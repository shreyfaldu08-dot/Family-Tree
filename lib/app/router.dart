import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/authentication/presentation/landing_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/admin_login_screen.dart';
import '../features/authentication/presentation/register_screen.dart';
import '../features/authentication/presentation/lineage_bridge_onboarding_screen.dart';
import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dashboard/presentation/notifications_screen.dart';
import '../features/family_tree/presentation/family_tree_screen.dart';
import '../features/people/presentation/people_directory_screen.dart';
import '../features/people/presentation/relationship_finder_screen.dart';
import '../features/person_profile/presentation/person_profile_screen.dart';
import '../features/archive/presentation/archive_screen.dart';
import '../features/timeline/presentation/timeline_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/membership/presentation/invitation_redemption_screen.dart';
import '../features/membership/presentation/pending_approval_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/person_form_screen.dart';
import '../features/admin/presentation/relationship_manager_screen.dart';
import '../features/admin/presentation/manage_users_screen.dart';
import '../features/admin/presentation/manage_media_screen.dart';
import '../features/admin/presentation/correction_requests_screen.dart';
import '../features/admin/presentation/admin_settings_screen.dart';
import '../features/admin/presentation/audit_logs_screen.dart';
import '../features/admin/presentation/export_screen.dart';
import '../features/admin/presentation/incomplete_records_screen.dart';
import 'navigation_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    // 1. Public Landing Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),

    // 2. Public Auth Routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/signup',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/redeem-invitation',
      builder: (context, state) => const InvitationRedemptionScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/pending-approval',
      builder: (context, state) => const PendingApprovalScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/lineage-bridge',
      builder: (context, state) => const LineageBridgeOnboardingScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/join-tree',
      builder: (context, state) => const LineageBridgeOnboardingScreen(),
    ),

    // Main 6-destination bottom navigation shell (7 for Admin)
    // Section 3: User bottom menu: Home, Tree, Search, Timeline, Gallery, Settings. Admin sees same + Admin tab.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 1. Home Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // 2. Tree View
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tree',
              builder: (context, state) {
                final personId = state.uri.queryParameters['personId'];
                return FamilyTreeScreen(initialPersonId: personId);
              },
            ),
          ],
        ),

        // 3. Timeline
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timeline',
              builder: (context, state) => const TimelineScreen(),
            ),
          ],
        ),

        // 4. Search & People Directory
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const PeopleDirectoryScreen(),
            ),
            GoRoute(
              path: '/people',
              builder: (context, state) => const PeopleDirectoryScreen(),
            ),
          ],
        ),

        // 5. Settings & Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),

        // 6. Gallery & Documents Archive
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gallery',
              builder: (context, state) => const ArchiveScreen(),
            ),
            GoRoute(
              path: '/archive',
              builder: (context, state) => const ArchiveScreen(),
            ),
          ],
        ),

        // 7. Admin Workspace (Branch 6, visible in Admin mode only)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),
      ],
    ),

    // Additional User Routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/member/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PersonProfileScreen(personId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/people/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PersonProfileScreen(personId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/relation',
      builder: (context, state) => const RelationshipFinderScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Admin Specific Form & Management Deep Links
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/person/new',
      builder: (context, state) {
        final relType = state.uri.queryParameters['initialRelationType'] ?? state.uri.queryParameters['relationType'];
        final srcId = state.uri.queryParameters['initialSourcePersonId'] ?? state.uri.queryParameters['sourcePersonId'];
        return PersonFormScreen(
          initialRelationType: relType,
          initialSourcePersonId: srcId,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/persons/new',
      builder: (context, state) {
        final relType = state.uri.queryParameters['initialRelationType'] ?? state.uri.queryParameters['relationType'];
        final srcId = state.uri.queryParameters['initialSourcePersonId'] ?? state.uri.queryParameters['sourcePersonId'];
        return PersonFormScreen(
          initialRelationType: relType,
          initialSourcePersonId: srcId,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/person/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return PersonFormScreen(personIdToEdit: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/persons/edit/:personId',
      builder: (context, state) {
        final id = state.pathParameters['personId'];
        return PersonFormScreen(personIdToEdit: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/relations',
      builder: (context, state) => const RelationshipManagerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/relationships',
      builder: (context, state) => const RelationshipManagerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/relationships/new',
      builder: (context, state) {
        final src = state.uri.queryParameters['sourcePersonId'];
        return RelationshipManagerScreen(initialSourcePersonId: src);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/users',
      builder: (context, state) => const ManageUsersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/media',
      builder: (context, state) => const ManageMediaScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/requests',
      builder: (context, state) => const CorrectionRequestsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/settings',
      builder: (context, state) => const AdminSettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/logs',
      builder: (context, state) => const AuditLogsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/audit',
      builder: (context, state) => const AuditLogsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/export',
      builder: (context, state) => const ExportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/incomplete',
      builder: (context, state) => const IncompleteRecordsScreen(),
    ),
  ],
);
