/**
 * Web Terminal Client
 * Main application entry point.
 *
 * Authentication flow:
 * 1. Server injects session data via window.__SESSION__ on page load
 * 2. If session is pending, show approval code for user to enter in Flutter app
 * 3. Once approved, connect WebSocket (session ID in HTTP-only cookie)
 * 4. Create PTY sessions for terminal tabs
 */

import '@xterm/xterm/css/xterm.css';
import {
  WsClient,
  SessionStatusMessage,
  CreatePtyResponse,
  PtyExitedMessage,
  ErrorMessage,
  WsMessage,
} from './ws-client';
import { TerminalManager } from './terminal-manager';

// Session data injected by server
interface SessionData {
  id: string;
  approvalCode: string;
  status: 'pending' | 'approved' | 'connected' | 'rejected' | 'expired' | 'disconnected';
}

declare global {
  interface Window {
    __SESSION__?: SessionData;
  }
}

// Application state
type AppState = 'pending' | 'connecting' | 'connected' | 'disconnected' | 'error';

class TerminalApp {
  private wsClient: WsClient;
  private terminalManager: TerminalManager | null = null;
  private state: AppState = 'pending';
  private session: SessionData | null = null;
  private statusPollInterval: ReturnType<typeof setInterval> | null = null;

  // DOM elements
  private pendingScreen!: HTMLElement;
  private terminalScreen!: HTMLElement;
  private approvalCodeEl!: HTMLElement;
  private statusText!: HTMLElement;
  private errorText!: HTMLElement;

  constructor() {
    // Determine WebSocket URL from current location
    const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${wsProtocol}//${window.location.host}/ws`;

    this.wsClient = new WsClient(wsUrl);
    this.setupWebSocketHandlers();
  }

  init(): void {
    // Get session from injected data
    this.session = window.__SESSION__ || null;

    console.log('[TerminalApp] Initializing with session:', this.session);

    // Get DOM elements
    this.pendingScreen = document.getElementById('pending-screen')!;
    this.terminalScreen = document.getElementById('terminal-screen')!;
    this.approvalCodeEl = document.getElementById('approval-code')!;
    this.statusText = document.getElementById('status-text')!;
    this.errorText = document.getElementById('error-text')!;

    // Setup new tab button
    const newTabBtn = document.querySelector('.new-tab-btn');
    if (newTabBtn) {
      newTabBtn.addEventListener('click', () => {
        if (this.terminalManager) {
          this.terminalManager.createTab();
        }
      });
    }

    // Initialize terminal manager
    const tabsContainer = document.getElementById('tabs-container')!;
    const terminalContainer = document.getElementById('terminal-container')!;
    this.terminalManager = new TerminalManager(
      this.wsClient,
      tabsContainer,
      terminalContainer
    );

    // Handle initial session state
    if (!this.session) {
      this.showError('No session. Please refresh the page.');
      return;
    }

    // Display approval code
    this.approvalCodeEl.textContent = this.session.approvalCode;

    // Check session status and act accordingly
    this.handleSessionState(this.session.status);
  }

  private handleSessionState(status: SessionData['status']): void {
    console.log('[TerminalApp] Handling session state:', status);

    switch (status) {
      case 'pending':
        this.state = 'pending';
        this.showScreen('pending');
        this.setStatus('Waiting for approval in the app...');
        this.startStatusPolling();
        break;
      case 'approved':
      case 'connected':
      case 'disconnected':
        this.stopStatusPolling();
        this.state = 'connecting';
        this.setStatus('Connecting...');
        this.wsClient.connect();
        break;
      case 'rejected':
        this.state = 'error';
        this.showError('Session was rejected by the app.');
        break;
      case 'expired':
        this.state = 'error';
        this.showError('Session expired. Please refresh the page.');
        break;
    }
  }

  private startStatusPolling(): void {
    // Poll session status every 2 seconds
    this.statusPollInterval = setInterval(async () => {
      try {
        const res = await fetch('/api/session');
        const data = await res.json();
        if (data.status !== 'pending') {
          this.handleSessionState(data.status);
        }
      } catch (e) {
        console.error('Failed to poll session status:', e);
      }
    }, 2000);
  }

  private stopStatusPolling(): void {
    if (this.statusPollInterval) {
      clearInterval(this.statusPollInterval);
      this.statusPollInterval = null;
    }
  }

  private setupWebSocketHandlers(): void {
    this.wsClient.setHandlers({
      onOpen: () => {
        this.setStatus('Connected');
        // Server will send session_status message
      },

      onClose: (code, reason) => {
        console.log(`WebSocket closed: ${code} ${reason}`);
        if (code === 4001) {
          this.state = 'error';
          this.showError(reason);
          return;
        }
        if (this.state === 'connected' || this.state === 'connecting' ||
            this.state === 'disconnected') {
          this.state = 'disconnected';
          this.showError('Connection lost. Reconnecting...');
          // Try to reconnect after 3 seconds
          setTimeout(() => {
            if (this.state === 'disconnected') {
              this.state = 'connecting';
              this.wsClient.connect();
            }
          }, 3000);
        }
      },

      onError: (error) => {
        console.error('WebSocket error:', error);
        if (this.state !== 'error') {
          this.showError('Connection error. Retrying...');
        }
      },

      onMessage: (message) => this.handleMessage(message),

      onTerminalData: (ptyId, data) => {
        this.terminalManager?.writeToTerminal(ptyId, data);
      },
    });
  }

  private handleMessage(message: WsMessage): void {
    switch (message.type) {
      case 'session_status':
        this.handleSessionStatus(message as SessionStatusMessage);
        break;
      case 'create_pty_response':
        this.handleCreatePtyResponse(message as CreatePtyResponse);
        break;
      case 'pty_exited':
        this.handlePtyExited(message as PtyExitedMessage);
        break;
      case 'error':
        this.handleError(message as ErrorMessage);
        break;
      case 'pong':
        // Heartbeat response, ignore
        break;
      default:
        console.log('Unknown message:', message);
    }
  }

  private handleSessionStatus(status: SessionStatusMessage): void {
    switch (status.status) {
      case 'connected':
        this.state = 'connected';
        this.clearError();
        this.showScreen('terminal');
        if (status.ptys) this.terminalManager?.syncPtys(status.ptys);
        // Create first terminal tab if none exist
        if (this.terminalManager?.getTabCount() === 0) {
          this.terminalManager.createTab();
        }
        break;
      case 'approved':
        // Session approved, wait for connected status
        this.setStatus('Session approved, connecting...');
        break;
      case 'pending':
        this.setStatus(`Waiting for approval. Code: ${status.approvalCode || this.session?.approvalCode}`);
        break;
      case 'rejected':
        this.state = 'error';
        this.showError('Session was rejected by the app.');
        this.wsClient.disconnect();
        break;
      case 'expired':
        this.state = 'error';
        this.showError('Session expired. Please refresh the page.');
        this.wsClient.disconnect();
        break;
    }
  }

  private handleCreatePtyResponse(response: CreatePtyResponse): void {
    this.terminalManager?.handlePtyCreated(
      response.ptyId,
      response.success,
      response.error
    );
  }

  private handlePtyExited(message: PtyExitedMessage): void {
    this.terminalManager?.handlePtyExited(message.ptyId, message.exitCode);
  }

  private handleError(error: ErrorMessage): void {
    console.error('Server error:', error.code, error.message);
    if (error.code === 'no_session' || error.code === 'invalid_session') {
      this.state = 'error';
      this.wsClient.disconnect();
    }
    this.showError(error.message);
  }

  private showScreen(screen: 'pending' | 'terminal'): void {
    console.log('[TerminalApp] Showing screen:', screen);
    this.pendingScreen.style.display = screen === 'pending' ? 'flex' : 'none';
    this.terminalScreen.style.display = screen === 'terminal' ? 'flex' : 'none';
  }

  private setStatus(text: string): void {
    this.statusText.textContent = text;
  }

  private showError(text: string): void {
    this.errorText.textContent = text;
    this.errorText.style.display = 'block';
  }

  private clearError(): void {
    this.errorText.textContent = '';
    this.errorText.style.display = 'none';
  }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const app = new TerminalApp();
  app.init();
});
