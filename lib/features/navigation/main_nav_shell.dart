import 'package:flutter/material.dart';
import '../../core/widgets/background_gradient_scaffold.dart';
import '../counter/presentation/today_screen.dart';
import '../history/presentation/history_screen.dart';
import 'floating_bottom_nav.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  AppTab _currentTab = AppTab.today;

  @override
  Widget build(BuildContext context) {
    return BackgroundGradientScaffold(
      body: Stack(
        children: [
          // Screen with transition: fade + slight upward slide (250 ms)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _currentTab == AppTab.today
                ? const KeyedSubtree(
                    key: ValueKey('today_screen'),
                    child: TodayScreen(),
                  )
                : const KeyedSubtree(
                    key: ValueKey('history_screen'),
                    child: HistoryScreen(),
                  ),
          ),

          // Floating Bottom Navigation pill
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingBottomNav(
                currentTab: _currentTab,
                onTabSelected: (tab) {
                  setState(() {
                    _currentTab = tab;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

