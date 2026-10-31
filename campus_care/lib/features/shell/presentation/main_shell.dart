import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/main_tabs.dart';
import '../../../core/theme/app_theme.dart';
import '../../appointments/presentation/screens/appointments_screen.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../messaging/presentation/screens/messages_screen.dart';
import '../../notifications/presentation/viewModels/notification_provider.dart';
import '../../profile/presentation/screens/profile_screen.dart';

/// Bottom navigation (Home / Appointments / Messages / Profile) around the tab pages.
/// Tabs keep their state while you switch between them; a tab is built the first
/// time it is opened.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final Set<int> _opened = {0};

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<MainTabs>();
    final index = tabs.index;
    _opened.add(index);
    final unread = context.select<NotificationProvider, int>(
      (p) => p.unreadCount,
    );
    // Hide the bar while typing so it does not squeeze the page (chat, journal).
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    Widget page(int i) {
      if (!_opened.contains(i)) return const SizedBox.shrink();
      switch (AppTab.values[i]) {
        case AppTab.home:
          return const HomeScreen();
        case AppTab.appointments:
          return const AppointmentsScreen();
        case AppTab.messages:
          return MessagesScreen(initialTab: tabs.messagesTab);
        case AppTab.profile:
          return const ProfileScreen();
      }
    }

    return PopScope(
      // Back on another tab returns to Home before the app closes.
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<MainTabs>().select(AppTab.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: IndexedStack(
          index: index,
          children: [for (var i = 0; i < AppTab.values.length; i++) page(i)],
        ),
        bottomNavigationBar: keyboardOpen
            ? null
            : SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      backgroundColor: Colors.transparent,
                      indicatorColor: Colors.white.withAlpha(50),
                      labelTextStyle: const WidgetStatePropertyAll(
                        TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      iconTheme: const WidgetStatePropertyAll(
                        IconThemeData(color: Colors.white),
                      ),
                    ),
                    child: NavigationBar(
                      elevation: 0,
                      selectedIndex: index,
                      onDestinationSelected: (i) =>
                          context.read<MainTabs>().select(AppTab.values[i]),
                      destinations: [
                        const NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          label: 'Home',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.calendar_month_outlined),
                          label: 'Appointments',
                        ),
                        NavigationDestination(
                          icon: Badge(
                            isLabelVisible: unread > 0,
                            label: Text(unread > 9 ? '9+' : '$unread'),
                            child: const Icon(Icons.chat_bubble_outline),
                          ),
                          label: 'Messages',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.person_outline),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
