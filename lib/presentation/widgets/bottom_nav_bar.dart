import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(LucideIcons.home),
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('12 Live', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            activeIcon: const Icon(LucideIcons.home, color: AppColors.primaryOrange),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.navigation),
            label: 'Routes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.mapPin),
            label: 'Nearby',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.clock),
            label: 'Timetable',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
