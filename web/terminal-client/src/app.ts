/**
 * Web Terminal Client
 * Main application entry point.
 */

import '@xterm/xterm/css/xterm.css';
import {
  WsClient,
  AuthResponse,
  SessionStatusMessage,
  CreatePtyResponse,
  ErrorMessage,
  WsMessage,
} from './ws-client';
import { TerminalManager } from './terminal-manager';

// Application state
type AppState =
  | 'disconnected'
  | 'connecting'
  | 'authenticating'
  | 'pending_approval'
  | 'connected';

class TerminalApp {
  private wsClient: WsClient;
  private terminalManager: TerminalManager | null = null;
  private state: AppState = 'disconnected';
  private token: string = '';

  // DOM elements
  private authScreen!: HTMLElement;
  private pendingScreen!: HTMLElement;
  private terminalScreen!: HTMLElement;
  private tokenInput!: HTMLInputElement;
  private connectBtn!: HTMLButtonElement;
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
    // Get DOM elements
    this.authScreen = document.getElementById('auth-screen')!;
    this.pendingScreen = document.getElementById('pending-screen')!;
    this.terminalScreen = document.getElementById('terminal-screen')!;
    this.tokenInput = document.getElementById('token-input') as HTMLInputElement;
    this.connectBtn = document.getElementById('connect-btn') as HTMLButtonElement;
    this.statusText = document.getElementById('status-text')!;
    this.errorText = document.getElementById('error-text')!;

    // Setup event listeners
    this.connectBtn.onclick = () => this.connect();
    this.tokenInput.onkeydown = (e) => {
      if (e.key === 'Enter') this.connect();
    };

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

    // Check for token in URL
    const urlParams = new URLSearchParams(window.location.search);
    const urlToken = urlParams.get('token');
    if (urlToken) {
      this.tokenInput.value = urlToken;
      // Clear URL
      window.history.replaceState({}, '', window.location.pathname);
    }

    this.showScreen('auth');
  }

  private setupWebSocketHandlers(): void {
    this.wsClient.setHandlers({
      onOpen: () => {
        this.setStatus('Connected, authenticating...');
        this.state = 'authenticating';
        this.wsClient.authenticate(this.token);
      },

      onClose: (code, reason) => {
        console.log(`WebSocket closed: ${code} ${reason}`);
        if (this.state !== 'disconnected') {
          this.state = 'disconnected';
          this.showError('Connection lost. Please reconnect.');
          this.showScreen('auth');
        }
      },

      onError: (error) => {
        console.error('WebSocket error:', error);
        this.showError('Connection error. Please try again.');
      },

      onMessage: (message) => this.handleMessage(message),

      onTerminalData: (ptyId, data) => {
        this.terminalManager?.writeToTerminal(ptyId, data);
      },
    });
  }

  private handleMessage(message: WsMessage): void {
    switch (message.type) {
      case 'auth_response':
        this.handleAuthResponse(message as AuthResponse);
        break;
      case 'session_status':
        this.handleSessionStatus(message as SessionStatusMessage);
        break;
      case 'create_pty_response':
        this.handleCreatePtyResponse(message as CreatePtyResponse);
        break;
      case 'error':
        this.handleError(message as ErrorMessage);
        break;
      default:
        console.log('Unknown message:', message);
    }
  }

  private handleAuthResponse(response: AuthResponse): void {
    if (response.success) {
      this.setStatus('Authentication successful. Waiting for approval...');
      this.state = 'pending_approval';
      this.showScreen('pending');
    } else {
      this.showError(response.message || 'Authentication failed');
      this.wsClient.disconnect();
      this.state = 'disconnected';
    }
  }

  private handleSessionStatus(status: SessionStatusMessage): void {
    switch (status.status) {
      case 'auth_required':
        // Server is ready for authentication, this is handled by onOpen
        console.log('Server ready for authentication');
        break;
      case 'approved':
        this.state = 'connected';
        this.showScreen('terminal');
        // Create first terminal tab
        if (this.terminalManager?.getTabCount() === 0) {
          this.terminalManager.createTab();
        }
        break;
      case 'rejected':
        this.showError('Session was rejected by the app.');
        this.wsClient.disconnect();
        this.state = 'disconnected';
        this.showScreen('auth');
        break;
      case 'pending':
        this.setStatus('Waiting for approval in the app...');
        break;
    }
  }

  private handleCreatePtyResponse(response: CreatePtyResponse): void {
    if (response.ptyId) {
      this.terminalManager?.handlePtyCreated(
        response.ptyId,
        response.success,
        response.message
      );
    }
  }

  private handleError(error: ErrorMessage): void {
    console.error('Server error:', error.message);
    this.showError(error.message);
  }

  private connect(): void {
    const token = this.tokenInput.value.trim();
    if (!token) {
      this.showError('Please enter a token');
      return;
    }

    this.token = token;
    this.clearError();
    this.setStatus('Connecting...');
    this.state = 'connecting';
    this.connectBtn.disabled = true;

    this.wsClient.connect();

    // Re-enable button after timeout
    setTimeout(() => {
      this.connectBtn.disabled = false;
    }, 3000);
  }

  private showScreen(screen: 'auth' | 'pending' | 'terminal'): void {
    this.authScreen.style.display = screen === 'auth' ? 'flex' : 'none';
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
