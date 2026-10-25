import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_layout.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final currentRoute = state.uri.toString();

    return Scaffold(
      key: scaffoldKey,
      drawer: isMobile
          ? Drawer(
              child: AppSidebar(
                currentRoute: currentRoute,
                onCloseDrawer: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) AppSidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  onOpenDrawer: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(child: SelectionArea(child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
