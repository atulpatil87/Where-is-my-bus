import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/presentation/widgets/bottom_nav_bar.dart';
import 'package:busindia/presentation/widgets/city_chip.dart';
import '../live_map/live_map_screen.dart';
import '../route_finder/route_finder_screen.dart';
import '../nearby_stops/nearby_stops_screen.dart';
import '../timetable/timetable_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LiveMapScreen(),
    const RouteFinderScreen(),
    const NearbyStopsScreen(),
    const TimetableScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("BusIndia", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            CityChip(cityName: "Pune", onTap: () {}),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).dividerColor,
            height: 1.0,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
