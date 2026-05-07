import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import routing and theme configurations
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

/// The root widget of the Nisarga application.
/// 
/// This widget sets up the [MaterialApp] with the custom GoRouter configuration
/// and listens to the [ThemeProvider] to dynamically switch between Light and Dark mode.
class NisargaApp extends StatelessWidget {
  const NisargaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds the MaterialApp whenever the theme state changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          // Disable the debug banner in the top right corner
          debugShowCheckedModeBanner: false,
          
          title: "Nisarga",
          
          // Define standard light and dark themes
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          
          // Apply the current theme mode selected by the user
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          
          // Inject the GoRouter configuration for declarative routing
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}