# Data Model: Update Xterm Terminal Widget

## Entities

### Terminal Session

**Description**: Represents an active terminal instance and its runtime state.

**Fields**:
- **Session ID**: Unique identifier for the session
- **Viewport Size**: Rows and columns visible to the user
- **Scrollback Limit**: Maximum number of lines retained
- **Cursor Position**: Current cursor row/column
- **Mode Flags**: Active modes such as insert/overwrite or selection mode

**Relationships**:
- Owns one **Terminal Buffer**
- Receives many **Interaction Events**

---

### Terminal Buffer

**Description**: Ordered collection of output lines representing visible content and
history.

**Fields**:
- **Lines**: Ordered list of output lines
- **Line Attributes**: Styling or state metadata associated with each line
- **Wrap State**: Whether a line is wrapped from previous output

**Relationships**:
- Belongs to a **Terminal Session**

---

### Interaction Event

**Description**: User-driven actions affecting terminal state.

**Fields**:
- **Event Type**: Input, selection, paste, resize, or scroll
- **Payload**: Data associated with the event (text, coordinates, dimensions)
- **Timestamp**: When the interaction occurred

**Relationships**:
- Targets a **Terminal Session**

## Validation Rules

- **Viewport Size** must remain within supported limits for the target platform.
- **Scrollback Limit** must be non-negative and large enough to preserve history.
- **Cursor Position** must always remain within the current buffer bounds.
- **Interaction Event Payload** must match the declared event type.
