# HomeWorkerFinder — WebSocket Documentation (Order Integration)

> **Target audience:** Flutter (Dart) frontend engineers integrating real-time order events.
> **Version:** 1.0 | **Date:** 2026-06-13
> **Backend stack:** Django Channels (ASGI) · `InMemoryChannelLayer` (dev) / Redis (prod)
> **Related HTTP docs:** see `API_DOCUMENTATION.md` §7 (Order REST) and §9 (WebSocket reference).

This file is the **complete WebSocket spec for the order flow**. Order lifecycle events (create, counter, accept, pay, start work, complete, cancel, change-request, set-hour) are broadcast to a chat room over the **Chat WebSocket** as `message_type: "EVENT"` frames. Notifications about order state changes are also pushed over the **Notification WebSocket**.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Base URLs](#2-base-urls)
3. [Authentication](#3-authentication)
4. [Chat WebSocket — Order Events](#4-chat-websocket--order-events)
   - [4.1 Connect](#41-connect)
   - [4.2 Connection rejection / close codes](#42-connection-rejection--close-codes)
   - [4.3 Outgoing frames (client → server)](#43-outgoing-frames-client--server)
   - [4.4 Incoming frames (server → client)](#44-incoming-frames-server--client)
   - [4.5 Order Event Frame — full schema](#45-order-event-frame--full-schema)
   - [4.6 Per-event payload reference](#46-per-event-payload-reference)
5. [Notification WebSocket](#5-notification-websocket)
6. [Order Event ⇄ REST Endpoint Map](#6-order-event--rest-endpoint-map)
7. [Flutter Integration Guide](#7-flutter-integration-guide)
   - [7.1 Dependencies](#71-dependencies)
   - [7.2 Connect + auth helper](#72-connect--auth-helper)
   - [7.3 Frame parser / dispatcher](#73-frame-parser--dispatcher)
   - [7.4 Sending order chat messages](#74-sending-order-chat-messages)
   - [7.5 Reconnect strategy](#75-reconnect-strategy)
8. [Edge cases & gotchas](#8-edge-cases--gotchas)
9. [Enum Reference (WebSocket)](#9-enum-reference-websocket)

---

## 1. Architecture Overview

Two independent WebSocket channels exist:

| Channel | URL | Purpose |
|---|---|---|
| **Chat** | `/ws/chat/<roomUUID>/<profileType>/` | Two-way chat between one customer and one provider. Also carries **order lifecycle events** for that pair. |
| **Notification** | `/ws/notification/` | One-way push: the server sends notifications to the authenticated user. |

**Important:** Order events do not have their own dedicated socket. They are **delivered through the Chat WebSocket** as a special message kind (`message_type: "EVENT"`). The Flutter client should:

1. Open a Chat WS for each conversation a user is viewing.
2. Branch in `onMessage` on `message_type` — `TEXT` / `IMAGE` / `VIDEO` / `AUDIO` / `FILE` / `EVENT` / `delete`.
3. For `EVENT`, branch again on `event.event_type` (e.g. `ORDER_CREATED`, `ORDER_COUNTER`, ...) and render an inline order card.
4. Optionally keep the Notification WS open globally to update a notifications badge.

Server-side, REST handlers in `task/views.py` call `PushSendMessage.order_chat_message(...)` after they mutate the order, which:
- Creates a `ChatMessage` with `message_type=EVENT` and a `ChatEvent` row carrying the order snapshot.
- Broadcasts the serialized payload to the Channels group `chat_{roomUUID}`.
- Anyone connected to that room receives the payload immediately.

---

## 2. Base URLs

| Environment | WebSocket Base |
|---|---|
| Production | `wss://api.yourdomain.com/ws` |
| Local ASGI dev (daphne) | `ws://127.0.0.1:8001/ws` |

> The default `python manage.py runserver` (WSGI on port 8000) does **not** serve WebSocket. Use `daphne find_worker_config.asgi:application` (port 8001 in this project) for local WS testing.

---

## 3. Authentication

WebSocket connections authenticate with the same JWT access token used for HTTP. The server's `JWTAuthMiddleware` (`chat_notify/middleware.py`) accepts the token from **either**:

| Method | How to send | Notes |
|---|---|---|
| Authorization header | `Authorization: Bearer <access_token>` | Works in native clients that support custom WS upgrade headers. |
| Query string | `?token=<access_token>` | **Recommended for Flutter.** `web_socket_channel` cannot set custom headers on most platforms. |

If the token is missing, invalid, or expired the user is `AnonymousUser`, and the consumer rejects the connection (close code `4003` via `DenyConnection` or a plain `1006`).

**On 401-equivalent disconnect:** Run the standard JWT refresh flow (`POST /token/refresh/`) and reconnect with the new access token.

---

## 4. Chat WebSocket — Order Events

### 4.1 Connect

```
URL:  wss://api.yourdomain.com/ws/chat/{roomUUID}/{profileType}/?token=<access_token>
```

| URL segment | Type | Values |
|---|---|---|
| `roomUUID` | string | 32-char hex from `ChatRoom.uuid` (e.g. `a1b2c3d4e5f67890a1b2c3d4e5f67890`). Obtain via `POST /room/start-chat/` (HTTP). |
| `profileType` | string | `CUSTOMER` or `PROVIDER`. Case-insensitive on the server (it calls `.upper()`). |

**Example URL:**
```
wss://api.yourdomain.com/ws/chat/a1b2c3d4e5f67890a1b2c3d4e5f67890/CUSTOMER/?token=eyJhbGciOi...
```

On successful upgrade the consumer:
- Joins the Channels group `chat_{roomUUID}`.
- Sends no greeting frame. Just open and wait for the first `chat_message` event.

### 4.2 Connection rejection / close codes

The consumer closes the socket if any of these conditions hold (see `ChatConsumer.connect`):

| Condition | Behaviour |
|---|---|
| `profileType` not in `{"CUSTOMER", "PROVIDER"}` | `await self.close()` — typically reported as `1006` on the client. |
| User is anonymous (no/invalid JWT) | `raise DenyConnection("Unauthorized")` → close code `4003`. |
| `ChatRoom` with `uuid=roomUUID` does not exist | `await self.close()` → `1006`. |
| Authenticated user is **neither** the room's customer nor its provider | `await self.close()` → `1006`. |
| Customer and provider are the **same user** | `await self.close()` → `1006`. |

**Flutter rule:**
- `4001` / `4003` → permanent: do not reconnect, redirect to auth/error screen.
- `1006` and other abnormal closures → transient: reconnect with exponential backoff.

### 4.3 Outgoing frames (client → server)

All frames are JSON. The discriminator is the top-level `type` field.

#### Text message
```json
{
  "type": "text",
  "message": "Are you available tomorrow?"
}
```
| Field | Required | Notes |
|---|---|---|
| `type` | yes | Must be `"text"` (case-insensitive). |
| `message` | yes | Non-empty; empty strings are silently dropped server-side. |

#### Attachment message (image / video / audio / file)
```json
{
  "type": "image",
  "message": "Before photo of the bathroom",
  "attachment_name": "before_photo.jpg",
  "attachment_size": 204800,
  "raw_file": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD..."
}
```
| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"image"`, `"video"`, `"audio"`, or `"file"`. |
| `message` | no | Optional caption. |
| `attachment_name` | yes | Filename + extension. |
| `attachment_size` | yes | Size in bytes. Server rejects > **25 MB** (`25 * 1024 * 1024`). |
| `raw_file` | yes | **Full data URI** including MIME prefix, e.g. `"data:image/jpeg;base64,...."`. The server splits on the first comma. |

#### Delete message
```json
{
  "type": "delete",
  "message_id": 101,
  "roomId": "a1b2c3d4e5f67890a1b2c3d4e5f67890"
}
```
| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"delete"`. |
| `message_id` | yes | `ChatMessage.id`. |
| `roomId` | yes | Room UUID (32-char hex). |

> **Order events are emitted by the server only.** You do not send order events over WS — you trigger them by calling the corresponding HTTP REST endpoint (see §6). The server pushes the resulting event into the chat room.

### 4.4 Incoming frames (server → client)

Every server-pushed frame has top-level `type: "chat_message"`. Branch on `message_type`:

| `message_type` | Meaning | Has `attachments` | Has `event` |
|---|---|---|---|
| `TEXT` | Plain text chat | empty `{}` | empty `{}` |
| `IMAGE` / `VIDEO` / `AUDIO` / `FILE` | Attachment chat | populated | empty `{}` |
| `EVENT` | **Order lifecycle event** (e.g. order created, work started) | empty `{}` | populated |
| `delete` | A message was deleted | n/a | n/a |

#### Text frame
```json
{
  "type": "chat_message",
  "id": 101,
  "message_type": "TEXT",
  "content": "Are you available tomorrow?",
  "timestamp": "2026-06-05T10:30:00.123456+00:00",
  "is_read": false,
  "attachments": {},
  "event": {},
  "sender": "CUSTOMER",
  "sender_data": {
    "first_name": "Alice",
    "last_name": "Chen",
    "photo": "https://api.yourdomain.com/media/users/alice.jpg",
    "user": "USER"
  }
}
```

#### Attachment frame
```json
{
  "type": "chat_message",
  "id": 103,
  "message_type": "IMAGE",
  "content": "Before photo of the bathroom",
  "timestamp": "2026-06-05T10:32:00.000000+00:00",
  "is_read": false,
  "attachments": {
    "url": "https://api.yourdomain.com/media/chat/before_photo.jpg",
    "mime": "IMAGE",
    "name": "before_photo.jpg",
    "size": 204800
  },
  "event": {},
  "sender": "CUSTOMER",
  "sender_data": {
    "first_name": "Alice", "last_name": "Chen",
    "photo": "https://api.yourdomain.com/media/users/alice.jpg",
    "user": "USER"
  }
}
```

#### Delete frame
```json
{
  "type": "chat_message",
  "message_type": "delete",
  "message_id": 101
}
```

### 4.5 Order Event Frame — full schema

When `message_type == "EVENT"`, the frame represents an **order lifecycle event**. Render it as an in-conversation system card (not a chat bubble).

```json
{
  "type": "chat_message",
  "id": 102,
  "message_type": "EVENT",
  "content": "",
  "timestamp": "2026-06-05T10:31:00.000000+00:00",
  "is_read": false,
  "attachments": {},
  "event": {
    "id": 1,
    "event_type": "ORDER_CREATED",
    "order_object": {
      "id": 42,
      "title": "Home Cleaning",
      "description": "Deep clean of a 3-bedroom apartment...",
      "area": "Downtown Toronto",
      "amount": "120.00",
      "status": "PENDING",
      "payment_status": "UNPAID",
      "working_date": "2026-06-10",
      "working_start_time": "09:00:00",
      "working_hour": 3,
      "end_time": "12:00:00",
      "end_datetime": "2026-06-10T12:00:00+00:00",
      "created_at": "2026-06-05T10:30:00.000000+00:00"
    },
    "reference_object": null,
    "created_at": "2026-06-05T10:31:00.000000+00:00",
    "updated_at": "2026-06-05T10:31:00.000000+00:00"
  },
  "sender": "CUSTOMER",
  "sender_data": {
    "first_name": "Alice", "last_name": "Chen",
    "photo": "https://api.yourdomain.com/media/users/alice.jpg",
    "user": "USER"
  }
}
```

**`event` object fields:**

| Field | Type | Notes |
|---|---|---|
| `id` | int | `ChatEvent.id`. |
| `event_type` | string | One of `SendEventType` — see §9. Branch on this to pick a renderer. |
| `order_object` | object | Snapshot of the related `Order`. Always present for order events. Fields below. |
| `reference_object` | object \| null | Present for events tied to an `OrderChangesRequest` (counter, propose-new-time, cancel, set-hour). Fields below. |
| `created_at` / `updated_at` | string (ISO 8601) | Event timestamps. |

**`event.order_object` fields:**

| Field | Type | Notes |
|---|---|---|
| `id` | int | Order ID — use for HTTP follow-up calls. |
| `title` | string | |
| `description` | string | |
| `area` | string | |
| `amount` | string (decimal) | Parse with `double.parse`. |
| `status` | string | `OrderStatus` enum value — see §9. Use this to drive UI state. |
| `payment_status` | string | `OrderPaymentStatus` enum value. |
| `working_date` | string | ISO `YYYY-MM-DD`. |
| `working_start_time` | string | `HH:MM:SS`. |
| `working_hour` | int | |
| `end_time` | string \| null | `HH:MM:SS`, may be null. |
| `end_datetime` | string \| null | ISO 8601, may be null. |
| `created_at` | string | ISO 8601. |

**`event.reference_object` fields** (only when `event_type` ∈ {`ORDER_COUNTER`, `ORDER_CHANGE_REQUEST`, `ORDER_CANCEL`, `ORDER_HOUR_SET`}):

| Field | Type | Notes |
|---|---|---|
| `id` | int | `OrderChangesRequest.id` — pass back as `request_id` / `changes_request_id` when responding via REST. |
| `request_by` | string | `"CUSTOMER"` or `"PROVIDER"` — who initiated. |
| `status` | string | `ACCEPT`, `DECLINED`, or `NO_RESPONSE`. |
| `changes_type` | string | `TIME`, `DATE`, `TIME_AND_DATE`, `AMOUNT`, `COUNTER`, `SET_HOUR`, or `CANCEL`. |
| `changes_data` | object | Free-form payload — fields depend on `changes_type`. E.g. for `COUNTER`: `{"budget": "100.00", "message": "..."}`; for `TIME_AND_DATE`: `{"date": "2026-06-11", "time": "10:00 AM", "message": "..."}`. |
| `created_at` / `updated_at` | string | ISO 8601. |

### 4.6 Per-event payload reference

Each subsection shows a complete example frame the client receives. All examples use the canonical mock seed (Alice = customer id 1; Bob = provider id 1; Order id 42; Room UUID `a1b2c3d4e5f67890a1b2c3d4e5f67890`).

---

#### `ORDER_CREATED`

**Trigger:** Customer calls `POST /order-create/`.
**Sent by group:** `chat_{roomUUID}`. The room is created if missing.
**Sender field:** `"CUSTOMER"`.

```json
{
  "type": "chat_message",
  "id": 200, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-05T10:30:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 11, "event_type": "ORDER_CREATED",
    "order_object": {
      "id": 42, "title": "Home Cleaning",
      "amount": "120.00",
      "status": "PENDING", "payment_status": "UNPAID",
      "working_date": "2026-06-10", "working_start_time": "09:00:00", "working_hour": 3
    },
    "reference_object": null
  },
  "sender": "CUSTOMER",
  "sender_data": {"first_name": "Alice", "last_name": "Chen", "photo": "...", "user": "USER"}
}
```

**Flutter render:** Show an "Order requested — awaiting provider" card.

---

#### `ORDER_COUNTER`

**Trigger:** `POST /order/customer/{id}/counter/` **or** `POST /order/provider/{id}/counter/`.
**Sender field:** `"CUSTOMER"` or `"PROVIDER"` depending on who counter-offered.
**`reference_object`:** populated with the new `OrderChangesRequest` (type `COUNTER`).

```json
{
  "type": "chat_message",
  "id": 201, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-05T11:10:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 12, "event_type": "ORDER_COUNTER",
    "order_object": { "id": 42, "title": "Home Cleaning", "amount": "120.00", "status": "PENDING", "payment_status": "UNPAID" },
    "reference_object": {
      "id": 7, "request_by": "CUSTOMER", "status": "NO_RESPONSE",
      "changes_type": "COUNTER",
      "changes_data": { "budget": "100.00", "message": "Budget is tight this month." }
    }
  },
  "sender": "CUSTOMER",
  "sender_data": {"first_name": "Alice", "last_name": "Chen", "photo": "...", "user": "USER"}
}
```

**Flutter render:** "Alice proposed a new price: CA$100.00" card with Accept / Decline buttons that POST a response to the matching `/counter/` endpoint on the **other** role's path.

---

#### `ORDER_STATUS`

**Trigger:** Generic status transitions, fired on `accept`, `pay-and-confirm`, `cancel-accept` etc. Use `order_object.status` to know the new state.
**Sender field:** Whichever role acted.
**`reference_object`:** usually `null` (some flows include the related changes request — see `ORDER_CANCEL` below for that pattern).

```json
{
  "type": "chat_message",
  "id": 202, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-05T11:00:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 13, "event_type": "ORDER_STATUS",
    "order_object": { "id": 42, "title": "Home Cleaning", "amount": "120.00", "status": "ACCEPT", "payment_status": "UNPAID" },
    "reference_object": null
  },
  "sender": "CUSTOMER",
  "sender_data": {"first_name": "Alice", "last_name": "Chen", "photo": "...", "user": "USER"}
}
```

**Flutter render:** Update the order header / chip; show a one-line system message ("Order accepted — awaiting payment").

---

#### `ORDER_CANCEL`

**Trigger:** `POST /order/customer/{id}/cancel/`, `POST /order/provider/{id}/cancel/`, or `cancel-accept/` (DECLINE branch on the provider side).
**`reference_object`:** the `OrderChangesRequest` of type `CANCEL` (with `changes_data.message` containing the reason).

```json
{
  "type": "chat_message",
  "id": 203, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-05T12:00:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 14, "event_type": "ORDER_CANCEL",
    "order_object": { "id": 42, "status": "CANCELLATION_REQUEST", "payment_status": "PAID", "amount": "120.00" },
    "reference_object": {
      "id": 5, "request_by": "CUSTOMER", "status": "NO_RESPONSE",
      "changes_type": "CANCEL",
      "changes_data": { "message": "Need to reschedule — family emergency." }
    }
  },
  "sender": "CUSTOMER",
  "sender_data": {"first_name": "Alice", "last_name": "Chen", "photo": "...", "user": "USER"}
}
```

**Flutter render:**
- If `order_object.status == "CANCELLED"` → "Order cancelled".
- If `order_object.status == "CANCELLATION_REQUEST"` → "Cancellation requested" card; the **other** role sees Accept / Decline buttons → POST to `/cancel-accept/`.

---

#### `ORDER_CHANGE_REQUEST`

**Trigger:** `POST /order/{role}/{id}/propose-new-time/` with `action: "create"`.
**`reference_object`:** `OrderChangesRequest` of type `TIME`, `DATE`, or `TIME_AND_DATE`.

```json
{
  "type": "chat_message",
  "id": 204, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-06T09:00:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 15, "event_type": "ORDER_CHANGE_REQUEST",
    "order_object": { "id": 42, "status": "CONFIRM", "payment_status": "PAID", "working_date": "2026-06-10", "working_start_time": "09:00:00" },
    "reference_object": {
      "id": 9, "request_by": "PROVIDER", "status": "NO_RESPONSE",
      "changes_type": "TIME_AND_DATE",
      "changes_data": { "date": "2026-06-11", "time": "10:00 AM", "message": "Can we shift by one day?" }
    }
  },
  "sender": "PROVIDER",
  "sender_data": {"first_name": "Bob", "last_name": "Martinez", "photo": "...", "user": "USER"}
}
```

**Flutter render:** "Bob proposed a new time: Jun 11 at 10:00 AM" — Accept / Decline buttons that POST `{"action":"update","request_id": 9, "status": "ACCEPT"|"DECLINED"}` to the **counterpart role's** `/propose-new-time/` endpoint.

---

#### `ORDER_HOUR_SET`

**Trigger:** `POST /order/provider/{id}/set-work-hour/`.
**`reference_object`:** `OrderChangesRequest` of type `SET_HOUR`.

```json
{
  "type": "chat_message",
  "id": 205, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-10T09:15:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 16, "event_type": "ORDER_HOUR_SET",
    "order_object": { "id": 42, "status": "IN_PROGRESS", "working_hour": 4, "amount": "180.00" },
    "reference_object": {
      "id": 11, "request_by": "PROVIDER", "status": "NO_RESPONSE",
      "changes_type": "SET_HOUR",
      "changes_data": { "set_hour": 4, "message": "The apartment is larger than expected — 4 hours needed." }
    }
  },
  "sender": "PROVIDER",
  "sender_data": {"first_name": "Bob", "last_name": "Martinez", "photo": "...", "user": "USER"}
}
```

**Flutter render:** "Bob updated estimated hours to 4" — show a card with the new amount and (for the customer) a confirm button.

---

#### `ORDER_WORK_START`

**Trigger:** `POST /order/provider/{id}/start-work/` (after GPS-within-100m check).
**Side effect on the server:** generates `confirmation_OTP` on the order; the customer must read this OTP from their order-detail screen and tell the provider.
**`reference_object`:** `null`.

```json
{
  "type": "chat_message",
  "id": 206, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-10T09:00:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 17, "event_type": "ORDER_WORK_START",
    "order_object": { "id": 42, "status": "IN_PROGRESS", "payment_status": "PAID" },
    "reference_object": null
  },
  "sender": "PROVIDER",
  "sender_data": {"first_name": "Bob", "last_name": "Martinez", "photo": "...", "user": "USER"}
}
```

**Flutter render (customer):** show a banner with the 6-digit confirmation OTP. **Flutter render (provider):** "Work started" + show an input to enter the customer's OTP for `complete`.

---

#### `ORDER_COMPLETE`

**Trigger:** `POST /order/provider/{id}/complete/` with the correct OTP.
**`reference_object`:** `null`.

```json
{
  "type": "chat_message",
  "id": 207, "message_type": "EVENT",
  "content": "", "timestamp": "2026-06-10T12:00:00+00:00", "is_read": false,
  "attachments": {},
  "event": {
    "id": 18, "event_type": "ORDER_COMPLETE",
    "order_object": { "id": 42, "status": "COMPLETED", "payment_status": "PAID", "amount": "120.00" },
    "reference_object": null
  },
  "sender": "PROVIDER",
  "sender_data": {"first_name": "Bob", "last_name": "Martinez", "photo": "...", "user": "USER"}
}
```

**Flutter render:** "Work completed" — show the rate-and-review CTA (POST `/order/customer/{id}/give-feedback/`).

---

#### `ORDER_UPDATED`

**Trigger:** Reserved for generic field changes. Currently unused by REST endpoints in `task/views.py` but defined in `SendEventType`. Treat it the same as `ORDER_STATUS`: re-render from `order_object`.

---

## 5. Notification WebSocket

The notification socket is independent of the chat socket and useful for global app-wide indicators (badge counts, top-bar toasts).

### 5.1 Connect

```
URL:  wss://api.yourdomain.com/ws/notification/?token=<access_token>
```

On connect, the server adds the channel to **three** groups simultaneously (`NotificationConsumer.connect`):

1. `notify_{user_id}` — direct personal notifications.
2. `role_{UserRole}` — role-based (e.g. `role_USER`).
3. `notify_all` — platform-wide announcements.

No client-side subscribe message is needed.

### 5.2 Incoming frame

```json
{
  "notify_text": "Bob started work on Order #42",
  "entity_type": "order",
  "entity": 42,
  "is_read": false
}
```

| Field | Type | Notes |
|---|---|---|
| `notify_text` | string | Human-readable message. |
| `entity_type` | string | Lowercase model name — e.g. `"order"`, `"ticket"`. |
| `entity` | int | Related object ID. For order events, this is the Order ID — fetch via `GET /order/{role}/{entity}/`. |
| `is_read` | bool | Always `false` on arrival. |

> The server actually broadcasts `{"type": "notify", "data": <object>}` to the channel group, but `NotificationConsumer.notify` strips the wrapper and forwards only `data` to the client. The Flutter client sees just the inner object shown above.

### 5.3 Flutter handling

- On receipt → increment in-app badge, optionally show a top-bar toast.
- For up-to-date metadata (`action`, `is_read`, timestamps), call `GET /notifications/` to refresh the list view.
- Mark all as read with `PATCH /notifications/` `{"is_read": true}`.

---

## 6. Order Event ⇄ REST Endpoint Map

Use this table to know **which HTTP call triggers which WS event**. The HTTP call is the action; the WS event is the consequence pushed to everyone in the room.

| Action | HTTP endpoint | WS `event_type` | `sender` | `reference_object` populated? |
|---|---|---|---|---|
| Create order | `POST /order-create/` | `ORDER_CREATED` | `CUSTOMER` | no |
| Counter-offer (customer) | `POST /order/customer/{id}/counter/` | `ORDER_COUNTER` | `CUSTOMER` | yes (`COUNTER`) |
| Counter-offer (provider) | `POST /order/provider/{id}/counter/` | `ORDER_COUNTER` | `PROVIDER` | yes (`COUNTER`) |
| Accept (customer) | `GET /order/customer/{id}/accept/` | `ORDER_STATUS` | `CUSTOMER` | no |
| Accept (provider) | `GET /order/provider/{id}/accept/` | `ORDER_STATUS` | `PROVIDER` | no |
| Pay & confirm | `GET /order/customer/{id}/pay-and-confirm/` | `ORDER_STATUS` | `CUSTOMER` | no |
| Propose new time | `POST /order/{role}/{id}/propose-new-time/` (`action=create`) | `ORDER_CHANGE_REQUEST` | acting role | yes (`TIME` / `DATE` / `TIME_AND_DATE`) |
| Cancel | `POST /order/{role}/{id}/cancel/` | `ORDER_CANCEL` | acting role | yes (`CANCEL`) |
| Respond to cancel | `POST /order/{role}/{id}/cancel-accept/` | `ORDER_CANCEL` (declined) **or** `ORDER_STATUS` (accepted → REFUND_REQUEST) | acting role | yes (`CANCEL`) |
| Set work hour | `POST /order/provider/{id}/set-work-hour/` | `ORDER_HOUR_SET` | `PROVIDER` | yes (`SET_HOUR`) |
| Start work | `POST /order/provider/{id}/start-work/` | `ORDER_WORK_START` | `PROVIDER` | no |
| Complete work | `POST /order/provider/{id}/complete/` | `ORDER_COMPLETE` | `PROVIDER` | no |

> The `sender` field on the WS frame is set explicitly by the server to whichever role triggered the action — not derived from the authenticated user. So the receiving client should treat `sender == "CUSTOMER"` as "the customer did this", regardless of whether *this* client is the customer or the provider.

---

## 7. Flutter Integration Guide

### 7.1 Dependencies

```yaml
dependencies:
  web_socket_channel: ^3.0.0
  flutter_secure_storage: ^9.2.2
  http: ^1.2.2
```

### 7.2 Connect + auth helper

```dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class OrderChatSocket {
  final String baseWs;         // e.g. 'wss://api.yourdomain.com/ws'
  final String roomUuid;       // 32-char hex
  final String profileType;    // 'CUSTOMER' or 'PROVIDER'
  final Future<String?> Function() getAccessToken; // returns current JWT

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _retry = 0;

  final _eventCtrl = StreamController<ChatFrame>.broadcast();
  Stream<ChatFrame> get events => _eventCtrl.stream;

  OrderChatSocket({
    required this.baseWs,
    required this.roomUuid,
    required this.profileType,
    required this.getAccessToken,
  });

  Future<void> connect() async {
    final token = await getAccessToken();
    if (token == null) throw StateError('No access token');

    final uri = Uri.parse('$baseWs/chat/$roomUuid/$profileType/')
        .replace(queryParameters: {'token': token});

    // IOWebSocketChannel.connect handles wss:// on mobile/desktop.
    final ch = IOWebSocketChannel.connect(uri);
    _channel = ch;
    _retry = 0;

    _sub = ch.stream.listen(
      (data) => _onMessage(data),
      onDone: () => _scheduleReconnect(ch.closeCode),
      onError: (_) => _scheduleReconnect(null),
      cancelOnError: true,
    );
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      _eventCtrl.add(ChatFrame.fromJson(json));
    } catch (_) {
      // ignore malformed frames
    }
  }

  void send(Map<String, dynamic> frame) {
    _channel?.sink.add(jsonEncode(frame));
  }

  void sendText(String message) =>
      send({'type': 'text', 'message': message});

  void deleteMessage(int messageId) => send({
        'type': 'delete',
        'message_id': messageId,
        'roomId': roomUuid,
      });

  void _scheduleReconnect(int? closeCode) {
    if (closeCode == 4001 || closeCode == 4003) {
      // permanent auth/permission failure
      _eventCtrl.addError(WebSocketAuthError(closeCode!));
      return;
    }
    _retry = (_retry + 1).clamp(1, 6);
    final delay = Duration(seconds: 1 << _retry); // 2,4,8,16,32,32 ...
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () => connect());
  }

  Future<void> close() async {
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
    await _eventCtrl.close();
  }
}

class WebSocketAuthError implements Exception {
  final int code;
  WebSocketAuthError(this.code);
}
```

### 7.3 Frame parser / dispatcher

```dart
class ChatFrame {
  final String type;          // always "chat_message"
  final String messageType;   // TEXT|IMAGE|VIDEO|AUDIO|FILE|EVENT|delete
  final int? id;
  final int? deletedMessageId;
  final String? content;
  final DateTime? timestamp;
  final String? sender;       // CUSTOMER|PROVIDER
  final SenderData? senderData;
  final Attachment? attachment;
  final OrderEvent? event;

  ChatFrame._({
    required this.type,
    required this.messageType,
    this.id,
    this.deletedMessageId,
    this.content,
    this.timestamp,
    this.sender,
    this.senderData,
    this.attachment,
    this.event,
  });

  factory ChatFrame.fromJson(Map<String, dynamic> j) {
    final mt = (j['message_type'] ?? '').toString();
    if (mt == 'delete') {
      return ChatFrame._(
        type: j['type'],
        messageType: mt,
        deletedMessageId: j['message_id'] as int?,
      );
    }
    final att = j['attachments'];
    final ev = j['event'];
    return ChatFrame._(
      type: j['type'],
      messageType: mt,
      id: j['id'] as int?,
      content: j['content'] as String?,
      timestamp:
          j['timestamp'] != null ? DateTime.tryParse(j['timestamp']) : null,
      sender: j['sender'] as String?,
      senderData: j['sender_data'] is Map
          ? SenderData.fromJson(Map<String, dynamic>.from(j['sender_data']))
          : null,
      attachment: att is Map && att.isNotEmpty
          ? Attachment.fromJson(Map<String, dynamic>.from(att))
          : null,
      event: ev is Map && ev.isNotEmpty
          ? OrderEvent.fromJson(Map<String, dynamic>.from(ev))
          : null,
    );
  }
}

class SenderData {
  final String firstName, lastName, photo, user;
  SenderData(this.firstName, this.lastName, this.photo, this.user);
  factory SenderData.fromJson(Map<String, dynamic> j) => SenderData(
        j['first_name'] ?? '',
        j['last_name'] ?? '',
        j['photo'] ?? '',
        j['user'] ?? '',
      );
}

class Attachment {
  final String url, mime, name;
  final int size;
  Attachment(this.url, this.mime, this.name, this.size);
  factory Attachment.fromJson(Map<String, dynamic> j) => Attachment(
        j['url'] ?? '',
        j['mime'] ?? '',
        j['name'] ?? '',
        (j['size'] as num?)?.toInt() ?? 0,
      );
}

class OrderEvent {
  final int id;
  final String eventType;       // ORDER_CREATED, ORDER_COUNTER, ...
  final OrderSnapshot? order;
  final ChangesRequest? reference;

  OrderEvent(this.id, this.eventType, this.order, this.reference);

  factory OrderEvent.fromJson(Map<String, dynamic> j) {
    return OrderEvent(
      j['id'] as int,
      j['event_type'] as String,
      j['order_object'] is Map
          ? OrderSnapshot.fromJson(Map<String, dynamic>.from(j['order_object']))
          : null,
      j['reference_object'] is Map
          ? ChangesRequest.fromJson(
              Map<String, dynamic>.from(j['reference_object']))
          : null,
    );
  }
}

class OrderSnapshot {
  final int id;
  final String title, status, paymentStatus;
  final double amount;
  final String workingDate;    // YYYY-MM-DD
  final String workingStartTime; // HH:MM:SS
  final int workingHour;
  OrderSnapshot({
    required this.id,
    required this.title,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    required this.workingDate,
    required this.workingStartTime,
    required this.workingHour,
  });
  factory OrderSnapshot.fromJson(Map<String, dynamic> j) => OrderSnapshot(
        id: j['id'] as int,
        title: j['title'] ?? '',
        status: j['status'] ?? '',
        paymentStatus: j['payment_status'] ?? '',
        amount: double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
        workingDate: j['working_date'] ?? '',
        workingStartTime: j['working_start_time'] ?? '',
        workingHour: (j['working_hour'] as num?)?.toInt() ?? 0,
      );
}

class ChangesRequest {
  final int id;
  final String requestBy;   // CUSTOMER|PROVIDER
  final String status;      // ACCEPT|DECLINED|NO_RESPONSE
  final String changesType; // COUNTER|TIME|DATE|TIME_AND_DATE|AMOUNT|SET_HOUR|CANCEL
  final Map<String, dynamic> changesData;
  ChangesRequest(this.id, this.requestBy, this.status, this.changesType,
      this.changesData);
  factory ChangesRequest.fromJson(Map<String, dynamic> j) => ChangesRequest(
        j['id'] as int,
        j['request_by'] ?? '',
        j['status'] ?? '',
        j['changes_type'] ?? '',
        Map<String, dynamic>.from(j['changes_data'] ?? const {}),
      );
}
```

Then dispatch:

```dart
socket.events.listen((frame) {
  switch (frame.messageType) {
    case 'TEXT':       _onText(frame); break;
    case 'IMAGE':
    case 'VIDEO':
    case 'AUDIO':
    case 'FILE':       _onAttachment(frame); break;
    case 'delete':     _onDelete(frame.deletedMessageId!); break;
    case 'EVENT':      _onOrderEvent(frame); break;
  }
});

void _onOrderEvent(ChatFrame f) {
  final ev = f.event!;
  switch (ev.eventType) {
    case 'ORDER_CREATED':       /* render request card */ break;
    case 'ORDER_COUNTER':       /* render counter card with Accept/Decline */ break;
    case 'ORDER_STATUS':        /* update header chip */ break;
    case 'ORDER_CANCEL':        /* show cancel card */ break;
    case 'ORDER_CHANGE_REQUEST':/* time/date proposal card */ break;
    case 'ORDER_HOUR_SET':      /* show new hour estimate */ break;
    case 'ORDER_WORK_START':    /* show OTP (customer) or OTP entry (provider) */ break;
    case 'ORDER_COMPLETE':      /* show feedback CTA */ break;
    case 'ORDER_UPDATED':       /* fallback: refresh order from HTTP */ break;
  }
}
```

### 7.4 Sending order chat messages

When the user types a message about the order, **send it as a plain text chat frame**; you do not need (or get) to send order event frames yourself:

```dart
socket.sendText('Sounds good, see you Wednesday.');
```

When the user takes an order action (accept, counter, cancel, etc.), call the **HTTP REST endpoint**. The backend will broadcast the corresponding `EVENT` frame to the room, which your existing socket listener handles automatically — no extra socket call needed.

### 7.5 Reconnect strategy

```
1. On socket close, inspect closeCode:
   - 4001 / 4003  → permanent auth failure: re-run JWT refresh; if that fails,
                    redirect to login.
   - Other (1006, transient): exponential backoff 2s → 4s → 8s → 16s → 32s.
2. Before reconnecting, refresh the JWT if the current access token is older
   than ~50 days (or pre-emptively whenever HTTP returns 401).
3. After reconnecting, call GET /room/{room_pk}/message/ to fill any gap of
   missed messages since the last received timestamp.
```

---

## 8. Edge cases & gotchas

| Gotcha | Detail |
|---|---|
| **Self-chat** | If the same user owns both the customer and provider profile of the room, the consumer closes the socket. Don't ever try to open a room with yourself. |
| **`profileType` case** | The URL segment is uppercased server-side (`profileType.upper()`), but for clarity always send `CUSTOMER` or `PROVIDER` exactly. |
| **Frame size** | Max attachment size 25 MB. Larger frames are silently rejected (no error frame; the message just never appears). Validate client-side before sending `raw_file`. |
| **`raw_file` format** | Must include the `data:<mime>;base64,` prefix. The server splits on the first comma — strip the prefix at your peril. |
| **`attachments` shape on send vs receive** | Outgoing: `attachment_name` + `attachment_size` + `raw_file` (data URI). Incoming: `{ url, mime, name, size }`. Don't mix them up. |
| **`event` and `attachments` empty values** | When not applicable, both are `{}` (empty object), not `null`. Dart's null-safety: handle both cases. |
| **`is_read` is always false on arrival** | The server never sends a "read receipt" frame. If you need read tracking, update server-side via HTTP (`PATCH /notifications/`) or call your read-API of choice. |
| **Channel layer is in-memory in dev** | The default `InMemoryChannelLayer` only delivers to clients connected to the **same Python process**. Multi-process broadcasting requires Redis (`channels_redis`). Beware when testing locally with multiple daphne workers. |
| **Order created with no existing room** | `POST /order-create/` calls `ChatRoom.objects.get_or_create(...)` then immediately broadcasts. If the Flutter client hadn't opened the WS to that new room yet, the `ORDER_CREATED` event is lost over WS — re-fetch the chat history via `GET /room/{room_pk}/message/` on first open to render the event card from history. |
| **`event_type: ORDER_COMPLETEL` typo on the wire** | `SendEventType.ORDER_COMPLETE` is defined as `"ORDER_COMPLETEL"` (with a trailing L) in `find_worker_config/model_choice.py`. **The Flutter dispatcher must match `"ORDER_COMPLETEL"` not `"ORDER_COMPLETE"`.** All other event values are normal. |
| **Sender mapping** | `sender` is the role that triggered the action server-side, not the speaker of the message. Treat events as system messages, not chat bubbles. |

---

## 9. Enum Reference (WebSocket)

### `SendMessageType` (received `message_type`)
`TEXT`, `IMAGE`, `VIDEO`, `AUDIO`, `FILE`, `EVENT`. Special `delete` (from delete frames) is **not** in this enum but appears on the wire.

### `SendEventType` (received `event.event_type`)

| Wire value | Meaning |
|---|---|
| `ORDER_CREATED` | New order requested by customer |
| `ORDER_COUNTER` | Counter-offer (price) by either party |
| `ORDER_UPDATED` | Generic field change (reserved) |
| `ORDER_STATUS` | Status transition (accept, pay-confirm, cancel-accept) |
| `ORDER_CANCEL` | Cancellation requested or declined |
| `ORDER_COMPLETEL` | **(sic)** Work complete. **Note the trailing L** — see §8. |
| `ORDER_WORK_START` | Provider has started work (within 100 m of job) |
| `ORDER_HOUR_SET` | Provider proposed new estimated hours |
| `ORDER_CHANGE_REQUEST` | New time/date proposal |

### `UserDefault` (received `sender` and outgoing `profileType` URL segment)
`CUSTOMER`, `PROVIDER`.

### `OrderStatus` (received `order_object.status`)
`PENDING`, `ACCEPT`, `CONFIRM`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`, `CANCELLATION_REQUEST`, `REFUND_REQUEST`, `REFUND`.

### `OrderPaymentStatus` (received `order_object.payment_status`)
`UNPAID`, `PAID`, `DISBURSEMENT`, `CANCELLED`, `REFUND`.

### `OrderChangesRequestStatus` (received `reference_object.status`)
`ACCEPT`, `DECLINED`, `NO_RESPONSE`.

### `ChangesRequestType` (received `reference_object.changes_type`)
`TIME`, `DATE`, `TIME_AND_DATE`, `AMOUNT`, `COUNTER`, `SET_HOUR`, `CANCEL`.

### `UserRole` (received `sender_data.user`)
`USER`, `ADMIN`.

---

*End of WEBSOCKET_ORDER_DOCUMENTATION.md*
