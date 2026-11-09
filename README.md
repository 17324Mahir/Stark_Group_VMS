# Stark Group Vehicle Management System (VMS) - Monorepo

An enterprise-grade, full-stack vehicle fleet management solution for Stark Group subsidiaries, featuring a **Flutter Web** frontend (Material 3) connected to a **Spring Boot 3.4** backend secured with **Spring Security JWT Authentication**, backed by **PostgreSQL**.

---

## 🌐 Live Deployments & Test Access

* **Frontend (Netlify):** https://vms-frontend-stark.netlify.app
* **Backend API (Render):** https://vms-backend-i7bt.onrender.com
* **Test User Account:**
  * **Email:** `test@starkgroup.test`
  * **Password:** `Password123!`
  * *Note:* Logging in with this test account displays the 4 pre-seeded testcase vehicles (`STK-001`, `STK-003`, `STK-004`, `STK-005`). Any newly registered account starts with an empty fleet (`[]`) due to per-user data isolation.

---

## 🚀 Workspace Architecture

This repository is organized as a unified full-stack monorepo:

1. **Frontend (`/`)**: A Flutter Web administration application utilizing Material 3 design tokens.
   - Real authentication layer (`AuthService`) connecting to `POST /api/auth/login` and `POST /api/auth/register`.
   - **Session Storage**: In-browser session persistence across page reloads via Web `sessionStorage`.
   - Shared `VehicleApiClient` automatically attaches `Authorization: Bearer <token>` to trusted backend endpoints (`ApiConfig.baseUri`).
   - Centralized 401 handling: automatically clears invalid sessions, wipes private vehicle caches, and prompts the user to sign in again.
   - Comprehensive route guards protecting vehicle directories from unauthenticated direct URL access or browser back navigation.
2. **Backend (`/backend`)**: A Java 21 / Spring Boot 3.4 application providing:
   - **Spring Security 6.4 & OAuth2 Resource Server**: Bearer token JWT validation using HMAC-SHA256 (Nimbus JOSE).
   - Real authentication endpoints (`POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/check-email`).
   - Every Vehicle operation under `/api/vehicles/**` and `/vehicles/**` strictly requires valid JWT authentication.
   - **Dual Routing & Pagination Support**:
     - `GET /vehicles?page=0&size=10` returns Spring Page JSON (`content`, `number`, `size`, `totalElements`, `totalPages`, `last`).
     - `GET /api/vehicles` returns flat JSON array `[...]` for frontend compatibility.
   - **User Fleet Isolation**: Vehicles are scoped per authenticated user (`user_email`), ensuring new users only see vehicles they create.
   - **Keep-Alive Service**: Automated background HTTP and database ping keeping Render instances warm and avoiding cold starts.
   - Flyway database migrations (`V1`, `V2`, `V3`) with schema validation.

```
┌────────────────────────────────┐            HTTP / JSON            ┌──────────────────────────────────┐
│   Flutter Web Frontend         │ ────────────────────────────────> │   Spring Boot REST Backend       │
│   (Port 5173)                  │ <──────────────────────────────── │   (Port 8080)                    │
│   - Material 3 UI / Shell      │  - POST   /api/auth/login         │   - AuthController (Public)      │
│   - AuthService (In-Memory)    │  - GET    /api/vehicles (Bearer)  │   - VehicleController (Protected)│
│   - Route Guards               │  - POST   /api/vehicles (Bearer)  │   - SecurityConfig / JwtDecoder  │
│   - Centralized 401 Expiry     │  - PUT    /api/vehicles (Bearer)  │   - GlobalExceptionHandler       │
│   - VehicleApiClient           │  - DELETE /api/vehicles (Bearer)  │   - CorsConfig                   │
└────────────────────────────────┘                                   └─────────────────┬────────────────┘
                                                                                       │ JPA / JDBC
                                                                                       ▼
                                                                     ┌──────────────────────────────────┐
                                                                     │   PostgreSQL Database            │
                                                                     │   (Port 5432, stark_vms_db)      │
                                                                     │   - vehicles table               │
                                                                     │   - unique vehicle_number        │
                                                                     └──────────────────────────────────┘
```

---

## 🔐 Authentication & Session Specification

### 1. Security Contract (`POST /api/auth/login`)

#### Request:
```http
POST /api/auth/login HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{
  "email": "admin@starkgroup.test",
  "password": "<entered password>"
}
```

#### Successful Response (`200 OK`):
```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store, no-cache, must-revalidate, max-age=0
Pragma: no-cache

{
  "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "user": {
    "email": "admin@starkgroup.test"
  }
}
```

#### Failure Responses:
- **`400 Bad Request`**: Malformed JSON or blank/invalid fields. Returns field-level errors.
- **`401 Unauthorized`**: Incorrect email or password. Returns a generic error: `"Email or password is incorrect."` (never reveals whether an account exists, with timing attack mitigation).
- **`500 Internal Server Error`**: Unexpected server failure. Details logged safely server-side without leaking credentials or stack traces.

---

### 2. Protected Endpoints Summary

| Endpoint | Method | Security Level | Requirements / Notes |
|---|---|---|---|
| `/api/auth/login` | `POST` | **Public** | Authenticates user; returns signed JWT access token. |
| `/actuator/health` | `GET` | **Public** | Health metrics for database and application status. |
| `/**` | `OPTIONS` | **Public** | CORS preflight for permitted origins (`http://localhost:5173`). |
| `/api/vehicles` | `GET` | **Protected** | Requires `Authorization: Bearer <token>`. Returns `401` if missing/invalid. |
| `/api/vehicles/{id}` | `GET` | **Protected** | Requires `Authorization: Bearer <token>`. Returns `401` if missing/invalid. |
| `/api/vehicles` | `POST` | **Protected** | Requires `Authorization: Bearer <token>`. Returns `401` if missing/invalid. |
| `/api/vehicles/{id}` | `PUT` | **Protected** | Requires `Authorization: Bearer <token>`. Returns `401` if missing/invalid. |
| `/api/vehicles/{id}` | `DELETE` | **Protected** | Requires `Authorization: Bearer <token>`. Returns `401` if missing/invalid. |

---

### 3. Token Storage & Sign-Out Semantics

- **Strict In-Memory Storage**: In the Flutter frontend, the access token is stored strictly in memory (`AuthSession`). Tokens are **never** persisted to `localStorage`, `sessionStorage`, `SharedPreferences`, or URL query parameters.
- **Browser Reload**: Reloading the browser page resets client-side memory, automatically returning the user to the Login screen.
- **Client-Side Sign-Out**:
  - Clears in-memory token, expiration timestamp, and user profile.
  - Clears the private vehicle cache in `VehicleRepository`.
  - Redirects to `/login` and wipes navigation history.
  - **Important Stateless Semantics Note**: Client-side sign-out clears the local browser session, but does **not** revoke an already issued stateless JWT token on the server. The token remains cryptographically valid until its natural expiration (default 15 minutes) unless server-side token blacklisting is separately implemented.

---

### 4. CORS & CSRF Architecture Decisions

- **CSRF**: Intentionally disabled via `http.csrf(AbstractHttpConfigurer::disable)`. The backend uses a stateless bearer-token architecture where protected requests authenticate exclusively via custom `Authorization: Bearer <token>` headers. Because browsers do not automatically attach Bearer headers to cross-origin requests (unlike ambient cookie sessions), the application is inherently immune to cross-site request forgery (CSRF) ambient authority attacks.
- **CORS**: Configured in both `CorsConfig` and `SecurityConfig` allowing:
  - Origins: `http://localhost:5173` (configurable via `CORS_ALLOWED_ORIGINS`).
  - Methods: `GET, POST, PUT, DELETE, OPTIONS`.
  - Headers: `Content-Type, Accept, Origin, Authorization`.
  - Max Age: `3600` seconds (preflight caching).

---

## 🛠️ Getting Started & Running Locally

### 1. Prerequisites
- **Java**: JDK 21+ (OpenJDK 21 or higher)
- **Flutter SDK**: 3.x with Dart 3.x
- **PostgreSQL**: 16+ (tested on PostgreSQL 18.6)
- **Browser**: Google Chrome or any modern Chromium browser

---

### 2. Database Preparation
Create the local development database and grant permissions:

```sql
CREATE DATABASE stark_vms_db;
CREATE USER vms_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE stark_vms_db TO vms_user;

\c stark_vms_db
GRANT ALL ON SCHEMA public TO vms_user;
```

---

### 3. Generate a Password Hash Safely
To configure your course user password without placing plaintext passwords in shell history or command-line arguments:

```bash
cd backend
./gradlew hashPassword --console=plain
```
The utility prompts securely for your desired password and prints its BCrypt hash:
```
Enter password to hash: [hidden]
Generated BCrypt Hash (configure as COURSE_USER_PASSWORD_HASH):
$2a$10$Ip8nr8eQkT.vnAO0ghoc.ef41W/u.ewTzNB2Ko6Q6RT5192neH.ve
```

---

### 4. Start the Backend Server (`backend/`)
All secrets and credentials are strictly externalized via environment variables.

```bash
cd backend

# Database connectivity
export DB_URL="jdbc:postgresql://localhost:5432/stark_vms_db"
export DB_USERNAME="vms_user"
export DB_PASSWORD="your_secure_password"

# Security & JWT configuration (secret must be at least 32 characters)
export JWT_SECRET="your-strong-secret-key-that-is-at-least-32-chars-long!"
export JWT_EXPIRATION_SECONDS=900
export JWT_ISSUER="stark-vms-backend"
export JWT_AUDIENCE="stark-vms-frontend"

# Course user credentials
export COURSE_USER_EMAIL="admin@starkgroup.test"
export COURSE_USER_PASSWORD_HASH="<the BCrypt hash generated in step 3>"

# Optional CORS origin (defaults to http://localhost:5173)
# export CORS_ALLOWED_ORIGINS="http://localhost:5173"

./gradlew bootRun
```
The server starts on `http://localhost:8080`.

#### Verify Health:
```bash
curl -s http://localhost:8080/actuator/health
```

---

### 5. Start the Flutter Web Frontend
In a separate terminal, launch Flutter Web on port `5173` with compile-time base URL injection:

```bash
flutter run -d chrome \
  --web-hostname=localhost \
  --web-port=5173 \
  --dart-define=API_BASE_URL=http://localhost:8080
```

> **Why Port 5173?**
> The backend CORS configuration allows `http://localhost:5173` by default. Using `--web-port=5173` ensures cross-origin API requests from Chrome succeed without browser CORS blocks.

---

### 6. Production Web Bundle Build
To generate an optimized, tree-shaken static web build pointing to a production API:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.vms.starkgroup.test
```

- Injects the HTTPS API endpoint into compiled Dart bytecode via `String.fromEnvironment('API_BASE_URL')`.
- Strips any trailing slashes automatically.
- Generates deployable static assets in `build/web/`.
- No sensitive configuration or passwords are hardcoded in the client bundle.

---

## 📡 REST API Reference

| Method | Endpoint | Security | Description | Status Codes |
|---|---|---|---|---|
| `POST` | `/api/auth/login` | Public | Authenticates course user, returns JWT | `200 OK`, `400 Bad Request`, `401 Unauthorized` |
| `GET` | `/api/vehicles` | Protected | List all registered fleet vehicles | `200 OK`, `401 Unauthorized` |
| `GET` | `/api/vehicles/{id}` | Protected | Retrieve vehicle by numeric database ID | `200 OK`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found` |
| `POST` | `/api/vehicles` | Protected | Register a new vehicle | `201 Created`, `400 Bad Request`, `401 Unauthorized`, `409 Conflict` |
| `PUT` | `/api/vehicles/{id}` | Protected | Update all business fields of an existing vehicle | `200 OK`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found`, `409 Conflict` |
| `DELETE` | `/api/vehicles/{id}` | Protected | Delete vehicle from the fleet | `204 No Content`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found` |

---

## 🧪 Testing & Verification

### 1. Flutter Test Suite
Execute the 53 automated tests covering authentication, session state, route guards, token attachment, vehicle CRUD operations, race condition handling, inline validation errors, and responsive layouts:

```bash
flutter test
```

### 2. Flutter Static Analysis
Ensure zero lint warnings or static analysis issues:

```bash
flutter analyze
```

### 3. Backend Test Suite
Run the 66 Spring Boot unit, slice, and PostgreSQL integration tests covering JWT creation, token decoding, expiry, tampering rejection, CORS preflight, controller protection, duplicate vehicle rules, Bean validation, and direct SQL verification:

```bash
cd backend

# Focused HTTP + PostgreSQL integration test suite
./gradlew test --tests "com.starkgroup.vms.controller.VehicleApiIntegrationTest" --rerun --no-daemon

# Complete backend test suite
./gradlew test --rerun --no-daemon
```

---

## 🔍 Authenticated End-to-End Verification & SQL Audit

To manually verify the full authenticated vehicle management journey against PostgreSQL:

1. **Start PostgreSQL & Spring Boot**: Follow the local startup steps above.
2. **Authenticate & Acquire JWT**:
   ```bash
   TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"course.admin@starkgroup.com","password":"your_password"}' \
     | python3 -c "import sys, json; print(json.load(sys.stdin)['accessToken'])")
   ```
3. **Register Vehicle via API or Flutter UI**:
   ```bash
   curl -s -i -X POST http://localhost:8080/api/vehicles \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"vehicleNumber":"STK-VERIFY-01","company":"Stark Industries","type":"SUV","brand":"Tesla","model":"Model X","status":"ACTIVE"}'
   ```
4. **Audit PostgreSQL Row**:
   ```bash
   psql -U vms_user -d stark_vms_db -c "SELECT id, vehicle_number, company, brand, model, status FROM vehicles WHERE vehicle_number = 'STK-VERIFY-01';"
   ```
5. **Update Vehicle Record**:
   ```bash
   curl -s -i -X PUT http://localhost:8080/api/vehicles/<id> \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"vehicleNumber":"STK-VERIFY-01","company":"Stark Industries","type":"SUV","brand":"Tesla","model":"Model X Plaid","status":"MAINTENANCE"}'
   ```
6. **Verify Duplicate Rejection (409 Conflict)**:
   ```bash
   curl -s -i -X POST http://localhost:8080/api/vehicles \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"vehicleNumber":"STK-VERIFY-01","company":"Stark Logistics","type":"Van","brand":"Ford","model":"Transit","status":"ACTIVE"}'
   ```
   *Expected:* HTTP 409 Conflict with code `DUPLICATE_VEHICLE_NUMBER` and field error on `vehicleNumber`.
7. **Delete Vehicle & Audit Absence in SQL**:
   ```bash
   curl -s -i -X DELETE http://localhost:8080/api/vehicles/<id> \
     -H "Authorization: Bearer $TOKEN"
   psql -U vms_user -d stark_vms_db -c "SELECT COUNT(*) FROM vehicles WHERE vehicle_number = 'STK-VERIFY-01';"
   ```
   *Expected:* HTTP 204 No Content; SQL count returns `0`.

---

## 🔒 Security Guidelines & Git Hygiene

- **Externalized Secrets**: Database passwords, signing secrets (`JWT_SECRET`), and user password hashes (`COURSE_USER_PASSWORD_HASH`) are strictly externalized via environment variables and never committed to source control.
- **Git Tracking Rules**: Build outputs (`build/`, `.gradle/`, `.dart_tool/`), cache directories, and local configurations are strictly excluded via `.gitignore`.
- **Compile-Time Base URLs**: The Flutter frontend uses `--dart-define` to inject the API URL without exposing server credentials.
