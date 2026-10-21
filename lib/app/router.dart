import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/family_tree/presentation/family_tree_screen.dart';
import '../features/people/presentation/people_directory_screen.dart';
import '../features/person_profile/presentation/person_profile_screen.dart';
import '../features/archive/presentation/archive_screen.dart';
import '../features/timeline/presentation/timeline_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/register_screen.dart';
import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/membership/presentation/invitation_redemption_screen.dart';
import '../features/membership/presentation/pending_approval_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/person_form_screen.dart';
import '../features/admin/presentation/relationship_manager_screen.dart';
import '../features/admin/presentation/membership_requests_screen.dart';
import '../features/admin/presentation/invitation_manager_screen.dart';
import '../features/admin/presentation/member_list_screen.dart';
import '../features/admin/presentation/audit_logs_screen.dart';
import '../features/admin/presentation/export_screen.dart';
import '../features/admin/presentation/incomplete_records_screen.dart';
import 'navigation_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // 5-destination bottom navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 1. Home Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // 2. Family Tree
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

        // 3. People Directory
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/people',
              builder: (context, state) => const PeopleDirectoryScreen(),
            ),
          ],
        ),

        // 4. Archive
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/archive',
              builder: (context, state) => const ArchiveScreen(),
            ),
          ],
        ),

        // 5. Profile & Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Person Profile Deep Link
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/people/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PersonProfileScreen(personId: id);
      },
    ),

    // Timeline Full Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/timeline',
      builder: (context, state) => const TimelineScreen(),
    ),

    // Settings
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Authentication Routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
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

    // Primary Admin Workspace & Tools
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'persons/new',
          builder: (context, state) => const PersonFormScreen(),
        ),
        GoRoute(
          path: 'persons/edit/:personId',
          builder: (context, state) {
            final id = state.pathParameters['personId'];
            return PersonFormScreen(personIdToEdit: id);
          },
        ),
        GoRoute(
          path: 'relationships',
          builder: (context, state) => const RelationshipManagerScreen(),
        ),
        GoRoute(
          path: 'relationships/new',
          builder: (context, state) {
            final src = state.uri.queryParameters['sourcePersonId'];
            return RelationshipManagerScreen(initialSourcePersonId: src);
          },
        ),
        GoRoute(
          path: 'requests',
          builder: (context, state) => const MembershipRequestsScreen(),
        ),
        GoRoute(
          path: 'invitations',
          builder: (context, state) => const InvitationManagerScreen(),
        ),
        GoRoute(
          path: 'members',
          builder: (context, state) => const MemberListScreen(),
        ),
        GoRoute(
          path: 'audit',
          builder: (context, state) => const AuditLogsScreen(),
        ),
        GoRoute(
          path: 'export',
          builder: (context, state) => const ExportScreen(),
        ),
        GoRoute(
          path: 'incomplete',
          builder: (context, state) => const IncompleteRecordsScreen(),
        ),
      ],
    ),
  ],
);
