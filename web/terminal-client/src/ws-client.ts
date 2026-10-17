/**
 * WebSocket client for communicating with the terminal server.
 * Handles both JSON control messages and binary terminal I/O.
 *
 * Authentication is now via HTTP-only session cookie - no token required.
 */

export type MessageType =
  | 'session_status'
  | 'create_pty'
  | 'create_pty_response'
  | 'close_pty'
  | 'resize_pty'
  | 'pty_exited'
  | 'ping'
  | 'pong'
  | 'error';

export interface WsMessage {
  type: MessageType;
  [key: string]: unknown;
}

export interface SessionStatusMessage extends WsMessage {
  type: 'session_status';
  status: 'pending' | 'approved' | 'connected' | 'rejected' | 'expired' | 'disconnected';
  message?: string;
  approvalCode?: string;
  ptys?: PtySnapshot[];
}

export interface PtySnapshot {
  id: string;
  cols: number;
  rows: number;
  data: string;
}

export interface PingMessage extends WsMessage {
  type: 'ping';
  sentAt: number;
}

export interface PongMessage extends WsMessage {
  type: 'pong';
  sentAt: number;
}

export interface CreatePtyResponse extends WsMessage {
  type: 'create_pty_response';
  ptyId: string;
  success: boolean;
  error?: string;
}

export interface PtyExitedMessage extends WsMessage {
  type: 'pty_exited';
  ptyId: string;
  exitCode: number;
}

export interface ErrorMessage extends WsMessage {
  type: 'error';
  code: string;
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
  private pingInterval: ReturnType<typeof setInterval> | null = null;

  constructor(url: string) {
    this.url = url;
  }

  setHandlers(handlers: WsEventHandler): void {
    this.handlers = handlers;
  }

  connect(): void {
    if (this.ws?.readyState === WebSocket.OPEN ||
        this.ws?.readyState === WebSocket.CONNECTING) {
      return;
    }

    const socket = new WebSocket(this.url);
    this.ws = socket;
    socket.binaryType = 'arraybuffer';

    socket.onopen = () => {
      if (this.ws !== socket) return;
      this.startPing();
      this.handlers.onOpen?.();
    };

    socket.onclose = (event) => {
      if (this.ws !== socket) return;
      this.ws = null;
      this.stopPing();
      this.handlers.onClose?.(event.code, event.reason);
    };

    socket.onerror = (error) => {
      if (this.ws !== socket) return;
      this.handlers.onError?.(error);
    };

    socket.onmessage = (event) => {
      if (this.ws !== socket) return;
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
          if (message.type === 'ping') {
            const sentAt =
              typeof message.sentAt === 'number' ? message.sentAt : Date.now();
            this.send({ type: 'pong', sentAt });
          }
          this.handlers.onMessage?.(message);
        } catch {
          console.error('Failed to parse message:', event.data);
        }
      }
    };
  }

  disconnect(): void {
    this.stopPing();
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

  // Send ping to keep connection alive
  private sendPing(): void {
    if (this.isConnected()) {
      this.send({ type: 'ping', sentAt: Date.now() });
    }
  }

  private startPing(): void {
    this.pingInterval = setInterval(() => this.sendPing(), 30000);
  }

  private stopPing(): void {
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
      this.pingInterval = null;
    }
  }

  // Encode binary frame: [ptyId length (1 byte)][ptyId bytes][data]
  private encodeBinaryFrame(
    ptyId: string,
    data: Uint8Array
  ): Uint8Array<ArrayBuffer> {
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
