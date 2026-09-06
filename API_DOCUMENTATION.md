# HomeWorkerFinder — API Documentation

> **Target audience:** AI coding assistant generating a Flutter (Dart) frontend.
> **Version:** 1.0 | **Date:** 2026-06-05
> **Backend stack:** Django 6.0 · Django REST Framework · Django Channels (ASGI/WebSocket) · SQLite/PostgreSQL

---

## Table of Contents

1. [Base URLs](#1-base-urls)
2. [Global Conventions](#2-global-conventions)
3. [Global Headers Reference](#3-global-headers-reference)
4. [Canonical Mock Data Seed](#4-canonical-mock-data-seed)
5. [Authentication](#5-authentication)
6. [Account Domain](#6-account-domain)
   - [Current User](#61-current-user)
   - [Addresses](#62-addresses)
   - [Language](#63-language)
   - [Provider Profile](#64-provider-profile)
   - [Provider Verification (KYC)](#65-provider-verification-kyc)
   - [Provider Availability](#66-provider-availability)
   - [Provider Earnings](#67-provider-earnings)
   - [Customer — Saved Helpers](#68-customer--saved-helpers)
   - [Customer — Recommended Helpers](#69-customer--recommended-helpers)
   - [Referrals & Vouchers](#610-referrals--vouchers)
   - [Customer Payment Methods](#611-customer-payment-methods)
   - [Provider Payout Methods](#612-provider-payout-methods)
   - [Reviews](#613-reviews)
   - [Activity](#614-activity)
7. [Task / Marketplace Domain](#7-task--marketplace-domain)
   - [Service Categories](#71-service-categories)
   - [Order — Customer Flow](#72-order--customer-flow)
   - [Order — Provider Flow](#73-order--provider-flow)
   - [Payment Transactions](#74-payment-transactions)
8. [Chat & Notifications (HTTP)](#8-chat--notifications-http)
   - [Chat Rooms](#81-chat-rooms)
   - [Messages](#82-messages)
   - [Notifications](#83-notifications)
9. [WebSocket Reference](#9-websocket-reference)
   - [Chat WebSocket](#91-chat-websocket)
   - [Notification WebSocket](#92-notification-websocket)
10. [Enum / Choice Reference](#10-enum--choice-reference)
11. [Order Status Lifecycle](#11-order-status-lifecycle)

---

## 1. Base URLs

| Environment | HTTP REST | WebSocket |
|---|---|---|
| Production | `https://api.yourdomain.com/api/v1` | `wss://api.yourdomain.com/ws` |
| Local dev (HTTP only) | `http://127.0.0.1:8000/api/v1` | — |
| Local dev (ASGI/WS) | `http://127.0.0.1:8001/api/v1` | `ws://127.0.0.1:8001/ws` |

All REST endpoint paths in this document are relative to the HTTP base (e.g. `POST /token/auth/` means `POST https://api.yourdomain.com/api/v1/token/auth/`).

---

## 2. Global Conventions

### 2.1 Standard Response Envelope

Every response — success or error — is wrapped in this envelope:

**Success:**
```json
{
  "status": true,
  "data": { ... }
}
```
or
```json
{
  "status": true,
  "message": "Human-readable success text"
}
```

**Paginated list:**
```json
{
  "status": true,
  "count": 42,
  "next": "https://api.yourdomain.com/api/v1/order/customer/?page=3",
  "previous": "https://api.yourdomain.com/api/v1/order/customer/?page=1",
  "results": [ ... ]
}
```

**Error:**
```json
{
  "status": false,
  "message": "Human-readable error string"
}
```
or (field-level validation errors):
```json
{
  "status": false,
  "message": {
    "email": ["This field is required."],
    "password": ["This field may not be blank."]
  }
}
```

### 2.2 Data Type Notes for Flutter/Dart

| Backend type | JSON representation | Dart parsing |
|---|---|---|
| `DecimalField` | `"120.00"` (string) | `double.parse(json['amount'])` |
| `DateField` | `"2026-06-10"` (ISO date) | `DateTime.parse(json['working_date'])` |
| `TimeField` | `"09:00:00"` (HH:MM:SS) | Parse manually |
| `DateTimeField` | `"2026-06-05T10:30:00Z"` (ISO 8601 UTC) | `DateTime.parse(json['created_at'])` |
| `ImageField`/`FileField` | `"https://api.yourdomain.com/media/..."` (absolute URL) | Direct URL string |
| `BooleanField` | `true` / `false` | Dart `bool` |

> **Critical:** All `DecimalField` values come back as **strings**, not JSON numbers. Always use `double.parse()`.

### 2.3 Date Formats — Two Different Formats in Use

| Context | Format | Example |
|---|---|---|
| `DateField` responses & order bodies | ISO `YYYY-MM-DD` | `"2026-06-10"` |
| Availability URL params & `dob` field | `DD-MM-YYYY` | `"10-06-2026"` |

> The availability endpoints (`date-slot-list/{date}`, `slot-exception/{date}`, `special-date/{date}`) and the KYC `dob` field use **DD-MM-YYYY**. All other dates use ISO format.

### 2.4 File Uploads

Endpoints that accept files use `multipart/form-data`. Do **not** set `Content-Type: application/json` for these — let Flutter's `http.MultipartRequest` set the boundary automatically.

Endpoints that accept files:
- `PATCH /current-user/` (`photo`)
- `POST /create-helper-profile/` (`logo`)
- `POST /provider-verification/` (`document`)
- `POST /order-create/` (`attachments`)

### 2.5 JWT Token Lifecycle

- **Access token lifetime:** 60 days
- **Refresh token lifetime:** 60 days
- **Rotation:** Enabled — each `/token/refresh/` call returns a new refresh token and blacklists the old one
- **Storage recommendation (Flutter):** `flutter_secure_storage`
- **On 401:** Attempt one silent refresh, then redirect to login if refresh also fails

---

## 3. Global Headers Reference

| Header | When required | Value | Notes |
|---|---|---|---|
| `Authorization` | All authenticated endpoints | `Bearer eyJ...` | JWT access token |
| `Content-Type` | POST/PATCH with JSON body | `application/json` | Omit for multipart uploads |
| `profile-type` | Endpoints protected by `ForCustomerProfile` or `ForProviderProfile` permission | `customer` or `provider` | **Must be lowercase.** Send on every authenticated request to avoid permission errors |
| `X-FRONTEND-KEY` | If server has `IsValidFrontendRequest` guard enabled | `<app-secret>` | Rarely required; check with backend team |

### Which endpoints need `profile-type`?

| Endpoint group | Required value |
|---|---|
| Customer order actions (`/order/customer/...`) | `customer` |
| Provider order actions (`/order/provider/...`) | `provider` |
| Customer-only account endpoints (save-helper, payment-methods) | `customer` |
| Provider-only account endpoints (payout-methods, helper-profile) | `provider` |
| Reviews (giving feedback) | whichever role is acting |
| Shared read endpoints (`/current-user/`, `/category/`) | Not required |

---

## 4. Canonical Mock Data Seed

All JSON examples in this document use the following consistent identifiers:

| Entity | ID / Value |
|---|---|
| **Alice** (Customer) | `id: 1`, `email: "alice@example.com"`, `first_name: "Alice"`, `last_name: "Chen"` |
| **Bob** (Provider) | `id: 2`, `email: "bob@example.com"`, `first_name: "Bob"`, `last_name: "Martinez"` |
| `CustomerProfile` (Alice) | `id: 1` |
| `ServiceProviderProfile` (Bob) | `id: 1`, `company_name: "Bob's Home Services"` |
| `ServiceCategory` | `id: 3`, `title: "Cleaning"` |
| `Address` (Alice) | `id: 1`, `city: "Toronto"`, `lat: 43.6532`, `lng: -79.3832` |
| `Address` (Bob — office) | `id: 2`, `city: "Toronto"`, `lat: 43.6551`, `lng: -79.3800` |
| `Order` | `id: 42`, `amount: "120.00"`, `status: "CONFIRM"`, `working_date: "2026-06-10"` |
| `ChatRoom` | `uuid: "a1b2c3d4e5f67890a1b2c3d4e5f67890"` |
| `PaymentTransaction` | `payment_id: "PAY-XK7F2M"` |
| Alice's JWT | `"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.alice_payload.sig"` |
| Bob's JWT | `"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.bob_payload.sig"` |

---

## 5. Authentication

All auth endpoints are **unauthenticated** (no `Authorization` header required).

---

### POST `/token/auth/`
**Purpose:** Password-based login. Returns JWT tokens.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `email` | string | Yes | Registered email address |
| `password` | string | Yes | User's password |

**Request Example:**
```json
{
  "email": "alice@example.com",
  "password": "SecureP@ss123"
}
```

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.alice_payload.sig",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.alice_refresh.sig",
    "default_profile": "CUSTOMER"
  }
}
```

> `default_profile` is `null` if the user has never switched profiles. It can be `"CUSTOMER"` or `"PROVIDER"`.

**Error Response (400):**
```json
{
  "status": false,
  "message": {
    "detail": "No active account found with the given credentials"
  }
}
```

---

### POST `/token/otp/request/`
**Purpose:** Request a 6-digit OTP sent via email or SMS for login. OTP expires in 5 minutes.

**Request Body** (provide at least one):
| Field | Type | Required | Notes |
|---|---|---|---|
| `email` | string | One of | Send OTP to this email |
| `phone` | string | One of | Send OTP to this phone |

**Request Example:**
```json
{ "email": "alice@example.com" }
```

**Success Response (200):**
```json
{
  "status": true,
  "message": "OTP sent",
  "data": "alice@example.com"
}
```

---

### POST `/token/otp/verify/`
**Purpose:** Verify OTP and receive JWT tokens.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `otp` | string | Yes | 6-digit code |
| `email` | string | One of | Same email used in request |
| `phone` | string | One of | Same phone used in request |

**Request Example:**
```json
{
  "otp": "847291",
  "email": "alice@example.com"
}
```

**Success Response (200):** Same shape as `POST /token/auth/`.

**Error Response (400):**
```json
{
  "status": false,
  "message": "Invalid or expired OTP."
}
```

---

### POST `/token/verify/`
**Purpose:** Check if a JWT token is still valid.

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `token` | string | Yes |

**Request Example:**
```json
{ "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.alice_payload.sig" }
```

**Success Response (200):**
```json
{
  "status": false,
  "message": "Token Valid!"
}
```

> **Flutter note:** This endpoint returns `status: false` even on success — this is a quirk of the underlying simplejwt view wrapper. Treat HTTP 200 as valid, HTTP 401 as expired.

**Error Response (401):**
```json
{
  "status": false,
  "message": { "detail": "Token is invalid or expired", "code": "token_not_valid" }
}
```

---

### POST `/token/refresh/`
**Purpose:** Exchange a refresh token for a new access token. The old refresh token is blacklisted.

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `refresh` | string | Yes |

**Request Example:**
```json
{ "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.alice_refresh.sig" }
```

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.alice_new_payload.sig"
  }
}
```

**Error Response (401):**
```json
{
  "status": false,
  "message": { "detail": "Token is blacklisted", "code": "token_not_valid" }
}
```

---

### POST `/auth/signup/`
**Purpose:** Register a new user. Sends an OTP to the provided email for verification. A `CustomerProfile` and a new-user discount voucher are created automatically.

**Request Body (JSON):**
| Field | Type | Required | Notes |
|---|---|---|---|
| `first_name` | string | Yes | |
| `last_name` | string | Yes | |
| `email` | string | Yes | Must be unique |
| `phone` | string | Yes | Must be unique |
| `password` | string | Yes | |
| `address` | object | Yes | See sub-fields below |
| `address.address_line` | string | Yes | Street address |
| `address.city` | string | Yes | City name |
| `address.lat` | float | Yes | Latitude |
| `address.lng` | float | Yes | Longitude |
| `referral_code` | string | No | Existing user's referral code |

**Request Example:**
```json
{
  "first_name": "Alice",
  "last_name": "Chen",
  "email": "alice@example.com",
  "phone": "+14161234567",
  "password": "SecureP@ss123",
  "address": {
    "address_line": "100 King St W",
    "city": "Toronto",
    "lat": 43.6532,
    "lng": -79.3832
  },
  "referral_code": "BOB2024"
}
```

**Success Response (200):**
```json
{
  "status": true,
  "message": "OTP send to your email address.",
  "data": "alice@example.com"
}
```

**Error Response (400):**
```json
{
  "status": false,
  "message": {
    "email": ["user with this email already exists."]
  }
}
```

---

### POST `/auth/signup/verify/`
**Purpose:** Confirm the signup OTP. Returns JWT tokens on success.

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `otp` | string | Yes |
| `email` | string | Yes |

**Request Example:**
```json
{
  "otp": "392841",
  "email": "alice@example.com"
}
```

**Success Response (200):** Same shape as `POST /token/auth/`.

---

### POST `/auth/signup/resend/`
**Purpose:** Resend the signup OTP.

**Request Body:**
```json
{ "email": "alice@example.com" }
```

**Success Response (200):**
```json
{ "status": true, "message": "OTP Resend!" }
```

---

### POST `/auth/token/google/`
**Purpose:** Login or auto-register via Google OAuth. If the email doesn't exist, a new user is created from the Google profile.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `access_token` | string | Yes | Google OAuth access token (from Google Sign-In SDK) |

**Request Example:**
```json
{ "access_token": "ya29.A0ARrdaM-GivenByGoogleSDK..." }
```

**Success Response (200):** Same shape as `POST /token/auth/`.

---

### POST `/auth/token/apple/`
**Purpose:** Login or auto-register via Apple Sign In.

**Request Body:**
```json
{ "access_token": "eyJraWQiOiJBcHBsZVRva2VuS2V5..." }
```

**Success Response (200):** Same shape as `POST /token/auth/`.

---

### POST `/auth/password/change/`
**Auth:** Required

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `old_password` | string | Yes |
| `new_password` | string | Yes |
| `confirm_new_password` | string | Yes |

**Request Example:**
```json
{
  "old_password": "SecureP@ss123",
  "new_password": "NewSecureP@ss456",
  "confirm_new_password": "NewSecureP@ss456"
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Password changed successfully" }
```

---

### POST `/auth/password/reset/`
**Purpose:** Request an OTP to reset password (unauthenticated).

**Request Body:**
```json
{ "email": "alice@example.com" }
```

**Success Response (200):**
```json
{
  "status": true,
  "message": "OTP send for reset your password.",
  "send_to": "a***@example.com"
}
```

---

### POST `/auth/password/reset-confirm/`
**Purpose:** Provide the OTP and new password to complete the reset.

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `email` | string | One of |
| `phone` | string | One of |
| `otp` | string | Yes |
| `new_password` | string | Yes |

**Request Example:**
```json
{
  "email": "alice@example.com",
  "otp": "192837",
  "new_password": "NewSecureP@ss456"
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Password Reset Sucessfully." }
```

---

## 6. Account Domain

### 6.1 Current User

#### GET `/current-user/`
**Auth:** Required

**Query Parameters:**
| Param | Type | Required | Notes |
|---|---|---|---|
| `user_mode` | string | No | `CUSTOMER` or `PROVIDER`. Triggers auto-creation of the profile if it doesn't exist yet. |

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "first_name": "Alice",
    "last_name": "Chen",
    "username": "alice_chen",
    "email": "alice@example.com",
    "phone": "+14161234567",
    "photo": "https://api.yourdomain.com/media/users/alice.jpg",
    "language": "en",
    "default_profile": "CUSTOMER",
    "address": {
      "id": 1,
      "address_line": "100 King St W",
      "city": "Toronto",
      "lat": "43.6532",
      "lng": "-79.3832",
      "is_default": true
    }
  }
}
```

#### PATCH `/current-user/`
**Auth:** Required
**Content-Type:** `multipart/form-data` (if uploading photo), otherwise `application/json`

**Request Body (all fields optional):**
| Field | Type | Notes |
|---|---|---|
| `first_name` | string | |
| `last_name` | string | |
| `username` | string | Must be unique |
| `email` | string | Must be unique |
| `phone` | string | Must be unique |
| `photo` | file | JPEG/PNG, any size |
| `language` | string | `"en"` or `"zh"` |

**Success Response (200):** Same shape as GET.

---

### 6.2 Addresses

#### GET `/user/address/`
**Auth:** Required

**Success Response (200):**
```json
{
  "status": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "address_line": "100 King St W",
      "city": "Toronto",
      "lat": "43.6532",
      "lng": "-79.3832",
      "is_default": true
    },
    {
      "id": 3,
      "address_line": "50 Queen St E",
      "city": "Toronto",
      "lat": "43.6510",
      "lng": "-79.3750",
      "is_default": false
    }
  ]
}
```

#### POST `/user/address/`
**Auth:** Required

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `address_line` | string | Yes |
| `city` | string | Yes |
| `lat` | float | Yes |
| `lng` | float | Yes |

**Request Example:**
```json
{
  "address_line": "50 Queen St E",
  "city": "Toronto",
  "lat": 43.6510,
  "lng": -79.3750
}
```

**Success Response (201):**
```json
{
  "status": true,
  "data": {
    "id": 3,
    "address_line": "50 Queen St E",
    "city": "Toronto",
    "lat": "43.6510",
    "lng": "-79.3750",
    "is_default": false
  }
}
```

#### PATCH `/user/address/{id}/`
**Auth:** Required
**Request Body:** Same fields as POST (all optional).

#### DELETE `/user/address/{id}/`
**Auth:** Required
**Success Response (200):** `{ "status": true, "message": "Address deleted." }`

---

### 6.3 Language

#### GET `/user/language/`
**Success Response (200):**
```json
{ "status": true, "language": "en" }
```

#### POST `/user/language/`
**Request Body:**
```json
{ "language": "zh" }
```
**Success Response (200):**
```json
{ "status": true, "language": "zh" }
```

---

### 6.4 Provider Profile

#### POST `/create-helper-profile/`
**Auth:** Required
**Content-Type:** `multipart/form-data`

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `service_category` | array of int | Yes | Category IDs (e.g. `[3, 5]`) |
| `company_name` | string | Yes | |
| `hourly_rate` | decimal string | Yes | e.g. `"45.00"` |
| `min_booking_hours` | decimal string | Yes | e.g. `"2.00"` |
| `logo` | file | No | Company/profile logo image |
| `details` | string | No | Bio / description |

**Request Example (multipart fields):**
```
service_category=3&service_category=5
company_name=Bob's Home Services
hourly_rate=45.00
min_booking_hours=2.00
details=Professional home cleaning with 5+ years experience.
```

**Success Response (201):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "company_name": "Bob's Home Services",
    "hourly_rate": "45.00",
    "min_booking_hours": "2.00",
    "details": "Professional home cleaning with 5+ years experience.",
    "logo": "https://api.yourdomain.com/media/providers/bobs-logo.jpg",
    "service_category": [
      { "id": 3, "title": "Cleaning" },
      { "id": 5, "title": "Plumbing" }
    ],
    "rating": "0.00",
    "total_jobs": 0,
    "is_verified": false,
    "office_location": null
  }
}
```

**Error (already exists):**
```json
{ "status": false, "message": "You already have a helper profile." }
```

#### GET `/helper-profile/`
**Auth:** Required
**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "company_name": "Bob's Home Services",
    "hourly_rate": "45.00",
    "min_booking_hours": "2.00",
    "details": "Professional home cleaning.",
    "logo": "https://api.yourdomain.com/media/providers/bobs-logo.jpg",
    "service_category": [{ "id": 3, "title": "Cleaning" }],
    "rating": "4.80",
    "total_jobs": 23,
    "is_verified": true,
    "office_location": {
      "id": 2,
      "address_line": "200 Bay St",
      "city": "Toronto",
      "lat": "43.6551",
      "lng": "-79.3800"
    },
    "portfolio": [],
    "reviews_and_ratings": [
      {
        "id": 7,
        "rating": 5,
        "review": "Excellent work!",
        "send_by": "CUSTOMER",
        "created_at": "2026-05-20T14:00:00Z"
      }
    ]
  }
}
```

#### PATCH `/helper-profile/`
**Auth:** Required
**Content-Type:** `multipart/form-data` (if updating logo), else `application/json`
**Request Body:** Same fields as create (all optional).

#### DELETE `/helper-profile/`
**Auth:** Required
**Success Response (200):** `{ "status": true, "message": "Helper profile deleted." }`

#### POST `/provider-address-update/`
**Auth:** Required
**Purpose:** Set which of the provider's saved addresses is used as their office/work location.

**Request Body:**
```json
{ "address_object_id": 2 }
```

**Success Response (200):**
```json
{ "status": true, "message": "Office location updated successfully." }
```

---

### 6.5 Provider Verification (KYC)

#### GET `/provider-verification/`
**Auth:** Required
**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "document_type": "PASSPORT",
    "full_name": "Bob Martinez",
    "document_id": "A12345678",
    "dob": "15-03-1990",
    "is_verified": true,
    "status": "APPROVED",
    "document": "https://api.yourdomain.com/media/kyc/bob-passport.jpg"
  }
}
```

#### POST `/provider-verification/`
**Auth:** Required
**Content-Type:** `multipart/form-data`

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `document_type` | string | Yes | `"PASSPORT"`, `"NID"`, or `"DRIVING_LICENSE"` |
| `document` | file | Yes | Image of the identity document |
| `full_name` | string | Yes | Full legal name |
| `document_id` | string | Yes | Document number |
| `dob` | string | Yes | **DD-MM-YYYY format** e.g. `"15-03-1990"` |

**Success Response (200):**
```json
{
  "status": true,
  "kyc_result": {
    "verified": false,
    "status": "REVIEW"
  }
}
```

> Possible `status` values: `"APPROVED"`, `"REVIEW"`, `"FAILED"`, `"REJECTED"`

---

### 6.6 Provider Availability

All date URL parameters use **DD-MM-YYYY** format.

#### GET `/user/helper-weekly-availability/`
**Auth:** Required
**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "day": "Mon",
      "day_status": 1,
      "start_time": "09:00 AM",
      "end_time": "05:00 PM",
      "slot_duration_minutes": 60
    }
  ]
}
```

#### POST `/user/helper-weekly-availability/set-weekly-availability/`
**Auth:** Required
**Purpose:** Bulk-set availability for multiple days at once.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `days` | array of string | Yes | Day abbreviations from `WeekDay` enum |
| `start_time` | string | Yes | `"09:00 AM"` format |
| `end_time` | string | Yes | `"05:00 PM"` format |
| `slot_duration_minutes` | int | No | Default: `60` |

**Request Example:**
```json
{
  "days": ["Mon", "Tue", "Wed", "Thu", "Fri"],
  "start_time": "09:00 AM",
  "end_time": "05:00 PM",
  "slot_duration_minutes": 60
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Weekly availability set successfully." }
```

#### POST `/user/helper-weekly-availability/update-availability/{day}/`
**Auth:** Required
**URL Param:** `day` — one of `Sun`, `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `start_time` | string | No | `"09:00 AM"` |
| `end_time` | string | No | `"05:00 PM"` |
| `day_status` | int | No | `1` = AVAILABLE, `0` = OFF |
| `slot_duration_minutes` | int | No | |

**Request Example:**
```json
{
  "start_time": "10:00 AM",
  "end_time": "04:00 PM",
  "day_status": 1,
  "slot_duration_minutes": 60
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Availability updated." }
```

#### GET `/user/helper-weekly-availability/date-slot-list/{date}/`
**Auth:** Required
**URL Param:** `date` in **DD-MM-YYYY** (e.g. `10-06-2026`)

**Success Response (200):**
```json
{
  "status": true,
  "count": 8,
  "data": {
    "date": "2026-06-10",
    "day": "Wed",
    "slots": [
      {
        "slot": "09:00 AM - 10:00 AM",
        "start_time": "09:00 AM",
        "end_time": "10:00 AM",
        "status": "available"
      },
      {
        "slot": "10:00 AM - 11:00 AM",
        "start_time": "10:00 AM",
        "end_time": "11:00 AM",
        "status": "booked"
      },
      {
        "slot": "11:00 AM - 12:00 PM",
        "start_time": "11:00 AM",
        "end_time": "12:00 PM",
        "status": "freezed"
      }
    ]
  }
}
```

> Slot `status` values: `"available"`, `"booked"`, `"freezed"`, `"unavailable"`

#### POST `/user/helper-weekly-availability/slot-exception/{date}/`
**Auth:** Required
**URL Param:** `date` in **DD-MM-YYYY**
**Purpose:** Block or unblock a specific time slot on a specific date (overrides weekly schedule).

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `start_time` | string | Yes |
| `end_time` | string | Yes |
| `is_available` | bool | Yes |

**Request Example:**
```json
{
  "start_time": "02:00 PM",
  "end_time": "03:00 PM",
  "is_available": false
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Slot exception added successfully." }
```

#### POST `/user/helper-weekly-availability/special-date/{date}/`
**Auth:** Required
**URL Param:** `date` in **DD-MM-YYYY**
**Purpose:** Mark an entire day with custom hours (e.g. a holiday or extended shift).

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `start_time` | string | Yes | |
| `end_time` | string | Yes | |
| `description` | string | No | e.g. `"Public Holiday"` |
| `date_status` | string | Yes | `"AVAILABLE"` or `"UNAVAILABLE"` |

**Request Example:**
```json
{
  "start_time": "09:00 AM",
  "end_time": "12:00 PM",
  "description": "Canada Day — half day only",
  "date_status": "AVAILABLE"
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Special date availability set." }
```

---

### 6.7 Provider Earnings

#### GET `/provider/next-job-orders/`
**Auth:** Required
**Purpose:** Returns the next 3 upcoming confirmed orders, sorted by `working_date`.
**Filters applied internally:** `status` in `[ACCEPT, CONFIRM, IN_PROGRESS]`, `payment_status = PAID`

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 42,
      "title": "Home Cleaning",
      "working_date": "2026-06-10",
      "working_start_time": "09:00:00",
      "working_hour": 3,
      "amount": "120.00",
      "status": "CONFIRM",
      "customer": {
        "id": 1,
        "first_name": "Alice",
        "last_name": "Chen",
        "photo": "https://api.yourdomain.com/media/users/alice.jpg"
      }
    }
  ]
}
```

#### GET `/provider/earnings-overview/`
**Auth:** Required

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "total_payout": "5000.00",
    "upcoming_payout": "500.00",
    "available_payout": "200.00",
    "payout_processing": "300.00"
  },
  "reports": {
    "last_7_total": "150.00",
    "last_30_total": "450.00"
  }
}
```

#### GET `/provider/earnings-transactions/`
**Auth:** Required
**Purpose:** Paginated earnings history grouped by date.

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "05-06-2026": [
      {
        "id": 1,
        "payment_id": "PAY-XK7F2M",
        "amount": "108.00",
        "type": "DEBIT",
        "action": "SEND_PROVIDER",
        "order": {
          "id": 42,
          "title": "Home Cleaning"
        },
        "created_at": "2026-06-05T14:30:00Z"
      }
    ],
    "01-06-2026": [ ... ]
  }
}
```

---

### 6.8 Customer — Saved Helpers

#### GET `/user/customer/save-helper/`
**Auth:** Required | **profile-type:** `customer`

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "helper": {
        "id": 1,
        "company_name": "Bob's Home Services",
        "hourly_rate": "45.00",
        "rating": "4.80",
        "is_verified": true,
        "logo": "https://api.yourdomain.com/media/providers/bobs-logo.jpg"
      }
    }
  ]
}
```

#### POST `/user/customer/save-helper/add-helper/{helper_id}/`
**Auth:** Required | **profile-type:** `customer`
**URL Param:** `helper_id` — ServiceProviderProfile ID

**Success Response (200):**
```json
{ "status": true, "message": "Bob Martinez Add in your saved helpers..." }
```

#### DELETE `/user/customer/save-helper/{id}/remove-helper/`
**Auth:** Required | **profile-type:** `customer`
**URL Param:** `id` — SavedHelper record ID (not the helper's profile ID)

**Success Response (200):**
```json
{ "status": true, "message": "Helper removed from saved helpers." }
```

---

### 6.9 Customer — Recommended Helpers

#### GET `/user/recommended-helpers/`
**Auth:** Required

**Query Parameters:**
| Param | Type | Required | Notes |
|---|---|---|---|
| `current_location` | string | No | `"lat,lng"` e.g. `"43.6532,-79.3832"` |

**Logic:** Returns up to 3 verified providers within 5 km of the given coordinates.

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "company_name": "Bob's Home Services",
      "hourly_rate": "45.00",
      "rating": "4.80",
      "is_verified": true,
      "distance_km": "1.2",
      "logo": "https://api.yourdomain.com/media/providers/bobs-logo.jpg",
      "service_category": [{ "id": 3, "title": "Cleaning" }]
    }
  ]
}
```

---

### 6.10 Referrals & Vouchers

#### GET `/my-referral-code/`
**Auth:** Required

**Success Response (200):**
```json
{ "status": true, "referral_code": "ALICE2024" }
```

#### GET `/user/my-referrals/`
**Auth:** Required

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "referrer": 1,
      "referred": 5,
      "code": "ALICE2024",
      "reward_given": false,
      "created_at": "2026-05-01T09:00:00Z"
    }
  ]
}
```

#### GET `/user/my-vouchers/`
**Auth:** Required

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "code": "NEWUSER10",
      "discount_type": "PERCENTAGE",
      "value": "10.00",
      "minimum_value": "50.00",
      "upto_value": "20.00",
      "is_used": false,
      "expiry_date": "2026-07-05T23:59:59Z"
    }
  ]
}
```

#### POST `/user/my-vouchers/add-voucher/`
**Auth:** Required

**Request Body:**
```json
{ "voucher_code": "PROMO2026" }
```

**Success Response (200):**
```json
{ "status": true, "message": "PROMO2026 Add in your account..." }
```

**Error (invalid code):**
```json
{ "status": false, "message": "Invalid voucher code." }
```

#### POST `/vouchers/apply/`
**Auth:** Required
**Purpose:** Preview the discount calculation before creating an order.

**Request Body:**
| Field | Type | Required |
|---|---|---|
| `code` | string | Yes |
| `order_amount` | decimal string | Yes |

**Request Example:**
```json
{
  "code": "NEWUSER10",
  "order_amount": "120.00"
}
```

**Success Response (200):**
```json
{
  "status": true,
  "voucher_id": 1,
  "voucher_code": "NEWUSER10",
  "original_amount": "120.00",
  "discount": "12.00",
  "final_amount": "108.00"
}
```

---

### 6.11 Customer Payment Methods

#### GET `/user/customer/payment-methods/`
**Auth:** Required | **profile-type:** `customer`

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "provider": "stripe",
      "method_type": "CARD",
      "brand": "VISA",
      "last4": "4242",
      "is_default": true,
      "payment_token": "pm_1234..."
    }
  ]
}
```

#### POST `/user/customer/payment-methods/`
**Auth:** Required | **profile-type:** `customer`

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `provider` | string | Yes | `"stripe"` or `"razorpay"` |
| `method_type` | string | Yes | `"CARD"`, `"BANK"`, or `"WALLET"` |
| `payment_token` | string | Yes | Token from payment SDK |
| `brand` | string | No | e.g. `"VISA"`, `"MASTERCARD"` |
| `last4` | string | No | Last 4 digits of card |
| `method_data` | object | No | Arbitrary extra data |
| `is_default` | bool | No | |

**Request Example:**
```json
{
  "provider": "stripe",
  "method_type": "CARD",
  "payment_token": "pm_1OziSi2eZvKYlo2CYtzaHpbV",
  "brand": "VISA",
  "last4": "4242",
  "is_default": true
}
```

**Success Response (201):** Same shape as a single item in GET list.

#### PATCH `/user/customer/payment-methods/{id}/`
**Auth:** Required | **profile-type:** `customer`
**Request Body:** Same fields as POST (all optional).

#### DELETE `/user/customer/payment-methods/{id}/`
**Auth:** Required | **profile-type:** `customer`

#### POST `/user/customer/payment-methods/{id}/set-default/`
**Auth:** Required | **profile-type:** `customer`

**Success Response (200):**
```json
{ "status": true, "message": "Default updated" }
```

---

### 6.12 Provider Payout Methods

#### GET `/user/provider/payout-methods/`
**Auth:** Required | **profile-type:** `provider`

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "method_type": "BANK",
      "account_holder_name": "Bob Martinez",
      "bank_name": "RBC",
      "account_number": "****7890",
      "ifsc_code": "RBC0001234",
      "is_verified": false,
      "is_default": true
    }
  ]
}
```

> `account_number` is encrypted at rest; only the last 4 digits are returned.

#### POST `/user/provider/payout-methods/`
**Auth:** Required | **profile-type:** `provider`

**Request Body (BANK):**
| Field | Type | Required | Notes |
|---|---|---|---|
| `method_type` | string | Yes | `"BANK"` or `"WALLET"` |
| `account_holder_name` | string | No | |
| `bank_name` | string | No | |
| `account_number` | string | Yes (BANK) | Stored encrypted |
| `ifsc_code` | string | Yes (BANK) | Routing/IFSC/transit code |
| `is_default` | bool | No | |

**Request Example:**
```json
{
  "method_type": "BANK",
  "account_holder_name": "Bob Martinez",
  "bank_name": "RBC",
  "account_number": "1234567890",
  "ifsc_code": "RBC0001234",
  "is_default": true
}
```

**Success Response (201):** Same shape as GET item (account_number masked).

#### PATCH `/user/provider/payout-methods/{id}/`
**Auth:** Required | **profile-type:** `provider`

#### DELETE `/user/provider/payout-methods/{id}/`
**Auth:** Required | **profile-type:** `provider`

#### POST `/user/provider/payout-methods/{id}/set-default/`
**Success Response (200):**
```json
{ "status": true, "message": "Default updated" }
```

---

### 6.13 Reviews

#### GET `/user/reviews/customer/`
**Auth:** Required
**Purpose:** Reviews that Alice (as customer) has written about providers.

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 7,
      "order": 42,
      "provider": {
        "id": 1,
        "company_name": "Bob's Home Services"
      },
      "rating": 5,
      "review": "Excellent work!",
      "send_by": "CUSTOMER",
      "is_approved": true,
      "created_at": "2026-06-11T10:00:00Z"
    }
  ]
}
```

#### GET `/user/reviews/provider/`
**Auth:** Required
**Purpose:** Reviews that Bob (as provider) has written about customers.

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 8,
      "order": 42,
      "customer": {
        "id": 1,
        "first_name": "Alice",
        "last_name": "Chen"
      },
      "rating": 4,
      "review": "Great customer, clear instructions.",
      "send_by": "PROVIDER",
      "is_approved": true,
      "created_at": "2026-06-11T11:00:00Z"
    }
  ]
}
```

---

### 6.14 Activity

#### GET `/activity/`
**Auth:** Required

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "my_activity": {
      "active_orders": 2,
      "completed_orders": 10,
      "total_spent": "1500.00",
      "avg_rating": "4.50"
    },
    "recent_activities": [
      {
        "action": "ORDER_CREATED",
        "message": "Order #42 created",
        "status": true,
        "created_at": "2026-06-05T10:30:00Z"
      }
    ]
  }
}
```

---

## 7. Task / Marketplace Domain

### 7.1 Service Categories

#### GET `/category/`
**Auth:** Not required

**Success Response (200):**
```json
{
  "status": true,
  "data": [
    {
      "id": 3,
      "title": "Cleaning",
      "description": "Home and office cleaning services",
      "icon": "https://api.yourdomain.com/media/categories/cleaning.png",
      "is_active": true,
      "subcategory": [
        {
          "id": 8,
          "title": "Deep Cleaning",
          "description": "Full deep clean",
          "icon": "https://api.yourdomain.com/media/categories/deep-clean.png",
          "is_active": true
        }
      ]
    }
  ]
}
```

#### GET `/category/{id}/`
Returns a single category with the same shape as one item above.

#### GET `/sub-category/`
Returns flat list of subcategories.

---

### 7.2 Order — Customer Flow

#### POST `/order-create/`
**Auth:** Required
**Content-Type:** `multipart/form-data` (if sending attachments), else `application/json`

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `provider_id` | int | Yes | ServiceProviderProfile ID |
| `title` | string | Yes | Short job title |
| `description` | string | Yes | Detailed description |
| `area` | string | Yes | Neighbourhood / area name |
| `lat` | decimal | Yes | Job location latitude |
| `lng` | decimal | Yes | Job location longitude |
| `amount` | decimal string | Yes | Proposed amount |
| `working_date` | date | Yes | `"YYYY-MM-DD"` |
| `working_start_time` | string | Yes | `"09:00 AM"` **or** `"09:00"` (both accepted) |
| `working_hour` | int | Yes | Estimated hours |
| `category` | int | Yes | ServiceCategory ID |
| `attachments` | array of file | No | Reference photos/documents |

**Request Example:**
```json
{
  "provider_id": 1,
  "title": "Home Cleaning",
  "description": "Deep clean of a 3-bedroom apartment including kitchen and 2 bathrooms.",
  "area": "Downtown Toronto",
  "lat": "43.6532",
  "lng": "-79.3832",
  "amount": "120.00",
  "working_date": "2026-06-10",
  "working_start_time": "09:00 AM",
  "working_hour": 3,
  "category": 3
}
```

**Success Response (201):**
```json
{
  "status": true,
  "message": "Custom offer created!",
  "data": {
    "id": 42,
    "title": "Home Cleaning",
    "description": "Deep clean of a 3-bedroom apartment...",
    "area": "Downtown Toronto",
    "lat": "43.6532",
    "lng": "-79.3832",
    "amount": "120.00",
    "status": "PENDING",
    "payment_status": "UNPAID",
    "working_date": "2026-06-10",
    "working_start_time": "09:00:00",
    "working_hour": 3,
    "category": { "id": 3, "title": "Cleaning" },
    "customer": { "id": 1 },
    "provider": { "id": 1, "company_name": "Bob's Home Services" },
    "attachments": [],
    "accepted_at": null,
    "started_at": null,
    "completed_at": null,
    "created_at": "2026-06-05T10:30:00Z",
    "updated_at": "2026-06-05T10:30:00Z"
  }
}
```

> **Side effect:** A `ChatRoom` is created between Alice and Bob (or the existing one is reused). An `ORDER_CREATED` WebSocket event is broadcast to `chat_{roomUUID}`.

---

#### GET `/order/customer/`
**Auth:** Required | **profile-type:** `customer`

**Query Parameters:**
| Param | Type | Notes |
|---|---|---|
| `status` | string | `confirm`, `complete`, `cancel` — filters by status group |
| `q` | string | Full-text search on title/description |
| `category_id` | int | Filter by category |
| `budget` | decimal | Filter by max amount |
| `working_date` | date | `YYYY-MM-DD` |
| `created_at` | date | Filter by creation date |
| `page` | int | Pagination page number |

**Success Response (200):** Paginated list of order objects (same shape as order-create response `data`).

---

#### GET `/order/customer/{id}/`
**Auth:** Required | **profile-type:** `customer`

**Success Response (200):**
```json
{
  "status": true,
  "data": {
    "id": 42,
    "title": "Home Cleaning",
    "description": "Deep clean of a 3-bedroom apartment...",
    "area": "Downtown Toronto",
    "lat": "43.6532",
    "lng": "-79.3832",
    "amount": "120.00",
    "status": "CONFIRM",
    "payment_status": "PAID",
    "working_date": "2026-06-10",
    "working_start_time": "09:00:00",
    "working_hour": 3,
    "end_time": "12:00:00",
    "category": { "id": 3, "title": "Cleaning" },
    "customer": { "id": 1, "first_name": "Alice", "last_name": "Chen" },
    "provider": {
      "id": 1,
      "company_name": "Bob's Home Services",
      "hourly_rate": "45.00",
      "rating": "4.80"
    },
    "attachments": [
      { "id": 1, "file": "https://api.yourdomain.com/media/order/file/ref.jpg" }
    ],
    "changes_requests": [],
    "accepted_at": "2026-06-05T11:00:00Z",
    "started_at": null,
    "completed_at": null,
    "created_at": "2026-06-05T10:30:00Z",
    "updated_at": "2026-06-05T11:05:00Z"
  }
}
```

---

#### GET `/order/customer/{id}/accept/`
**Auth:** Required | **profile-type:** `customer`
**Purpose:** Customer accepts the order (PENDING → ACCEPT). Awaiting payment.
**Required state:** `status == PENDING`

**Success Response (200):**
```json
{ "status": true, "message": "Order accept and awaiting for payment." }
```

**Error (wrong state):**
```json
{ "status": false, "message": "Order is not in PENDING state." }
```

---

#### GET `/order/customer/{id}/pay-and-confirm/`
**Auth:** Required | **profile-type:** `customer`
**Purpose:** Pay for and confirm the order (ACCEPT+UNPAID → CONFIRM+PAID).
**Required state:** `status == ACCEPT` and `payment_status == UNPAID`
**Side effects:** Creates a `PaymentTransaction` (type=`CREDIT`, action=`ORDER_PAYMENT`); updates the provider's slot to `BOOKED`.

**Success Response (200):**
```json
{ "status": true, "message": "Order pay and confirm!" }
```

**Error (already paid):**
```json
{ "status": false, "message": "Duplicate payment detected." }
```

---

#### POST `/order/customer/{id}/counter/`
**Auth:** Required | **profile-type:** `customer`
**Purpose:** Propose a different price.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `budget` | decimal string | Yes | Proposed new amount |
| `message` | string | No | Optional note |

**Request Example:**
```json
{
  "budget": "100.00",
  "message": "I can offer this — budget is tight this month."
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Counter Offer Sent" }
```

**Error (pending counter exists):**
```json
{ "status": false, "message": "A counter offer is already pending." }
```

> **Side effect:** Sends an `ORDER_COUNTER` WebSocket event to the chat room.

---

#### POST `/order/customer/{id}/propose-new-time/`
**Auth:** Required | **profile-type:** `customer`
**Purpose:** Dual-mode endpoint for proposing a new date/time OR responding to the provider's proposal.

**Mode 1 — Create a proposal:**
```json
{
  "action": "create",
  "date": "2026-06-11",
  "time": "10:00 AM",
  "message": "Can we shift by one day?"
}
```

**Mode 2 — Respond to a proposal:**
```json
{
  "action": "update",
  "request_id": 7,
  "status": "ACCEPT"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `action` | string | Yes | `"create"` or `"update"` |
| `date` | date | No (create) | `"YYYY-MM-DD"` — omit to keep original date |
| `time` | string | No (create) | `"10:00 AM"` or `"10:00"` |
| `message` | string | No | |
| `request_id` | int | Yes (update) | `OrderChangesRequest` ID |
| `status` | string | Yes (update) | `"ACCEPT"` or `"DECLINED"` |

**Success Response (200):**
```json
{ "status": true, "message": "Time proposal sent." }
```

---

#### POST `/order/customer/{id}/cancel/`
**Auth:** Required | **profile-type:** `customer`

**Request Body:**
```json
{ "message": "Need to reschedule — family emergency." }
```

**Behavior:**
- If `status` in `[PENDING, ACCEPT]` and `payment_status == UNPAID` → **CANCELLED** immediately
- If `status` in `[CONFIRM, IN_PROGRESS]` and `payment_status == PAID` → Creates `CANCELLATION_REQUEST` (provider must accept/decline)

**Success Response (200):**
```json
{ "status": true, "message": "Order cancelled." }
```
or
```json
{ "status": true, "message": "Cancellation request sent to provider." }
```

---

#### POST `/order/customer/{id}/cancel-accept/`
**Auth:** Required | **profile-type:** `customer`
**Purpose:** Customer responds to a provider-initiated cancellation request.

**Request Body:**
```json
{
  "changes_request_id": 5,
  "action": "ACCEPT"
}
```

| Field | Type | Required |
|---|---|---|
| `changes_request_id` | int | Yes |
| `action` | string | Yes — `"ACCEPT"` or `"DECLINED"` |

**If ACCEPT:** Creates `OrderRefundRequest`, transitions order → `REFUND_REQUEST`.

**Success Response (200):**
```json
{ "status": true, "message": "Cancellation accepted. Refund initiated." }
```

---

#### POST `/order/customer/{id}/give-feedback/`
**Auth:** Required | **profile-type:** `customer`
**Required state:** `status == COMPLETED`

**Request Body:**
```json
{
  "rating": 5,
  "review": "Bob was punctual, thorough, and very professional!"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `rating` | int | Yes | 1–5 |
| `review` | string | Yes | |

**Success Response (200):**
```json
{ "status": true, "message": "Thanks for your feedback!" }
```

**Error (duplicate):**
```json
{ "status": false, "message": "You have already submitted feedback for this order." }
```

---

### 7.3 Order — Provider Flow

Most provider order endpoints mirror the customer ones. Only differences and provider-specific endpoints are documented in full below.

#### GET `/order/provider/`
**Auth:** Required | **profile-type:** `provider`
**Query params:** Same as customer — `status`, `q`, `category_id`, `budget`, `working_date`, `created_at`, `page`

#### GET `/order/provider/{id}/`
**Auth:** Required | **profile-type:** `provider`
**Response:** Same shape as `GET /order/customer/{id}/`

#### GET `/order/provider/{id}/accept/`
**Auth:** Required | **profile-type:** `provider`
**Required state:** `status == PENDING`
**Success Response (200):**
```json
{ "status": true, "message": "Order accept and awaiting for payment." }
```

#### POST `/order/provider/{id}/set-work-hour/`
**Auth:** Required | **profile-type:** `provider`
**Purpose:** Provider requests to adjust the estimated work hours. Validated against slot availability.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `set_hour` | int | Yes | New estimated hours |
| `message` | string | No | |

**Request Example:**
```json
{
  "set_hour": 4,
  "message": "The apartment is larger than expected — 4 hours needed."
}
```

**Success Response (200):**
```json
{ "status": true, "message": "4 Hour Set for complete the work!" }
```

**Error (slot conflict):**
```json
{ "status": false, "message": "Slot is not available for the additional hours." }
```

> **Side effect:** Sends `ORDER_HOUR_SET` WebSocket event to the chat room.

#### POST `/order/provider/{id}/counter/`
Same as customer counter. See [POST `/order/customer/{id}/counter/`](#post-ordercustomeridcounter).

#### POST `/order/provider/{id}/propose-new-time/`
Same dual-mode as customer. See [POST `/order/customer/{id}/propose-new-time/`](#post-ordercustomeridpropose-new-time).

#### POST `/order/provider/{id}/cancel/`
Same logic as customer cancel.

#### POST `/order/provider/{id}/cancel-accept/`
**Auth:** Required | **profile-type:** `provider`
**Purpose:** Provider responds to a customer-initiated cancellation request.
Same body as customer version.

---

#### POST `/order/provider/{id}/start-work/`
**Auth:** Required | **profile-type:** `provider`
**Required state:** `status == CONFIRM`

**GPS Validation:** The provider's submitted coordinates must be within **100 meters** of the order's `lat`/`lng`. If not, the request is rejected.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `start` | bool | Yes | Must be `true` |
| `address` | string | No | Current address text |
| `lat` | float | Yes | Provider's current GPS latitude |
| `lng` | float | Yes | Provider's current GPS longitude |

**Request Example:**
```json
{
  "start": true,
  "address": "100 King St W, Toronto",
  "lat": 43.6533,
  "lng": -79.3831
}
```

**Success Response (200):**
```json
{ "status": true, "message": "Work Started!" }
```

**Error (too far):**
```json
{ "status": false, "message": "You are not within 100m of the job location." }
```

> **Side effects:** 
> - Order transitions CONFIRM → IN_PROGRESS
> - `confirmation_OTP` (6-digit) is generated and stored on the order — the customer must share this OTP with the provider to complete
> - Sends `ORDER_WORK_START` WebSocket event

---

#### POST `/order/provider/{id}/complete/`
**Auth:** Required | **profile-type:** `provider`
**Required state:** `status == IN_PROGRESS`
**Purpose:** Provider enters the OTP shared by the customer to mark the job complete.

**Request Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `otp` | string | Yes | 6-digit OTP that the customer received when work started |

**Request Example:**
```json
{ "otp": "847291" }
```

**Success Response (200):**
```json
{ "status": true, "message": "Work Complete!" }
```

**Error (wrong OTP):**
```json
{ "status": false, "message": "Invalid OTP." }
```

> **Side effects:** Order → COMPLETED; provider slot exception deactivated; triggers payment disbursement flow.

#### POST `/order/provider/{id}/give-feedback/`
Same as customer give-feedback with `send_by = "PROVIDER"`.

---

### 7.4 Payment Transactions

#### GET `/payment-transaction/`
**Auth:** Required

**Headers:**
| Header | Value | Notes |
|---|---|---|
| `profile-type` | `customer` or `provider` | Optional. Filters transactions by profile. |

**Success Response (200):**
```json
{
  "status": true,
  "count": 3,
  "results": [
    {
      "id": 1,
      "payment_id": "PAY-XK7F2M",
      "transaction_id": "TXN-STRIPE-001",
      "amount": "120.00",
      "currency": "CA$",
      "type": "CREDIT",
      "action": "ORDER_PAYMENT",
      "reference": "Order #42 payment",
      "profile": "CUSTOMER",
      "payment_information": {
        "gateway": "stripe",
        "charge_id": "ch_1234"
      },
      "created_at": "2026-06-05T11:05:00Z"
    }
  ]
}
```

---

## 8. Chat & Notifications (HTTP)

### 8.1 Chat Rooms

#### POST `/room/start-chat/`
**Auth:** Required
**Purpose:** Create a chat room between the current user and a provider. If a room already exists for this customer-provider pair, the existing room is returned.

**Request Body:**
```json
{ "provider_id": 1 }
```

**Success Response (200 or 201):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "uuid": "a1b2c3d4e5f67890a1b2c3d4e5f67890",
    "customer": {
      "id": 1,
      "first_name": "Alice",
      "last_name": "Chen",
      "photo": "https://api.yourdomain.com/media/users/alice.jpg"
    },
    "provider": {
      "id": 1,
      "company_name": "Bob's Home Services",
      "logo": "https://api.yourdomain.com/media/providers/bobs-logo.jpg"
    },
    "created_at": "2026-06-05T10:30:00Z"
  }
}
```

#### GET `/room/`
**Auth:** Required
Returns all chat rooms the user is a participant in.

#### GET `/room/customer/`
**Auth:** Required
Returns only rooms where the user is the customer.

#### GET `/room/provider/`
**Auth:** Required
Returns only rooms where the user is the provider.

**Room list item shape:**
```json
{
  "id": 1,
  "uuid": "a1b2c3d4e5f67890a1b2c3d4e5f67890",
  "customer": { "id": 1, "first_name": "Alice", "last_name": "Chen", "photo": "..." },
  "provider": { "id": 1, "company_name": "Bob's Home Services", "logo": "..." },
  "created_at": "2026-06-05T10:30:00Z"
}
```

---

### 8.2 Messages

#### GET `/room/{room_pk}/message/`
**Auth:** Required
**URL Param:** `room_pk` — ChatRoom integer ID (not UUID)

Returns paginated message history, newest first.

**Success Response (200):**
```json
{
  "status": true,
  "count": 15,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 101,
      "message_type": "TEXT",
      "content": "Are you available tomorrow?",
      "timestamp": "2026-06-05T10:30:00Z",
      "is_read": true,
      "sender": "CUSTOMER",
      "attachments": null,
      "event": null,
      "sender_data": {
        "first_name": "Alice",
        "last_name": "Chen",
        "photo": "https://api.yourdomain.com/media/users/alice.jpg",
        "user": "USER"
      }
    },
    {
      "id": 102,
      "message_type": "EVENT",
      "content": "",
      "timestamp": "2026-06-05T10:31:00Z",
      "is_read": true,
      "sender": "CUSTOMER",
      "attachments": null,
      "event": {
        "id": 1,
        "event_type": "ORDER_CREATED",
        "order_object": {
          "id": 42,
          "title": "Home Cleaning",
          "amount": "120.00",
          "status": "PENDING",
          "working_date": "2026-06-10",
          "working_start_time": "09:00:00"
        },
        "reference_object": null
      },
      "sender_data": { ... }
    }
  ]
}
```

---

### 8.3 Notifications

#### GET `/notifications/`
**Auth:** Required

**Success Response (200):**
```json
{
  "status": true,
  "count": 3,
  "results": [
    {
      "id": 1,
      "action": "ORDER_STATUS",
      "message": "Your order #42 has been confirmed.",
      "is_read": false,
      "entity_type": "order",
      "entity_id": 42,
      "created_at": "2026-06-05T11:05:00Z"
    }
  ]
}
```

#### PATCH `/notifications/`
**Auth:** Required
**Purpose:** Mark all notifications as read.

**Request Body:**
```json
{ "is_read": true }
```

**Success Response (200):**
```json
{ "status": true, "message": "All notifications marked as read." }
```

#### GET `/notifications/{id}/`
Returns a single notification.

#### DELETE `/notifications/{id}/`
**Success Response (200):**
```json
{ "status": true, "message": "Notification deleted." }
```

---

## 9. WebSocket Reference

### 9.1 Chat WebSocket

#### Connection

```
URL:  wss://api.yourdomain.com/ws/chat/{roomId}/{profileType}/
```

| URL segment | Type | Values | Notes |
|---|---|---|---|
| `roomId` | string | 32-char hex UUID | From `ChatRoom.uuid` (e.g. `a1b2c3d4e5f67890a1b2c3d4e5f67890`) |
| `profileType` | string | `CUSTOMER` or `PROVIDER` | Case-insensitive on the server |

**Authentication — pick one method:**
- HTTP header: `Authorization: Bearer <access_token>`
- Query param: `?token=<access_token>`

> **Flutter recommendation:** Use the `?token=` query param. Most Flutter WebSocket packages (`web_socket_channel`) cannot set custom HTTP upgrade headers.

**Connection rejection scenarios (server closes with code 4001 or 4003):**
- No valid JWT → anonymous user rejected
- `profileType` not in `["CUSTOMER", "PROVIDER"]` → rejected
- `ChatRoom` with given UUID not found → rejected
- Authenticated user is not the customer or provider of the room → rejected
- Customer and provider are the same user → rejected

---

#### Send — Text Message

```json
{
  "type": "text",
  "message": "Are you available tomorrow?"
}
```

| Field | Type | Required |
|---|---|---|
| `type` | string | Yes — `"text"` |
| `message` | string | Yes — non-empty |

---

#### Send — File / Image / Video / Audio

```json
{
  "type": "image",
  "message": "Before photo of the bathroom",
  "attachment_name": "before_photo.jpg",
  "attachment_size": 204800,
  "raw_file": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD..."
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `type` | string | Yes | `"image"`, `"video"`, `"audio"`, or `"file"` |
| `message` | string | No | Optional caption |
| `attachment_name` | string | Yes | Filename with extension |
| `attachment_size` | int | Yes | File size in bytes |
| `raw_file` | string | Yes | **Full data URI** including MIME prefix: `"data:image/jpeg;base64,..."` |

> Max file size: **25 MB** (25 × 1024 × 1024 bytes). Server rejects larger files.

---

#### Send — Delete Message

```json
{
  "type": "delete",
  "message_id": 101,
  "roomId": "a1b2c3d4e5f67890a1b2c3d4e5f67890"
}
```

| Field | Type | Required |
|---|---|---|
| `type` | string | Yes — `"delete"` |
| `message_id` | int | Yes |
| `roomId` | string | Yes — the UUID |

---

#### Receive — Text Message

All messages received have `type: "chat_message"` as the outer discriminator. Branch on `message_type`.

```json
{
  "type": "chat_message",
  "id": 101,
  "message_type": "TEXT",
  "content": "Are you available tomorrow?",
  "timestamp": "2026-06-05T10:30:00Z",
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

---

#### Receive — File/Image/Video/Audio Message

Same as text, with `attachments` populated:

```json
{
  "type": "chat_message",
  "id": 103,
  "message_type": "IMAGE",
  "content": "Before photo of the bathroom",
  "timestamp": "2026-06-05T10:32:00Z",
  "is_read": false,
  "attachments": {
    "url": "https://api.yourdomain.com/media/chat/before_photo.jpg",
    "mime": "image/jpeg",
    "name": "before_photo.jpg",
    "size": 204800
  },
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

---

#### Receive — Delete Event

```json
{
  "type": "chat_message",
  "message_type": "delete",
  "message_id": 101
}
```

---

#### Receive — Order Event Message (`message_type: "EVENT"`)

Automatically sent by the server when order actions occur (create, counter, start, complete, etc.). The Flutter client should render these as non-chat system messages in the conversation.

```json
{
  "type": "chat_message",
  "id": 102,
  "message_type": "EVENT",
  "content": "",
  "timestamp": "2026-06-05T10:31:00Z",
  "is_read": false,
  "attachments": {},
  "event": {
    "id": 1,
    "event_type": "ORDER_CREATED",
    "order_object": {
      "id": 42,
      "title": "Home Cleaning",
      "amount": "120.00",
      "status": "PENDING",
      "working_date": "2026-06-10",
      "working_start_time": "09:00:00"
    },
    "reference_object": null
  },
  "sender": "CUSTOMER",
  "sender_data": {
    "first_name": "Alice",
    "last_name": "Chen",
    "photo": "https://api.yourdomain.com/media/users/alice.jpg",
    "user": "USER"
  }
}
```

**`event.event_type` values and their triggers:**

| `event_type` | Triggered by |
|---|---|
| `ORDER_CREATED` | `POST /order-create/` |
| `ORDER_COUNTER` | `POST /order/{role}/{id}/counter/` |
| `ORDER_UPDATED` | General order field changes |
| `ORDER_STATUS` | Status transitions |
| `ORDER_CANCEL` | Cancellation request |
| `ORDER_COMPLETE` | `POST /order/provider/{id}/complete/` |
| `ORDER_WORK_START` | `POST /order/provider/{id}/start-work/` |
| `ORDER_HOUR_SET` | `POST /order/provider/{id}/set-work-hour/` |
| `ORDER_CHANGE_REQUEST` | `POST /order/{role}/{id}/propose-new-time/` |

**`event.reference_object`** is populated for events tied to an `OrderChangesRequest` (counter, time proposals). It contains the changes request data when non-null.

---

#### Disconnect & Error Handling (Flutter)

```
// Recommended Flutter reconnect logic:
- On close code 4001/4003 (auth/permission): do not reconnect, redirect to login/error screen
- On abnormal closure (1006, network error): wait 2s, then attempt reconnect with exponential backoff (max 30s)
- On reconnect: re-fetch missed messages via GET /room/{id}/message/ before re-subscribing
```

---

### 9.2 Notification WebSocket

#### Connection

```
URL:  wss://api.yourdomain.com/ws/notification/
```

**Auth:** Same as Chat WS — `Authorization: Bearer <token>` header or `?token=<token>` query param.

On connect, the server automatically subscribes the user to **three** channel groups simultaneously:
1. `notify_{user_id}` — personal direct notifications
2. `role_{UserRole}` — role-based (e.g. `role_USER`, `role_ADMIN`)
3. `notify_all` — platform-wide announcements

No client-side subscription message is needed.

---

#### Receive — Notification Event

```json
{
  "notify_text": "New order request from Alice Chen",
  "entity_type": "order",
  "entity": 42,
  "is_read": false
}
```

> **Important:** Flutter receives **only** this inner object. The `type: "notify"` wrapper used for channel routing is consumed server-side and is never visible to the client.

| Field | Type | Notes |
|---|---|---|
| `notify_text` | string | Human-readable description of the event |
| `entity_type` | string | Model name in lowercase, e.g. `"order"`, `"ticket"` |
| `entity` | int | ID of the related object |
| `is_read` | bool | Always `false` on arrival |

**Flutter handling:** On receipt, optionally fetch the updated notification list via `GET /notifications/` to get the full Notification model with `action`, `message`, and timestamps.

---

## 10. Enum / Choice Reference

Use these exact string values in requests and when matching response fields.

### User & Profile

| Enum | Values |
|---|---|
| `UserRole` | `USER`, `ADMIN` |
| `UserDefault` (profile-type header) | `CUSTOMER`, `PROVIDER` |
| `UserLanguage` | `en`, `zh` |
| `UserStatus` | `ACTIVE`, `DEACTIVE`, `REJECTED` |
| `HelperStatus` | `GOOD`, `WARNING`, `DANGER`, `TEMPORARY_SUSPENSED`, `PERMANENT_SUSPENSED` |

### OTP & Verification

| Enum | Values |
|---|---|
| `OTPType` | `LOGIN`, `SIGNUP`, `VERIFY`, `RESET_PASSWORD` |
| `DocumentType` | `PASSPORT`, `NID`, `DRIVING_LICENSE` |
| `DocumentStatus` | `APPROVED`, `REVIEW`, `FAILED`, `REJECTED` |

### Order

| Enum | Values |
|---|---|
| `OrderStatus` | `PENDING`, `ACCEPT`, `CONFIRM`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`, `CANCELLATION_REQUEST`, `REFUND_REQUEST`, `REFUND` |
| `OrderPaymentStatus` | `UNPAID`, `PAID`, `DISBURSEMENT`, `CANCELLED`, `REFUND` |
| `OrderChangesRequestStatus` | `ACCEPT`, `DECLINED`, `NO_RESPONSE` |
| `ChangesRequestType` | `TIME`, `DATE`, `TIME_AND_DATE`, `AMOUNT`, `COUNTER`, `SET_HOUR`, `CANCEL` |
| `ReviewRatingChoice` | `1`, `2`, `3`, `4`, `5` (integers) |
| `RefundStatus` | `PENDING`, `APPROVED`, `REJECTED`, `COMPLETED` |

### Payment

| Enum | Values |
|---|---|
| `PaymentTransactionType` | `CREDIT`, `HOLD`, `DEBIT` |
| `PaymentAction` | `ORDER_PAYMENT`, `PAYMENT_HOLD`, `SEND_PROVIDER`, `REFUND_CUSTOMER` |
| `PaymentCurrencyType` | `CN¥`, `CA$` |
| `PaymentMethodType` (customer) | `CARD`, `BANK`, `WALLET` |
| `PayoutMethodType` (provider) | `BANK`, `WALLET` |

### Voucher

| Enum | Values |
|---|---|
| `VOUCHER_DISCOUNT_TYPE` | `PERCENTAGE`, `FLAT` |
| `VOUCHER_TYPE` | `FOR_USER`, `FOR_GLOBAL` |

### Availability

| Enum | Values |
|---|---|
| `WeekDay` | `Sun`, `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat` |
| `DayStatus` | `AVAILABLE`, `OFF`, `UNAVAILABLE` |

### Chat & Notifications

| Enum | Values |
|---|---|
| `SendMessageType` | `TEXT`, `IMAGE`, `VIDEO`, `AUDIO`, `FILE`, `EVENT` |
| `SendEventType` | `ORDER_CREATED`, `ORDER_COUNTER`, `ORDER_UPDATED`, `ORDER_STATUS`, `ORDER_CANCEL`, `ORDER_COMPLETE`, `ORDER_WORK_START`, `ORDER_HOUR_SET`, `ORDER_CHANGE_REQUEST` |

---

## 11. Order Status Lifecycle

### State Machine Diagram

```
                        ┌───────────────────────────────────┐
                        │            PENDING                │  ◄── Created by customer
                        └───────────────────────────────────┘
                               │                  │
                         (accept)            (cancel while UNPAID)
                               │                  │
                               ▼                  ▼
                        ┌─────────┐         ┌──────────┐
                        │ ACCEPT  │         │CANCELLED │
                        └─────────┘         └──────────┘
                               │
                     (pay-and-confirm)
                               │
                               ▼
                        ┌─────────┐
                        │ CONFIRM │  ◄── Slot locked as BOOKED
                        └─────────┘
                          │       │
               (start-work)     (cancel while PAID)
                          │       │
                          ▼       ▼
                   ┌────────┐  ┌──────────────────────┐
                   │IN_PROG-│  │ CANCELLATION_REQUEST  │
                   │ RESS   │  └──────────────────────┘
                   └────────┘           │
                          │    (cancel-accept → ACCEPT)
                     (complete)         │
                        with OTP        ▼
                          │    ┌─────────────────┐
                          ▼    │ REFUND_REQUEST   │
                   ┌──────────┐└─────────────────┘
                   │COMPLETED │         │
                   └──────────┘  (admin processes)
                                        │
                                        ▼
                                  ┌────────┐
                                  │ REFUND │
                                  └────────┘
```

### State Transition Table

| From | To | Triggered by | Endpoint |
|---|---|---|---|
| `PENDING` | `ACCEPT` | Customer or Provider accepts | `GET /order/{role}/{id}/accept/` |
| `PENDING` | `CANCELLED` | Customer cancels (unpaid) | `POST /order/customer/{id}/cancel/` |
| `ACCEPT` | `CONFIRM` | Customer pays | `GET /order/customer/{id}/pay-and-confirm/` |
| `ACCEPT` | `CANCELLED` | Either party cancels (unpaid) | `POST /order/{role}/{id}/cancel/` |
| `CONFIRM` | `IN_PROGRESS` | Provider starts work (within 100m) | `POST /order/provider/{id}/start-work/` |
| `CONFIRM` | `CANCELLATION_REQUEST` | Either party requests cancellation (paid) | `POST /order/{role}/{id}/cancel/` |
| `IN_PROGRESS` | `COMPLETED` | Provider submits OTP from customer | `POST /order/provider/{id}/complete/` |
| `IN_PROGRESS` | `CANCELLATION_REQUEST` | Either party requests cancellation | `POST /order/{role}/{id}/cancel/` |
| `CANCELLATION_REQUEST` | `REFUND_REQUEST` | Other party accepts cancellation | `POST /order/{role}/{id}/cancel-accept/` with `action: "ACCEPT"` |
| `REFUND_REQUEST` | `REFUND` | Admin processes the refund | Admin action |

### Payment Status Transitions

| `payment_status` | When set |
|---|---|
| `UNPAID` | Initial state |
| `PAID` | After `pay-and-confirm` |
| `DISBURSEMENT` | After provider is paid out |
| `REFUND` | After refund is processed |

---

*End of API_DOCUMENTATION.md*
