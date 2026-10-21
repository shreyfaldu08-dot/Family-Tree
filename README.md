# Family Legacy — Living Heritage Mobile Application

**Family Legacy** is a production-oriented Flutter mobile application designed to preserve family history, oral narratives, documents, and historical milestones across **ten generations**.

The application is built on **Flutter & Dart**, with a **PostgreSQL** backend managed via **Supabase**, strict **Row Level Security (RLS)** policies, private media storage buckets, and a signature **organic CustomPainter lineage visualization engine**.

---

## 1. Architectural Foundation & Tech Stack

- **Mobile Frontend:** Flutter 3.47.7+ & Dart 3.13.5+
- **Architecture:** Feature-based Clean Architecture (`presentation`, `domain`, `data`, `services`)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Navigation & Routing:** GoRouter with `StatefulShellRoute` (5-tab persistent bottom bar)
- **Backend & Database:** Supabase & PostgreSQL 15+
- **Security & Authorization:** PostgreSQL Row Level Security (RLS) + Defensive Client Security Guards
- **Private Storage:** Supabase Storage (`family-legacy-private` bucket) with short-lived signed URLs
- **Lineage Visualization:** Custom `CustomPainter` with cubic Bézier branch paths and `TreeLayoutEngine`
- **Session Persistence:** `flutter_secure_storage` with hardware keystore / keychain backing
- **Typography:** Cormorant Garamond (Editorial Serif for names & stories) & Inter (Sans-serif for UI)
- **Living Heritage Color Palette:**
  - Forest green: `#203D32`
  - Warm ivory: `#F5F0E6`
  - Muted brass: `#B18A54`
  - Stone: `#E7E0D4`
  - Charcoal: `#292C27`
  - Sage: `#6D786B`

---

## 2. Strict Authorization Architecture

There is **exactly one primary admin (Archon)** for each family archive.

| Capability | Primary Admin | Approved Family Viewer |
| :--- | :---: | :---: |
| **View Family Tree & 10 Generations** | Yes | Yes |
| **Search Directory & Read Profiles** | Yes | Yes |
| **Read Biographies & Life Stories** | Yes | Yes |
| **Access Permitted Media & Documents** | Yes | Yes |
| **Create / Edit / Delete Person Records** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **Add / Delete Family Relationships** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **Upload / Delete Media Assets** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **Generate & Revoke Single-Use Invites** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **Approve / Reject Membership Requests** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **Revoke Member Access** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **View Audit Trail Logs** | **Yes** | **DENIED (Blocked by RLS & UI)** |
| **Export Full Archive JSON** | **Yes** | **DENIED (Blocked by RLS & UI)** |

> **Security Guard Policy:** Viewers can NEVER write to canonical family records. Attempting direct PostgreSQL API writes from a viewer session will fail with RLS violation errors.

---

## 3. Database Schema & Supabase Migrations

The database migrations are located in `supabase/migrations/`:

1. `20261021_01_family_legacy_schema.sql`:
   - Tables: `profiles`, `families`, `family_memberships`, `invitations`, `membership_requests`, `persons`, `relationships`, `media_assets`, `person_media`, `life_events`, `event_person_links`, `sources`, `person_sources`, `audit_logs`.
   - Constraints: Enforces exactly one active primary admin per family via unique partial index.
   - Enforces `chk_no_self_relation` (`person_id <> related_person_id`).

2. `20261021_02_family_legacy_rls.sql`:
   - Security helper functions: `is_family_admin(family_id)`, `is_approved_family_member(family_id)`.
   - Recursive CTE cycle prevention function: `check_ancestry_cycle(family_id, parent_id, child_id)`.
   - Trigger `trg_validate_relationship` executing `validate_relationship_insert()` before any insert or update on `relationships`.
   - Complete Row Level Security policies across all tables.
   - Private bucket storage policies for `family-legacy-private`.

3. `20261021_03_stored_procedures.sql`:
   - Atomic stored procedures: `redeem_invitation_and_request()`, `approve_membership_request()`, `reject_membership_request()`, `revoke_membership()`, `export_family_archive()`.

4. `20261021_04_sample_seed.sql`:
   - Complete 10-generation synthetic test seed documenting the **Kensington Living Heritage** across four centuries (1720–2024).

### Applying Migrations to Supabase

Using the Supabase CLI:
```bash
supabase link --project-ref your-project-ref
supabase db push
```
Or paste the contents of `supabase/migrations/*.sql` into the Supabase SQL Editor.

---

## 4. Project Directory Structure

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router with Riverpod ProviderScope
│   ├── navigation_scaffold.dart   # 5-destination bottom navigation bar
│   ├── router.dart                # GoRouter route declarations and guards
│   └── theme/
│       ├── app_theme.dart         # Material 3 theme with rounded Living Heritage styling
│       ├── colors.dart            # Palette tokens (forest green, ivory, brass, stone)
│       └── typography.dart        # Cormorant Garamond & Inter typography definitions
├── core/
│   ├── config/
│   │   └── supabase_config.dart   # Supabase URL, anon key, bucket names
│   ├── errors/
│   │   └── app_exception.dart     # Domain exceptions (Unauthorized, AncestryCycle, etc.)
│   └── security/
│       └── security_guards.dart   # Client authorization guards & cycle check assertions
├── data/
│   ├── models/                    # Typed data models with JSON serialization
│   │   ├── audit_entry.dart
│   │   ├── family.dart
│   │   ├── invitation.dart
│   │   ├── life_event.dart
│   │   ├── media_asset.dart
│   │   ├── membership.dart
│   │   ├── person.dart
│   │   ├── profile.dart
│   │   ├── relationship.dart
│   │   └── source.dart
│   ├── providers/
│   │   └── repository_providers.dart # Riverpod providers for DI & reactive state
│   ├── repositories/              # Repositories with remote Supabase & local fallbacks
│   │   ├── admin_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── family_repository.dart
│   │   ├── media_repository.dart
│   │   ├── person_repository.dart
│   │   ├── relationship_repository.dart
│   │   └── timeline_repository.dart
│   └── services/
│       ├── secure_storage_service.dart # FlutterSecureStorage session persistence
│       └── supabase_service.dart       # Supabase client, signed URLs, SHA-256 hashing
└── features/
    ├── admin/                     # Primary Admin workspace screens
    │   └── presentation/
    │       ├── admin_dashboard_screen.dart
    │       ├── audit_logs_screen.dart
    │       ├── export_screen.dart
    │       ├── incomplete_records_screen.dart
    │       ├── invitation_manager_screen.dart
    │       ├── member_list_screen.dart
    │       ├── membership_requests_screen.dart
    │       ├── person_form_screen.dart
    │       └── relationship_manager_screen.dart
    ├── archive/                   # Photos, audio stories, documents
    ├── authentication/            # Sign in, register, forgot password
    ├── dashboard/                 # Overview, lineage metrics, recent records
    ├── family_tree/               # Signature Feature: 10-Generation Tree
    │   ├── domain/
    │   │   ├── tree_layout_engine.dart # Relative generation depth & node coordinates
    │   │   └── tree_node.dart          # Graph node model
    │   └── presentation/
    │       ├── family_tree_painter.dart # CustomPainter with organic curved branches
    │       ├── family_tree_screen.dart  # InteractiveViewer with pan & pinch-zoom
    │       └── widgets/
    │           ├── generation_navigator.dart # Floating generation stepper (-5 to +5)
    │           ├── person_node_widget.dart   # Portrait avatar, brass badges
    │           └── tree_preview_sheet.dart   # Selected person bottom sheet
    ├── membership/                # Invitation redemption & pending approval
    ├── people/                    # Searchable directory with filters
    ├── person_profile/            # 6-tab profile (Overview, Connections, Story, Memories, Docs, Timeline)
    ├── settings/                  # User profile, role switcher simulator, sign out
    └── timeline/                  # Chronological family milestones
```

---

## 5. Running the Application Locally

### Prerequisites
- Flutter SDK (v3.22.0 or higher)
- Dart SDK (v3.4.0 or higher)
- Android Studio / Xcode

### Setup
```bash
# Clone the repository and navigate into the workspace
git clone <repo-url>
cd "family_legacy"

# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run the automated test suite
flutter test
```

### Running on Device or Emulator
```bash
# Run with default offline test mode (preloaded with 10-generation Kensington lineage)
flutter run

# Run with custom live Supabase backend
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## 6. Build Instructions

### Android Build
1. In `android/app/build.gradle`, verify `minSdkVersion 23` and `targetSdkVersion 34`.
2. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. Create `android/key.properties` with keystore credentials.
4. Build release APK or App Bundle:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

### iOS Build
1. Install CocoaPods dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Open `ios/Runner.xcworkspace` in Xcode.
3. Configure `Signing & Capabilities` with your Apple Developer Team.
4. Build release IPA:
   ```bash
   flutter build ipa --release
   ```

---

## 7. Testing Suite Summary

Family Legacy includes automated test suites covering:
- **`test/unit/security_guards_test.dart`**:
  - Primary admin write verification
  - Viewer write rejection (`UnauthorizedException`)
  - Revoked member immediate access termination
  - Self-parenting prevention
  - Multi-node ancestry cycle detection (A $\rightarrow$ B $\rightarrow$ C $\rightarrow$ A)
- **`test/unit/tree_layout_engine_test.dart`**:
  - 10-generation lineage graph layout
  - Relative generation depth calculations
  - Upward ancestor positioning vs downward descendant positioning
- **`test/unit/invitation_hashing_test.dart`**:
  - SHA-256 token normalization & cryptographic hashing
  - Expiration and revocation checks
- **`test/widget_test.dart`**:
  - Smoke tests verifying navigation shell, dashboard, and tabs

Run tests anytime via:
```bash
flutter test
```
