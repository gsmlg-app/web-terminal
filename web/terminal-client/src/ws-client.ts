/**
 * WebSocket client for communicating with the terminal server.
 * Handles both JSON control messages and binary terminal I/O.
 */

export type MessageType =
  | 'auth'
  | 'auth_response'
  | 'session_status'
  | 'create_pty'
  | 'create_pty_response'
  | 'close_pty'
  | 'resize_pty'
  | 'error';

export interface WsMessage {
  type: MessageType;
  [key: string]: unknown;
}

export interface AuthResponse extends WsMessage {
  type: 'auth_response';
  success: boolean;
  sessionId?: string;
  message?: string;
}

export interface SessionStatusMessage extends WsMessage {
  type: 'session_status';
  status: 'auth_required' | 'pending' | 'approved' | 'rejected';
  message?: string;
}

export interface CreatePtyResponse extends WsMessage {
  type: 'create_pty_response';
  success: boolean;
  ptyId?: string;
  message?: string;
}

export interface ErrorMessage extends WsMessage {
  type: 'error';
  message: string;
}

export type WsEventHandler = {
  onOpen?: () => void;
  onClose?: (code: number, reason: string) => void;
  onError?: (error: Event) => void;
  onMessage?: (message: WsMessage) => void;
  onTerminalData?: (ptyId: string, data: Uint8Array) => void;
};

export class WsClient {
  private ws: WebSocket | null = null;
  private url: string;
  private handlers: WsEventHandler = {};
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000;

  constructor(url: string) {
    this.url = url;
  }

  setHandlers(handlers: WsEventHandler): void {
    this.handlers = handlers;
  }

  connect(): void {
    if (this.ws?.readyState === WebSocket.OPEN) {
      return;
    }

    this.ws = new WebSocket(this.url);
    this.ws.binaryType = 'arraybuffer';

    this.ws.onopen = () => {
      this.reconnectAttempts = 0;
      this.handlers.onOpen?.();
    };

    this.ws.onclose = (event) => {
      this.handlers.onClose?.(event.code, event.reason);
    };

    this.ws.onerror = (error) => {
      this.handlers.onError?.(error);
    };

    this.ws.onmessage = (event) => {
      if (event.data instanceof ArrayBuffer) {
        // Binary frame: terminal data
        const frame = new Uint8Array(event.data);
        const decoded = this.decodeBinaryFrame(frame);
        if (decoded) {
          this.handlers.onTerminalData?.(decoded.ptyId, decoded.data);
        }
      } else {
        // JSON control message
        try {
          const message = JSON.parse(event.data) as WsMessage;
          this.handlers.onMessage?.(message);
        } catch {
          console.error('Failed to parse message:', event.data);
        }
      }
    };
  }

  disconnect(): void {
    if (this.ws) {
      this.ws.close(1000, 'Client disconnect');
      this.ws = null;
    }
  }

  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }

  // Send JSON control message
  send(message: WsMessage): void {
    if (!this.isConnected()) {
      console.error('WebSocket not connected');
      return;
    }
    this.ws!.send(JSON.stringify(message));
  }

  // Send authentication
  authenticate(token: string): void {
    this.send({ type: 'auth', token });
  }

  // Request new PTY
  createPty(ptyId: string, cols: number, rows: number): void {
    this.send({ type: 'create_pty', ptyId, cols, rows });
  }

  // Close PTY
  closePty(ptyId: string): void {
    this.send({ type: 'close_pty', ptyId });
  }

  // Resize PTY
  resizePty(ptyId: string, cols: number, rows: number): void {
    this.send({ type: 'resize_pty', ptyId, cols, rows });
  }

  // Send terminal input (binary frame)
  sendTerminalData(ptyId: string, data: Uint8Array): void {
    if (!this.isConnected()) {
      return;
    }
    const frame = this.encodeBinaryFrame(ptyId, data);
    this.ws!.send(frame);
  }

  // Encode binary frame: [ptyId length (1 byte)][ptyId bytes][data]
  private encodeBinaryFrame(ptyId: string, data: Uint8Array): Uint8Array {
    const encoder = new TextEncoder();
    const ptyIdBytes = encoder.encode(ptyId);
    const frame = new Uint8Array(1 + ptyIdBytes.length + data.length);
    frame[0] = ptyIdBytes.length;
    frame.set(ptyIdBytes, 1);
    frame.set(data, 1 + ptyIdBytes.length);
    return frame;
  }

  // Decode binary frame
  private decodeBinaryFrame(
    frame: Uint8Array
  ): { ptyId: string; data: Uint8Array } | null {
    if (frame.length < 2) {
      return null;
    }
    const ptyIdLength = frame[0];
    if (frame.length < 1 + ptyIdLength) {
      return null;
    }
    const decoder = new TextDecoder();
    const ptyId = decoder.decode(frame.slice(1, 1 + ptyIdLength));
    const data = frame.slice(1 + ptyIdLength);
    return { ptyId, data };
  }
}
