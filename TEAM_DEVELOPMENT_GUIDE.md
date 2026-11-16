# Mosaed — Team Development Guide

**Document type:** Team working agreement  
**Team size:** 4 developers (1 Team Leader + 3 Developers)  
**Architecture:** Feature-first, with responsibility-based layers inside features  
**State management:** Cubit (`flutter_bloc`)  
**Backend:** Firebase / Cloud Firestore / Firebase Storage

> This is the team's shared development guide. Read it before starting a feature. Changes to shared contracts, database structure, security rules, or project-wide configuration require Team Leader review.

## 1. Project Overview

Mosaed is a pharmacy and medicine discovery application with two main roles:

- **Customer:** discovers pharmacies and medicines, views availability and prices, places orders, and communicates with pharmacies.
- **Pharmacy:** manages its profile and inventory, receives and processes orders, and communicates with customers.

Current technical decisions:
- Flutter and Dart.
- Feature-first project organization.
- Cubit for state management.
- Firebase Authentication for identity.
- Cloud Firestore for application data.
- Firebase Storage for uploaded files and images.
- `go_router` for navigation.
- Shared styling and reusable components in `core/`.

These are current project decisions. Do not add architectural layers to every feature unless they are needed.

## 2. Team Responsibilities

This guide assumes four people total: the Team Leader plus three Developers.

### Team Leader — Architecture, Backend Foundation, Integration

Owns:
- `core/`, `main.dart`, `app.dart`, routing, and app initialization.
- Shared design system and reusable core widgets.
- Firebase project configuration and environment setup.
- Firestore schema proposals, indexes, and Security Rules.
- Shared contracts and cross-feature integration.
- Pull request review and merge approval.
- Chat and shared notification infrastructure, scheduled after foundational features are ready.

The Team Leader approves shared-file and contract changes, keeps `develop` buildable, resolves cross-feature dependencies, and coordinates integration testing.

### Developer 1 — Authentication and Profiles

Owns:
- `features/authentication/`
- `features/profile/`

Scope:
- Customer and pharmacy registration.
- Login and logout.
- Password reset and agreed email-verification flow.
- Role-aware account setup.
- User profile viewing and editing.
- Pharmacy profile settings that belong to the account/profile flow.
- Form validation and loading, success, and failure states.

### Developer 2 — Customer Application

Owns:
- `features/customer/`
- Customer-facing UI in `features/medicines/`

Scope:
- Customer home.
- Pharmacy discovery and details.
- Medicine search and browsing.
- Display of medicine information, availability, and prices.
- Cart experience.
- Customer-side order creation through the agreed order contract.
- Customer order history and tracking UI.

### Developer 3 — Pharmacy Management

Owns:
- `features/pharmacy/`
- `features/inventory/`
- Canonical order data model and pharmacy-side order workflow in `features/orders/`

Scope:
- Pharmacy dashboard.
- Incoming orders.
- Inventory listing and search.
- Add, edit, and remove inventory entries.
- Update prices and quantities.
- Excel import after its format and validation rules are agreed.
- Accept or reject orders.
- Update order status through approved transitions.
- Pharmacy-side order history.

### Shared ownership rules

| Capability | Owner | Other member's responsibility |
|---|---|---|
| Authentication and user profile | Developer 1 | Other features consume the agreed user contract |
| Medicine catalog and customer discovery UI | Developer 2 | Inventory references agreed medicine identifiers |
| Pharmacy inventory | Developer 3 | Customer screens read availability and price through the agreed interface |
| Orders data model and lifecycle | Developer 3 | Developer 2 builds customer-side screens using the agreed interface |
| Chat | Team Leader | Other developers integrate using the agreed conversation interface |
| Core, routing, shared widgets | Team Leader | Feature developers request changes rather than editing shared files independently |

Do not create duplicate models, repositories, or Firestore collections for a capability owned by another developer.

## 3. Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routing/
│   ├── utils/
│   └── widgets/
│       ├── buttons/
│       ├── inputs/
│       ├── cards/
│       ├── badges/
│       ├── dialogs/
│       └── navigation/
├── features/
│   ├── authentication/
│   ├── customer/
│   ├── pharmacy/
│   ├── medicines/
│   ├── inventory/
│   ├── orders/
│   ├── chat/
│   └── profile/
├── app.dart
└── main.dart
```

Example internal structure (create only folders that a feature needs):

```text
feature_name/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── logic/
│   └── cubits/
│       └── feature_name/
│           ├── feature_cubit.dart
│           └── feature_state.dart
└── presentation/
    ├── screens/
    └── widgets/
```

Rules:
1. Do not create empty layers just for appearance.
2. Screens and widgets must not call Firebase directly.
3. Shared widgets belong in `core/widgets/` only when genuinely reusable.
4. Feature-specific widgets stay inside their feature.
5. Coordinate before moving or renaming shared folders.

## 4. Coding Standards

| Item | Convention | Example |
|---|---|---|
| Files and folders | `snake_case` | `login_cubit.dart` |
| Classes and enums | `PascalCase` | `LoginCubit` |
| Variables and methods | `camelCase` | `loadOrders()` |
| Constants | `camelCase` | `defaultPageSize` |
| Cubit files | `<feature>_cubit.dart` | `login_cubit.dart` |
| State files | `<feature>_state.dart` | `login_state.dart` |
| Models | `<name>_model.dart` | `user_model.dart` |

General rules:
- Prefer descriptive names, immutable models and states, and `const` constructors where possible.
- Handle nullable values deliberately; avoid unnecessary `!`.
- Keep methods focused and avoid oversized widgets or Cubit methods.
- Do not duplicate business rules across screens.
- Run formatting, analysis, and relevant tests before a pull request.
- Never commit service-account keys, private credentials, or secrets.

UI rules:
- Follow approved Figma screens and Mosaed design tokens.
- Use `AppColors`, `AppTextStyles`, and `AppDimensions` instead of scattering raw values.
- Support Arabic and right-to-left layout.
- Handle loading, empty, error, and success states.
- Do not present hard-coded demo content as production data.

## 5. State Management and Data Flow

Agreed default flow:

```text
Presentation (Screen / Widget)
          |
          v
        Cubit
          |
          v
      Repository
          |
          v
   Data Source (Firebase)
```

Responsibilities:
- **Presentation:** renders state and sends user actions to Cubit. No Firebase queries.
- **Cubit:** coordinates actions, calls repositories, and emits states. No UI layout code.
- **Repository:** exposes feature operations and hides Firebase details from Cubit.
- **Data source:** performs Firebase operations and is called by the repository.

Use explicit states such as `Initial`, `Loading`, `Success`, and `Failure`. Add feature-specific state data when needed; do not force unrelated operations into one unclear generic state.

Example repository contract:

```dart
abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}
```

## 6. Shared Data Contracts

Before implementing a feature that reads or writes shared data, its owner must agree on model fields, identifiers, and repository methods with the Team Leader and affected feature owners.

### User identity
- Firebase Authentication UID is the authoritative user identifier.
- Use agreed role values: `customer` and `pharmacy`.
- Do not generate a separate random ID for an authenticated user.
- Authorization must be enforced by trusted backend rules or server-side logic, not only by hiding UI controls.

### Medicine and inventory
- The medicine catalog stores general medicine information.
- Pharmacy inventory stores a particular pharmacy's availability, quantity, and selling price for a medicine.
- Catalog data alone is not proof that a pharmacy has stock.
- Inventory entries must reference agreed pharmacy and medicine identifiers.

### Orders
Developer 3 owns the canonical order model and lifecycle. Customer and pharmacy interfaces must use the same contract.

Proposed initial status values (must be approved before implementation):

```text
pending
accepted
rejected
preparing
ready
completed
cancelled
```

Agree on allowed transitions, who can perform each transition, and how stock is reserved or reduced. Do not invent new status strings independently.

### Money and timestamps
- Store money as integer minor units (for example, piasters), not floating-point values.
- Use Firestore `Timestamp` for persisted dates.
- Agree on field names and whether timestamps are client-created or server-created.

## 7. Proposed Firestore Collections

**This is a proposal, not an approved final schema.** The Team Leader must review fields, relationships, queries, indexes, and Security Rules before implementation depends on it.

| Collection | Purpose |
|---|---|
| `users` | User profile and role |
| `pharmacies` | Pharmacy profile and verification metadata |
| `medicines` | General medicine catalog |
| `pharmacy_inventory` | Pharmacy-specific prices and quantities |
| `orders` | Customer orders and pharmacy processing |
| `conversations` | Conversation metadata |
| `conversations/{id}/messages` | Messages in a conversation |
| `notifications` | Notification records, if stored in Firestore |

Data principles:
- Use Firebase Auth UID as the `users` document ID.
- Protect private license and verification data.
- Inventory records identify both pharmacy and medicine.
- Order items should preserve the agreed product and price snapshot.
- Validate totals using trusted logic; do not trust client-submitted totals.
- Validate stock and order transitions against concurrent updates.
- Client-side checks are not security controls.

Firebase security:
- Firestore Rules enforce authentication, ownership, role, and allowed field changes.
- Storage Rules restrict uploads by user, file type, and size as appropriate.
- Never put Admin SDK credentials in the Flutter app.
- Do not deploy unreviewed rules to production.
- Keep rules and index configuration in version control.

## 8. Firebase Environments and Access

Use separate Firebase projects for development and production when both are configured.

**Development**
- All developers use the shared Mosaed Development project.
- Use test accounts and test data only.
- Coordinate changes to collections, indexes, and rules.

**Production**
- Restrict privileged access.
- Do not point development builds at production by default.
- Production deployments and rule changes require Team Leader approval.

Never commit service-account JSON files, private keys, passwords, or private tokens. Client Firebase configuration does not replace Security Rules.

## 9. Git Workflow

### Branches
- `main`: stable release-ready code.
- `develop`: shared integration branch.
- `feature/<name>`: feature work.
- `fix/<name>`: bug fixes.
- `refactor/<name>`: refactoring.

Examples:

```text
feature/authentication
feature/customer-discovery
feature/pharmacy-inventory
feature/chat
fix/login-validation
```

### Initial setup

The Team Leader creates the repository and `develop` branch. Each developer clones the repository:

```bash
git clone <repository-url>
cd <repository-folder>
git checkout develop
git pull origin develop
```

### Start a task

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<task-name>
```

### Commit examples

```text
feat(auth): implement login
feat(inventory): add inventory item
fix(customer): handle empty search results
refactor(orders): extract repository
test(auth): add login cubit tests
docs: update team development guide
```

Allowed prefixes: `feat`, `fix`, `refactor`, `style`, `test`, `docs`, `chore`.

### Before a pull request

```bash
dart format .
flutter analyze
flutter test
```

Run relevant tests. If tests do not yet exist, add them where practical and report remaining test gaps. Update the feature branch with current `develop` before requesting review. Resolve conflicts in the feature branch.

### Pull request rules

Every PR must:
1. Target `develop`, not `main`.
2. Explain what changed and why.
3. Identify affected features and files.
4. Include screenshots or a recording for UI changes.
5. Mention Firestore schema, rules, or index changes.
6. Include analyzer and test results.
7. Be reviewed and approved by the Team Leader before merge.

Do not push directly to `main` or `develop`.

## 10. Definition of Done

A feature is not complete merely because its screen renders.

- [ ] UI follows approved Figma design and design tokens.
- [ ] User actions work as expected.
- [ ] Cubit and states are implemented cleanly.
- [ ] Data access goes through repositories.
- [ ] Firebase integration works in development.
- [ ] Loading, empty, error, and success states are handled.
- [ ] Inputs are validated.
- [ ] Authorization and ownership are enforced by Security Rules or trusted backend logic.
- [ ] Important success and failure paths are tested.
- [ ] `dart format .` has been run.
- [ ] `flutter analyze` has no unresolved issues introduced by the change.
- [ ] Relevant tests pass.
- [ ] PR is reviewed and merged into `develop`.

If an item is not applicable, explain why in the PR.

## 11. Communication

At the team's agreed check-in, each developer reports:
1. What did I complete?
2. What am I working on next?
3. Am I blocked?
4. Do I need a contract, model, or shared-file change?

Raise cross-feature questions before implementing assumptions. Do not wait until integration week to reveal incompatible models or collection structures.

The Team Leader maintains the task board and records approved decisions in this guide or linked documentation.

## 12. Delivery Order

### Phase 1 — Foundation
- Confirm repository and branch protections.
- Configure development Firebase.
- Agree on initial data contracts and Security Rules.
- Confirm shared models and routing contracts.

### Phase 2 — Authentication
- Implement customer and pharmacy registration.
- Implement login, logout, and password reset.
- Persist user role and profile data.
- Test role-aware navigation.

### Phase 3 — Parallel development
- Developer 2: customer discovery and medicine browsing.
- Developer 3: pharmacy dashboard and inventory.
- Team Leader: integration and chat foundations.

### Phase 4 — Orders integration
- Connect customer cart and order creation to pharmacy inventory.
- Implement pharmacy order processing.
- Validate stock and order status transitions.

### Phase 5 — Communication
- Implement conversations and messages.
- Add notifications as agreed.
- Integrate chat entry points into customer and pharmacy flows.

### Phase 6 — Testing and release
- Test customer and pharmacy end-to-end flows.
- Review security rules and access boundaries.
- Resolve integration defects.
- Prepare the release build.

## 13. Change Control

This guide is versioned with the project. Changes to project architecture, shared models, repository interfaces, Firestore structure, order statuses, Firebase rules, routing, app initialization, or shared design tokens require discussion and Team Leader approval.

When a decision changes, update this document and inform all developers before relying on the new decision.

---

**End of guide — Depi project Team**
