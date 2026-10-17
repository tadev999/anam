import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_view.dart';
import '../../../practices/presentation/screens/practices_view.dart';
import '../../../hearth/presentation/screens/hearth_view.dart';
import '../../../mind_garden/presentation/screens/mind_garden_screen.dart';
import '../../../profile/presentation/screens/profile_view.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeView(),
      const PracticesView(),
      const HearthView(),
      const MindGardenScreen(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.spa_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.spa_rounded, color: AppColors.primary),
              label: 'An Trú',
            ),
            NavigationDestination(
              icon: Icon(Icons.self_improvement_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.self_improvement_rounded, color: AppColors.primary),
              label: 'Lắng Dịu',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.local_fire_department_rounded, color: AppColors.primary),
              label: 'Bếp Lửa',
            ),
            NavigationDestination(
              icon: Icon(Icons.filter_vintage_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.filter_vintage_rounded, color: AppColors.primary),
              label: 'Vườn Tâm',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Hồ Sơ',
            ),
          ],
        ),
      ),
    );
  }
}
