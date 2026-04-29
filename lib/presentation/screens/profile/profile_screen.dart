import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // light grey usually, handled by theme
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryOrange, AppColors.primaryOrangeDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 12)
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              // Removing NetworkImage to avoid real network requests during static UI test, substituted with simple Icon
                              color: AppColors.primaryOrangeLight,
                            ),
                            child: const Center(child: Icon(Icons.person, color: Colors.white, size: 32)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Atul Patil", style: AppTextStyles.subHead.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text("Pune · Daily Commuter 🏅", style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.9))),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatPill("247 Trips"),
                          _buildStatPill("12 Reports"),
                          _buildStatPill("850 pts"),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contribution Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Your Contribution", style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
                          Text("🏆 Rank #42 in Pune", style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        child: const LinearProgressIndicator(
                          value: 0.68,
                          backgroundColor: AppColors.divider,
                          color: AppColors.primaryOrange,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("City Hero Level: 68%", style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                      const SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildBadgeCard(context, "🛡️ Route Expert"),
                            _buildBadgeCard(context, "⭐ Daily Commuter"),
                            _buildBadgeCard(context, "🔥 Top Reporter"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),

                // Settings Group 1
                _buildSettingsGroup(context, "My Preferences", [
                  _buildSettingsTile(context, "🏙️", "Saved Cities", trailing: "Pune, Mumbai"),
                  _buildSettingsTile(context, "⭐", "Saved Routes", trailing: "3 routes"),
                  _buildSettingsTile(context, "🔔", "Notifications", isSwitch: true, switchValue: true),
                  _buildSettingsTile(context, "🌙", "Dark Mode", isSwitch: true, switchValue: false),
                ]),

                // Settings Group 2
                _buildSettingsGroup(context, "App Settings", [
                  _buildSettingsTile(context, "🌐", "Language", trailing: "English"),
                  _buildSettingsTile(context, "♿", "Accessibility", trailing: "Standard"),
                  _buildSettingsTile(context, "📴", "Offline Data", trailing: "Pune timetable · 2.4 MB"),
                ]),

                // Settings Group 3
                _buildSettingsGroup(context, "Account", [
                  _buildSettingsTile(context, "🔑", "Login / Account", trailing: "Google · atul@gmail.com"),
                  _buildSettingsTile(context, "🔒", "Privacy Settings", hasArrow: true),
                  _buildSettingsTile(context, "❓", "Help & Support", hasArrow: true),
                  _buildSettingsTile(context, "⭐", "Rate BusIndia", hasArrow: true),
                ]),

                const SizedBox(height: AppSpacing.md),
                
                TextButton(
                  onPressed: () {},
                  child: const Text("Sign Out", style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primaryOrangeDark, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildBadgeCard(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, 2), blurRadius: 8)
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String icon, String title, {String? trailing, bool hasArrow = false, bool isSwitch = false, bool switchValue = false}) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          if (hasArrow) const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          if (isSwitch) Switch(
            value: switchValue,
            onChanged: (v) {},
            activeColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }
}
