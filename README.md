# Stark Group Vehicle Management System (VMS)

An enterprise-grade, desktop-first admin portal for managing fleet operations across Stark Group subsidiaries, featuring a **Flutter Web** frontend connected via REST to a **Spring Boot 3.4** backend backed by **PostgreSQL**.

---

## 🚀 Architecture Overview

This monorepo workspace contains a decoupled full-stack architecture:

1. **Frontend (`/`)**: A Flutter Web administration application utilizing Material 3 design tokens. It communicates with the backend over HTTP using `VehicleApiClient` with compile-time configuration (`--dart-define=API_BASE_URL=...`), typed domain exceptions, and reactive repository caching.
2. **Backend (`/backend`)**: A Java 21 / Spring Boot 3.4 application providing:
   - Full REST CRUD API for the Vehicle domain under `/api/vehicles`.
   - Enterprise data validation with normalized unique Vehicle Numbers (case-insensitive, whitespace-trimmed).
   - Standardized `ErrorResponse` contract (`400`, `404`, `409`, `405`, `415`, `500`).
   - Granular CORS configuration for Flutter Web origins (`http://localhost:5173`).
   - Explicit Flyway schema migration (`V1__create_vehicles_table.sql`) with Hibernate schema validation (`ddl-auto=validate`).
   - Actuator health metrics for the PostgreSQL connection.

```
┌────────────────────────────────┐            HTTP / JSON            ┌──────────────────────────────────┐
│   Flutter Web Frontend         │ ────────────────────────────────> │   Spring Boot REST Backend       │
│   (Port 5173)                  │ <──────────────────────────────── │   (Port 8080)                    │
│   - Material 3 UI / Shell      │  - GET    /api/vehicles           │   - VehicleController            │
│   - VehicleRepository          │  - POST   /api/vehicles           │   - VehicleService               │
│   - VehicleApiClient           │  - GET    /api/vehicles/{id}      │   - GlobalExceptionHandler       │
│   - Compile-time API_BASE_URL  │  - PUT    /api/vehicles/{id}      │   - CorsConfig                   │
│   - Simulated Auth Session     │  - DELETE /api/vehicles/{id}      │                                  │
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

## 🔑 Demo Access & Environment Modes

- **Local Web Application URL**: `http://localhost:5173`
- **Simulated Authentication**:
  - **Demo Email**: `demo@starkgroup.test`
  - **Demo Password**: `Demo@12345`
  - An **"Autofill"** shortcut is available on the Login screen for testing.
- **Data Persistence Distinction**:
  > **Important:** While the authentication flow is currently simulated client-side for demonstration and UI review purposes without backend session tokens, **all vehicle fleet operations (list, register, edit, delete, status changes) are live, fully persistent, and synchronized with the PostgreSQL database** via the Spring Boot REST API.

---

## 🛠️ Getting Started & Running Locally

### 1. Prerequisites
- **Java Development Kit**: JDK 21+ (OpenJDK 21 or higher)
- **Flutter SDK**: 3.x with Dart 3.x
- **PostgreSQL**: 16+ (tested on PostgreSQL 18.6)
- **Browser**: Google Chrome or any modern Chromium browser

---

### 2. Database Preparation
Create the local development database and grant permissions to an application user:

```sql
-- Connect via psql as administrator:
CREATE DATABASE stark_vms_db;
CREATE USER vms_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE stark_vms_db TO vms_user;

-- Grant schema permissions:
\c stark_vms_db
GRANT ALL ON SCHEMA public TO vms_user;
```

---

### 3. Start the Backend Server (`backend/`)
The datasource properties are strictly externalized via environment variables.

```bash
cd backend

# Configure environment variables
export DB_URL="jdbc:postgresql://localhost:5432/stark_vms_db"
export DB_USERNAME="vms_user"
export DB_PASSWORD="your_secure_password"

# Optional: configure allowed CORS origin (defaults to http://localhost:5173)
# export CORS_ALLOWED_ORIGINS="http://localhost:5173"

# Run Spring Boot server
./gradlew bootRun
```
The backend initializes Flyway migrations and starts on `http://localhost:8080`.

#### Verify Backend Health & Database Connectivity:
```bash
curl -s http://localhost:8080/actuator/health
```
Expected response: `{"status":"UP","components":{"db":{"status":"UP",...}}}`

---

### 4. Start the Flutter Web Frontend
In a separate terminal, launch the Flutter Web client on port `5173` with compile-time base URL injection:

```bash
flutter run -d chrome \
  --web-hostname=localhost \
  --web-port=5173 \
  --dart-define=API_BASE_URL=http://localhost:8080
```

> **Why Port 5173?**
> The backend CORS configuration allows `http://localhost:5173` by default. Using `--web-port=5173` ensures cross-origin API requests from Chrome succeed without browser CORS blocks.

---

### 5. Production Web Bundle Build
To generate an optimized, tree-shaken static web build pointing to a production API:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.vms.starkgroup.test
```

- Injects the HTTPS API endpoint into compiled Dart bytecode via `String.fromEnvironment('API_BASE_URL')`.
- Strips any trailing slashes automatically.
- Generates deployable static assets in `build/web/`.
- No sensitive configuration or passwords are hardcoded in the client bundle.

---

## 🌐 Cross-Origin Resource Sharing (CORS) Configuration

Browser security blocks cross-origin XMLHttpRequests/fetch requests from the Flutter Web origin (`http://localhost:5173`) to the Spring Boot origin (`http://localhost:8080`) unless explicitly permitted by CORS headers.

The backend configures CORS in `backend/src/main/java/com/starkgroup/vms/config/CorsConfig.java`:
- **Allowed Origins**: `http://localhost:5173` by default (comma-separated list configurable via `app.cors.allowed-origins` or `CORS_ALLOWED_ORIGINS` environment variable).
- **Allowed Methods**: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`.
- **Allowed Headers**: `*` (including `Content-Type`, `Accept`, `Origin`).
- **Max Age**: 3600 seconds (preflight caching).

---

## 📡 REST API Reference

The backend exposes the Vehicle domain at `/api/vehicles`:

| Method | Endpoint | Description | Status Codes |
|---|---|---|---|
| `GET` | `/api/vehicles` | List all registered fleet vehicles | `200 OK` |
| `GET` | `/api/vehicles/{id}` | Retrieve a vehicle by numeric database ID | `200 OK`, `400 Bad Request`, `404 Not Found` |
| `POST` | `/api/vehicles` | Register a new vehicle | `201 Created`, `400 Bad Request`, `409 Conflict` |
| `PUT` | `/api/vehicles/{id}` | Update all business fields of an existing vehicle | `200 OK`, `400 Bad Request`, `404 Not Found`, `409 Conflict` |
| `DELETE` | `/api/vehicles/{id}` | Delete a vehicle from the fleet | `204 No Content`, `400 Bad Request`, `404 Not Found` |

### Field Constraints & Validation

| Field | Type | Required | Constraints |
|---|---|---|---|
| `id` | `Long` (Backend) / `int` (Frontend) | Generated | Positive database sequence ID |
| `vehicleNumber` | `String` | Yes | Non-blank, max 64 chars, unique (normalized uppercase & trimmed) |
| `company` | `String` | Yes | Non-blank, max 120 chars |
| `type` | `String` | Yes | Non-blank, max 60 chars (e.g., Sedan, SUV, Truck, Van, Electric) |
| `brand` | `String` | Yes | Non-blank, max 80 chars |
| `model` | `String` | Yes | Non-blank, max 120 chars |
| `status` | `String` | Yes | Enum: `ACTIVE`, `INACTIVE`, `MAINTENANCE` |

### Error Payload Contract
All API errors return a uniform JSON schema:

```json
{
  "timestamp": "2026-11-03T04:30:00Z",
  "status": 409,
  "code": "DUPLICATE_VEHICLE_NUMBER",
  "message": "A vehicle with this Vehicle Number already exists.",
  "path": "/api/vehicles",
  "fieldErrors": []
}
```

- `DUPLICATE_VEHICLE_NUMBER` (`409 Conflict`): Handled by the Flutter UI to display an inline field-level validation error under the Vehicle Number input while preserving all user-entered form data.
- `VALIDATION_FAILED` (`400 Bad Request`): Returns an array of `fieldErrors` with field-specific guidance.
- `VEHICLE_NOT_FOUND` (`404 Not Found`): Handled gracefully with recovery options.

---

## ✨ Features & User Experience

### 1. 🗂️ Application Shell & Demo Notice
- Desktop navy sidebar (`#0F172A`) with Stark Group branding, persistent Vehicles navigation item, and user profile footer.
- Top application bar with user status, "Sign out" action, and an explicit **"Database Connected"** badge denoting active database synchronization.

### 2. 🚙 Vehicles Directory (`/vehicles`)
- **Real-Time Data**: Automatically loads fleet records from `/api/vehicles` on startup.
- **Refresh & Recovery**: Header refresh button with animated spinner; error banner with a "Retry" button when network errors occur.
- **Search & Filters**: Instant client-side search across Vehicle Number, Company, Brand, and Model; Company and Status filters; "Clear filters" button.
- **Sorting & Pagination**: Toggleable sorting by Vehicle Number or Company; 10 records per page with item counter summary.
- **Responsive Layout**: Material 3 `Table` with bold identifiers and status badges on desktop; responsive card layout on mobile viewports.

### 3. 📝 Register & Edit Vehicle Forms (`/vehicles/new` & `/vehicles/edit`)
- Two-column responsive layout partitioned into Vehicle Identity, Vehicle Details, and Operational State.
- Pre-populated dropdowns dynamically incorporating existing company and chassis type values.
- **Conflict Prevention**: Backend 409 duplicate errors are intercepted and highlighted directly on the Vehicle Number input without losing other unsaved form fields.
- **Guard against Accidental Data Loss**: Confirmation dialog prevents leaving the page with unsaved modifications.

### 4. 🗑️ Delete Flow
- Modal confirmation dialog displaying the vehicle number and subsidiary before executing `DELETE /api/vehicles/{id}`.
- Re-fetches the fleet list and presents confirmation snackbar notifications.

---

## 🎨 Visual Direction & Design Tokens

- **Brand Navy**: `#0F172A` (Sidebar & brand accents)
- **Action Blue**: `#2563EB` (Primary buttons & active selected states)
- **Background**: `#F8FAFC` (Light neutral)
- **Surfaces**: `#FFFFFF` (White cards & tables with subtle `#E2E8F0` borders)
- **Status Badges**:
  - **Active**: Green `#15803D`, background `#DCFCE7`, border `#86EFAC`
  - **Inactive**: Slate `#475569`, background `#F1F5F9`, border `#CBD5E1`
  - **Maintenance**: Amber `#B45309`, background `#FEF3C7`, border `#FCD34D`

---

## 🏗️ Project Structure

```
.
├── lib/
│   ├── main.dart                                  # Application entry point & theme
│   ├── core/
│   │   ├── config/
│   │   │   └── api_config.dart                    # Centralized base URL & URI helpers
│   │   ├── errors/
│   │   │   └── api_exception.dart                 # Typed ApiException & NetworkException
│   │   ├── theme/
│   │   │   └── app_theme.dart                     # Color tokens, typography, and Material 3 theme
│   │   └── utils/
│   │       └── responsive.dart                    # Breakpoint utilities (Desktop, Tablet, Mobile)
│   ├── models/
│   │   └── vehicle.dart                          # Model with integer ID, status enum & JSON serialization
│   ├── data/
│   │   ├── api/
│   │   │   └── vehicle_api_client.dart           # HTTP client with timeouts & error parsing
│   │   ├── mock_data.dart                        # Seed data & company fallback lists
│   │   └── vehicle_repository.dart               # HTTP-backed reactive state manager
│   ├── router/
│   │   └── app_router.dart                       # Named routes & 404 recovery handling
│   ├── widgets/
│   │   ├── app_shell.dart                        # Responsive navigation shell with user menu
│   │   ├── status_badge.dart                     # Accessible status indicator chip
│   │   └── confirmation_dialog.dart              # Modal dialogs for deletion & discard confirmation
│   └── screens/
│       ├── auth/
│       │   └── login_screen.dart                 # Administrative demo login view
│       └── vehicles/
│           ├── vehicle_list_screen.dart          # Fleet directory with async fetch & retry
│           └── vehicle_form_screen.dart          # Register & Edit vehicle form with error mapping
├── test/
│   ├── widget_test.dart                          # 11 UI widget & interaction tests (offline fake)
│   ├── vehicle_api_client_test.dart              # 8 unit tests for HTTP parsing, status, & errors
│   └── vehicle_ui_integration_test.dart          # 4 UI tests for empty states, retry, & 409 conflict
└── backend/
    ├── build.gradle                              # Gradle build with Spring Boot 3.4 & Flyway
    ├── docs/
    │   └── vehicle-api.md                        # Full REST API specification with curl examples
    └── src/
        ├── main/
        │   ├── java/com/starkgroup/vms/
        │   │   ├── config/
        │   │   │   └── CorsConfig.java           # Granular CORS configuration
        │   │   ├── controller/
        │   │   │   └── VehicleController.java    # REST API endpoints (/api/vehicles)
        │   │   ├── domain/
        │   │   │   ├── Vehicle.java              # JPA Entity with unique constraint
        │   │   │   └── VehicleStatus.java        # ACTIVE, INACTIVE, MAINTENANCE
        │   │   ├── dto/                          # Request & response DTOs with validation
        │   │   ├── exception/                    # GlobalExceptionHandler & typed errors
        │   │   ├── repository/
        │   │   │   └── VehicleRepository.java    # Spring Data JPA repository
        │   │   └── service/
        │   │       └── VehicleService.java       # Normalization & business duplicate rules
        │   └── resources/
        │       ├── application.properties        # Externalized config & Flyway settings
        │       └── db/migration/
        │           └── V1__create_vehicles_table.sql # Explicit Flyway migration
        └── test/                                 # 28 Spring Boot tests (CORS, Controller, Service, Repo)
```

---

## 🧪 Testing & Verification

### 1. Flutter Test Suite
Run the 23 automated tests covering the HTTP client, JSON serialization, repository, and UI screens:

```bash
flutter test
```

### 2. Flutter Static Analysis
Ensure zero lint warnings or static analysis issues:

```bash
flutter analyze
```

### 3. Backend Test Suite
Run the 28 Spring Boot tests covering controllers, CORS preflight, service business logic, repository queries, and Bean validation:

```bash
cd backend
./gradlew test
```

---

## 🔒 Security Guidelines & Git Hygiene

- **Externalized Secrets**: Database passwords and connection strings are strictly managed via environment variables and never committed to source control.
- **Git Tracking Rules**: Build outputs (`build/`, `.gradle/`, `.dart_tool/`), cache directories, and local configurations are strictly excluded via `.gitignore`.
- **Compile-Time Base URLs**: The Flutter frontend uses `--dart-define` to inject the API URL without exposing server credentials.
