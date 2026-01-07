/**
 * Terminal manager for handling multiple terminal tabs.
 * Each tab corresponds to a PTY session on the server.
 */

import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { WebLinksAddon } from '@xterm/addon-web-links';
import { WebglAddon } from '@xterm/addon-webgl';
import { WsClient } from './ws-client';

export interface TerminalTab {
  id: string;
  terminal: Terminal;
  fitAddon: FitAddon;
  element: HTMLElement;
  title: string;
}

export class TerminalManager {
  private tabs: Map<string, TerminalTab> = new Map();
  private activeTabId: string | null = null;
  private wsClient: WsClient;
  private tabsContainer: HTMLElement;
  private terminalContainer: HTMLElement;
  private tabCounter = 0;

  constructor(
    wsClient: WsClient,
    tabsContainer: HTMLElement,
    terminalContainer: HTMLElement
  ) {
    this.wsClient = wsClient;
    this.tabsContainer = tabsContainer;
    this.terminalContainer = terminalContainer;

    // Handle resize
    window.addEventListener('resize', () => this.handleResize());
  }

  createTab(ptyId?: string): string {
    const id = ptyId || `pty-${++this.tabCounter}`;
    const title = `Terminal ${this.tabCounter}`;

    // Create terminal element
    const element = document.createElement('div');
    element.className = 'terminal-panel';
    element.id = `terminal-${id}`;
    element.style.display = 'none';
    this.terminalContainer.appendChild(element);

    // Create xterm instance
    const terminal = new Terminal({
      cursorBlink: true,
      cursorStyle: 'block',
      fontFamily: '"Fira Code", "SF Mono", Monaco, Menlo, Consolas, monospace',
      fontSize: 14,
      lineHeight: 1.2,
      theme: {
        background: '#1e1e2e',
        foreground: '#cdd6f4',
        cursor: '#f5e0dc',
        cursorAccent: '#1e1e2e',
        selectionBackground: '#45475a',
        black: '#45475a',
        red: '#f38ba8',
        green: '#a6e3a1',
        yellow: '#f9e2af',
        blue: '#89b4fa',
        magenta: '#f5c2e7',
        cyan: '#94e2d5',
        white: '#bac2de',
        brightBlack: '#585b70',
        brightRed: '#f38ba8',
        brightGreen: '#a6e3a1',
        brightYellow: '#f9e2af',
        brightBlue: '#89b4fa',
        brightMagenta: '#f5c2e7',
        brightCyan: '#94e2d5',
        brightWhite: '#a6adc8',
      },
    });

    // Load addons
    const fitAddon = new FitAddon();
    terminal.loadAddon(fitAddon);
    terminal.loadAddon(new WebLinksAddon());

    // Try WebGL renderer for performance
    try {
      terminal.loadAddon(new WebglAddon());
    } catch {
      console.warn('WebGL addon not available, using canvas renderer');
    }

    // Open terminal
    terminal.open(element);
    fitAddon.fit();

    // Handle terminal input
    terminal.onData((data) => {
      const encoder = new TextEncoder();
      this.wsClient.sendTerminalData(id, encoder.encode(data));
    });

    // Create tab button
    this.createTabButton(id, title);

    // Store tab
    const tab: TerminalTab = { id, terminal, fitAddon, element, title };
    this.tabs.set(id, tab);

    // Request PTY from server
    const dims = fitAddon.proposeDimensions();
    const cols = dims?.cols ?? 80;
    const rows = dims?.rows ?? 24;
    this.wsClient.createPty(id, cols, rows);

    // Activate this tab
    this.activateTab(id);

    return id;
  }

  private createTabButton(id: string, title: string): void {
    const tabButton = document.createElement('div');
    tabButton.className = 'tab';
    tabButton.dataset.tabId = id;

    const titleSpan = document.createElement('span');
    titleSpan.className = 'tab-title';
    titleSpan.textContent = title;

    const closeButton = document.createElement('button');
    closeButton.className = 'tab-close';
    closeButton.innerHTML = '&times;';
    closeButton.onclick = (e) => {
      e.stopPropagation();
      this.closeTab(id);
    };

    tabButton.appendChild(titleSpan);
    tabButton.appendChild(closeButton);

    tabButton.onclick = () => this.activateTab(id);

    // Insert before the new-tab button
    const newTabBtn = this.tabsContainer.querySelector('.new-tab-btn');
    if (newTabBtn) {
      this.tabsContainer.insertBefore(tabButton, newTabBtn);
    } else {
      this.tabsContainer.appendChild(tabButton);
    }
  }

  activateTab(id: string): void {
    const tab = this.tabs.get(id);
    if (!tab) return;

    // Deactivate current tab
    if (this.activeTabId) {
      const currentTab = this.tabs.get(this.activeTabId);
      if (currentTab) {
        currentTab.element.style.display = 'none';
        this.getTabButton(this.activeTabId)?.classList.remove('active');
      }
    }

    // Activate new tab
    tab.element.style.display = 'block';
    this.getTabButton(id)?.classList.add('active');
    this.activeTabId = id;

    // Focus and fit
    setTimeout(() => {
      tab.fitAddon.fit();
      tab.terminal.focus();
    }, 0);
  }

  closeTab(id: string): void {
    const tab = this.tabs.get(id);
    if (!tab) return;

    // Close PTY on server
    this.wsClient.closePty(id);

    // Clean up
    tab.terminal.dispose();
    tab.element.remove();
    this.getTabButton(id)?.remove();
    this.tabs.delete(id);

    // Activate another tab if this was active
    if (this.activeTabId === id) {
      this.activeTabId = null;
      const remainingTabs = Array.from(this.tabs.keys());
      if (remainingTabs.length > 0) {
        this.activateTab(remainingTabs[remainingTabs.length - 1]);
      }
    }
  }

  writeToTerminal(ptyId: string, data: Uint8Array): void {
    const tab = this.tabs.get(ptyId);
    if (tab) {
      const decoder = new TextDecoder();
      tab.terminal.write(decoder.decode(data));
    }
  }

  handlePtyCreated(ptyId: string, success: boolean, message?: string): void {
    const tab = this.tabs.get(ptyId);
    if (!tab) return;

    if (!success) {
      tab.terminal.write(`\r\n\x1b[31mFailed to create terminal: ${message}\x1b[0m\r\n`);
    }
  }

  handlePtyClosed(ptyId: string): void {
    const tab = this.tabs.get(ptyId);
    if (tab) {
      tab.terminal.write('\r\n\x1b[33m[Session ended]\x1b[0m\r\n');
    }
  }

  private getTabButton(id: string): HTMLElement | null {
    return this.tabsContainer.querySelector(`[data-tab-id="${id}"]`);
  }

  private handleResize(): void {
    if (this.activeTabId) {
      const tab = this.tabs.get(this.activeTabId);
      if (tab) {
        tab.fitAddon.fit();
        const dims = tab.fitAddon.proposeDimensions();
        if (dims) {
          this.wsClient.resizePty(this.activeTabId, dims.cols, dims.rows);
        }
      }
    }
  }

  getTabCount(): number {
    return this.tabs.size;
  }

  clear(): void {
    for (const [id] of this.tabs) {
      this.closeTab(id);
    }
  }
}
