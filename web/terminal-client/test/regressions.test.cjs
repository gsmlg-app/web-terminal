const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');
const { transformSync } = require('esbuild');

function load(name, dependencies = {}, globals = {}) {
  let source = readFileSync(path.join(__dirname, '../src', name), 'utf8');
  if (name === 'app.ts') source += '\nexport { TerminalApp };\n';
  const code = transformSync(source, { loader: 'ts', format: 'cjs' }).code;
  const module = { exports: {} };
  vm.runInNewContext(code, {
    module, require: (name) => dependencies[name] || {},
    TextDecoder, TextEncoder, Uint8Array, ArrayBuffer, atob, Map, console,
    setTimeout, clearTimeout, setInterval, clearInterval,
    ...globals,
  });
  return module.exports;
}

function element() {
  return {
    style: {}, dataset: {}, classList: { add() {}, remove() {} },
    appendChild() {}, remove() {}, querySelector() { return null; },
  };
}

function manager() {
  class Terminal {
    text = '';
    loadAddon() {} open() {} onData() {} focus() {} dispose() {}
    reset() { this.text = ''; }
    resize() {}
    write(data) { this.text += data; }
  }
  class FitAddon { fit() {} proposeDimensions() { return { cols: 80, rows: 24 }; } }
  const { TerminalManager } = load('terminal-manager.ts', {
    '@xterm/xterm': { Terminal }, '@xterm/addon-fit': { FitAddon },
    '@xterm/addon-web-links': { WebLinksAddon: class {} },
    '@xterm/addon-webgl': { WebglAddon: class {} },
  }, { window: { addEventListener() {} }, document: { createElement: element } });
  const created = [], closed = [];
  const client = {
    createPty: (...args) => created.push(args), closePty: (id) => closed.push(id),
    resizePty() {}, sendTerminalData() {},
  };
  return { manager: new TerminalManager(client, element(), element()), created, closed };
}

test('UTF-8 streams retain incomplete bytes independently for each tab', () => {
  const { manager: m } = manager();
  m.createTab('pty-1'); m.createTab('pty-2');
  const bytes = new TextEncoder().encode('中文😀');
  m.writeToTerminal('pty-1', bytes.slice(0, 1));
  m.writeToTerminal('pty-2', new TextEncoder().encode('other'));
  m.writeToTerminal('pty-1', bytes.slice(1, 8));
  m.writeToTerminal('pty-1', bytes.slice(8));
  assert.equal(m.tabs.get('pty-1').terminal.text, '中文😀');
  assert.equal(m.tabs.get('pty-1').buffer, '中文😀');
  assert.equal(m.tabs.get('pty-2').terminal.text, 'other');
});

test('reconnect resync reuses PTYs, restores split UTF-8 and avoids ID collisions', () => {
  const { manager: m, created, closed } = manager();
  m.createTab('pty-1');
  const snapshot = [{ id: 'pty-7', cols: 100, rows: 30,
    data: Buffer.from([0xe4]).toString('base64') }];
  m.syncPtys(snapshot);
  m.writeToTerminal('pty-7', Uint8Array.from([0xb8, 0xad]));
  assert.equal(m.tabs.get('pty-7').terminal.text, '中');
  assert.equal(m.getTabCount(), 1);
  assert.equal(created.length, 1);
  assert.deepEqual(closed, []);
  m.syncPtys([{ ...snapshot[0], data: Buffer.from('中').toString('base64') }]);
  assert.equal(m.tabs.get('pty-7').terminal.text, '中');
  assert.equal(m.createTab(), 'pty-8');
});

test('WsClient avoids overlapping connects and ignores stale socket events', () => {
  const sockets = [];
  class Socket {
    static OPEN = 1; static CONNECTING = 0;
    readyState = 0;
    constructor() { sockets.push(this); }
    close() { this.readyState = 3; }
  }
  const { WsClient } = load('ws-client.ts', {}, { WebSocket: Socket });
  const client = new WsClient('ws://example');
  let closes = 0;
  client.setHandlers({ onClose: () => closes++ });
  client.connect(); client.connect();
  assert.equal(sockets.length, 1);
  sockets[0].readyState = 3;
  client.connect();
  sockets[0].onclose({ code: 1000, reason: '' });
  assert.equal(closes, 0);
  client.disconnect();
});

function app() {
  const timers = [];
  class WsClient {
    connects = 0;
    setHandlers(handlers) { this.handlers = handlers; }
    connect() { this.connects++; }
    disconnect() {}
  }
  const { TerminalApp } = load('app.ts', { './ws-client': { WsClient } }, {
    window: { location: { protocol: 'http:', host: 'example' } },
    document: { addEventListener() {} }, setTimeout: (fn) => { timers.push(fn); },
  });
  const a = new TerminalApp();
  a.setStatus = () => {}; a.showError = () => {};
  a.clearError = () => {}; a.showScreen = () => {};
  return { a, timers };
}

test('connection failures continue retrying after the first reconnect fails', () => {
  const { a, timers } = app();
  a.state = 'connected';
  a.wsClient.handlers.onClose(1006, '');
  timers.shift()();
  a.wsClient.handlers.onClose(1006, '');
  assert.equal(timers.length, 1);
  timers.shift()();
  assert.equal(a.wsClient.connects, 2);
});

test('connected status synchronizes existing PTYs instead of creating one', () => {
  const { a } = app();
  let created = 0, synced;
  a.terminalManager = {
    syncPtys: (ptys) => { synced = ptys; },
    getTabCount: () => synced?.length || 0, createTab: () => { created++; },
  };
  const ptys = [{ id: 'pty-7', cols: 80, rows: 24, data: '' }];
  a.handleSessionStatus({ type: 'session_status', status: 'connected', ptys });
  assert.equal(synced, ptys);
  assert.equal(created, 0);
});

test('refreshing a disconnected approved page starts reconnecting', () => {
  const { a } = app();
  a.handleSessionState('disconnected');
  assert.equal(a.wsClient.connects, 1);
});

test('invalid or expired session errors terminate reconnect attempts', () => {
  const { a } = app();
  a.state = 'disconnected';
  a.handleError({ code: 'invalid_session', message: 'Expired' });
  assert.equal(a.state, 'error');
});

test('a replaced browser tab stops reconnecting instead of evicting its replacement', () => {
  const { a, timers } = app();
  a.state = 'connected';
  a.wsClient.handlers.onClose(4001, 'Session opened in another tab');
  assert.equal(a.state, 'error');
  assert.equal(timers.length, 0);
});
