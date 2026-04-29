import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/core/theme/app_theme.dart';
import '../home/home_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  String selectedCity = "Pune";

  final List<Map<String, dynamic>> cities = [
    {"name": "Pune", "operator": "PMPML", "color": const Color(0xFFE65100), "live": true},
    {"name": "Mumbai", "operator": "BEST", "color": const Color(0xFF1565C0), "live": true},
    {"name": "Delhi", "operator": "DTC", "color": const Color(0xFFC62828), "live": true},
    {"name": "Bangalore", "operator": "BMTC", "color": const Color(0xFF2E7D32), "live": true},
    {"name": "Hyderabad", "operator": "TSRTC", "color": const Color(0xFF6A1B9A), "live": false},
    {"name": "Chennai", "operator": "MTC", "color": const Color(0xFF00838F), "live": true},
    {"name": "Ahmedabad", "operator": "AMTS", "color": const Color(0xFFF57F17), "live": false},
    {"name": "Kolkata", "operator": "CTS", "color": const Color(0xFF558B2F), "live": true},
    {"name": "Jaipur", "operator": "JCT", "color": const Color(0xFFAD1457), "live": false},
    {"name": "Nagpur", "operator": "NMC", "color": const Color(0xFF00695C), "live": true},
    {"name": "Surat", "operator": "SUDA", "color": const Color(0xFF1565C0), "live": false},
    {"name": "Indore", "operator": "City Bus", "color": const Color(0xFF4527A0), "live": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Select Your City"),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search city or state...",
                  prefixIcon: Icon(LucideIcons.search),
                  suffixIcon: Icon(LucideIcons.mic),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Text("Popular Cities", style: AppTextStyles.subHead.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final isSelected = selectedCity == city["name"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCity = city["name"];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [city["color"], city["color"].withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge - 2)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.location_city, color: Colors.white, size: 32),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(city["name"], style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
                                    Text(city["operator"], style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: city["live"] ? AppColors.busOnTime : AppColors.textSecondary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          city["live"] ? "Live" : "Schedule Only",
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryOrange,
                              child: Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: Text("Continue with $selectedCity"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
