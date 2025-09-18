import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'audio_list_screen.dart';
import 'player_screen.dart';
import 'playlist_screen.dart';
import 'package:nxade_music/l10n/app_localizations.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const AudioListScreen(),
    const PlayerScreen(),
    const PlaylistScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    Color textColor = theme.textColor;
    if (theme.backgroundImage != null) {
      textColor = _calculateTextColorFromImage(theme.backgroundImage!);
    } else if (theme.gradientColors != null) {
      final endColor = theme.gradientColors!.last;
      textColor = endColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    BoxDecoration bottomBarDecoration;
    if (theme.backgroundImage != null) {
      // Resim temalarında tamamen şeffaf
      bottomBarDecoration = const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      );
    } else if (theme.gradientColors != null) {
      // Gradyan temalarında gradyanın son rengini kullan
      bottomBarDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.gradientColors!.last,
            theme.gradientColors!.first,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      );
    } else {
      // Solid renk temalarında tema rengini kullan
      bottomBarDecoration = BoxDecoration(
        color: theme.accentColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          image: theme.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(theme.backgroundImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.05),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: theme.gradientColors != null
              ? LinearGradient(
                  colors: theme.gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  tileMode: TileMode.clamp,
                )
              : null,
          color: theme.backgroundImage == null && theme.gradientColors == null
              ? theme.backgroundColor
              : null,
        ),
        child: Navigator(
          key: ValueKey(_selectedIndex),
          onGenerateRoute: (settings) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => _screens[_selectedIndex],
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
                final fadeAnimation = animation.drive(
                  fadeTween.chain(CurveTween(curve: Curves.easeInOut)),
                );
                final scaleTween = Tween<double>(begin: 0.95, end: 1.0);
                final scaleAnimation = animation.drive(
                  scaleTween.chain(CurveTween(curve: Curves.easeOutQuad)),
                );
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
              reverseTransitionDuration: const Duration(milliseconds: 400),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: bottomBarDecoration,
        clipBehavior: Clip.hardEdge,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.accentColor,
          unselectedItemColor: textColor.withOpacity(0.7),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: textColor,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: textColor.withOpacity(0.7),
          ),
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.headset,
                  size: _selectedIndex == 0 ? 28 : 24,
                  color: _selectedIndex == 0 ? theme.accentColor : textColor.withOpacity(0.7),
                ),
              ),
              label: AppLocalizations.of(context)!.audio_list,
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.disc_full,
                  size: _selectedIndex == 1 ? 28 : 24,
                  color: _selectedIndex == 1 ? theme.accentColor : textColor.withOpacity(0.7),
                ),
              ),
              label: AppLocalizations.of(context)!.player,
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.library_music,
                  size: _selectedIndex == 2 ? 28 : 24,
                  color: _selectedIndex == 2 ? theme.accentColor : textColor.withOpacity(0.7),
                ),
              ),
              label: AppLocalizations.of(context)!.playlist,
            ),
          ],
        ),
      ),
    );
  }

  Color _calculateTextColorFromImage(String imagePath) {
    return Colors.white; // Placeholder
  }
}