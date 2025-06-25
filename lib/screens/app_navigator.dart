import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'audio_list_screen.dart';
import 'player_screen.dart';
import 'playlist_screen.dart';
import 'package:akn_music/l10n/app_localizations.dart';

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AudioListScreen(),
    PlayerScreen(),
    PlaylistScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Alt navigasyon bar rengini belirle
    Color bottomBarColor;
    if (theme.backgroundImage != null || theme.gradientColors != null) {
      // Resim veya gradyan temalarda şeffaf
      bottomBarColor = Colors.transparent;
    } else {
      // Diğer temalarda tema rengi
      bottomBarColor = theme.backgroundColor;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _screens[_selectedIndex],
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bottomBarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.accentColor,
          unselectedItemColor: theme.textColor.withOpacity(0.6),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.headset),
              label: AppLocalizations.of(context)!.audio_list,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.disc_full),
              label: AppLocalizations.of(context)!.player,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: AppLocalizations.of(context)!.playlist,
            ),
          ],
        ),
      ),
    );
  }
}