import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final gradientColors = isDark 
            ? AppTheme.getDarkGradient() 
            : AppTheme.getLightGradient();

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                        const Expanded(
                          child: Text(
                            'Settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),

                  // Settings Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildSectionTitle(context, 'Appearance'),
                          _buildThemeSettings(context),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Language'),
                          _buildLanguageSettings(context),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Units'),
                          _buildUnitSettings(context),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Notifications'),
                          _buildNotificationSettings(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.headlineMedium?.color,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light Theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              activeColor: AppTheme.lightBlue,
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              activeColor: AppTheme.lightBlue,
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              activeColor: AppTheme.lightBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSettings(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return ListTile(
          title: const Text('Language'),
          subtitle: Text(languageProvider.getLanguageName(languageProvider.currentLanguageCode)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(context, languageProvider),
        );
      },
    );
  }

  Widget _buildUnitSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Column(
          children: [
            RadioListTile<String>(
              title: const Text('Celsius (°C)'),
              value: 'celsius',
              groupValue: settingsProvider.temperatureUnit,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setTemperatureUnit(value);
                }
              },
              activeColor: AppTheme.lightBlue,
            ),
            RadioListTile<String>(
              title: const Text('Fahrenheit (°F)'),
              value: 'fahrenheit',
              groupValue: settingsProvider.temperatureUnit,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setTemperatureUnit(value);
                }
              },
              activeColor: AppTheme.lightBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return SwitchListTile(
          title: const Text('Weather Notifications'),
          subtitle: const Text('Get notified about weather changes'),
          value: settingsProvider.notificationsEnabled,
          onChanged: (value) {
            settingsProvider.setNotifications(value);
          },
          activeColor: AppTheme.lightBlue,
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languageProvider.supportedLanguages.length,
            itemBuilder: (context, index) {
              final languageCode = languageProvider.supportedLanguages.keys.elementAt(index);
              final languageName = languageProvider.supportedLanguages[languageCode]!;
              
              return RadioListTile<String>(
                title: Text(languageName),
                value: languageCode,
                groupValue: languageProvider.currentLanguageCode,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: AppTheme.lightBlue,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
