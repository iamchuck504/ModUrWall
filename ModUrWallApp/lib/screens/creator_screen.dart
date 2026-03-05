import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/wallpaper_background.dart';

class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  AppTheme currentTheme = AppTheme.dark;
  String? selectedGenre;
  String? selectedStyle;
  String? selectedFlow;
  bool isLoading = false;
  String? imageUrl;

  final Map<String, List<String>> options = {
    'genre': ['abstract', 'nature', 'cyberpunk', 'minimal', 'cosmic', 'urban'],
    'style': ['geometric', 'organic', 'glitch', 'gradient', 'fractal', 'neon'],
    'flow': ['smooth', 'chaotic', 'rhythmic', 'static', 'dynamic', 'pulse'],
  };

  void selectOption(String type) {
    final random = Random();
    final optionsList = options[type]!;
    final selected = optionsList[random.nextInt(optionsList.length)];

    setState(() {
      if (type == 'genre') selectedGenre = selected;
      if (type == 'style') selectedStyle = selected;
      if (type == 'flow') selectedFlow = selected;

      if (selectedGenre != null && selectedStyle != null && selectedFlow != null) {
        generateImage();
      }
    });
  }

  Future<void> generateImage() async {
    setState(() => isLoading = true);

    // Simulate image generation — replace with real API call in v1
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      imageUrl = 'https://placehold.co/1920x1080/0a0e1a/0088ff?text='
          '${Uri.encodeComponent('$selectedGenre-$selectedStyle-$selectedFlow')}';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentTheme.bg,
      body: Stack(
        children: [
          WallpaperBackground(theme: currentTheme),
          Column(
            children: [
              // Top 2/3 — Image display
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: currentTheme.darker.withValues(alpha: 0.8),
                    border: Border(
                      bottom: BorderSide(color: currentTheme.accent, width: 3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (imageUrl == null && !isLoading)
                        Center(
                          child: Text(
                            '[ awaiting creation ]',
                            style: TextStyle(
                              color: currentTheme.dim,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: currentTheme.accent,
                          ),
                        ),
                      if (imageUrl != null && !isLoading)
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: currentTheme.dim, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: currentTheme.accent.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: currentTheme.darker,
                                  child: Center(
                                    child: Text(
                                      'Image generation complete',
                                      style:
                                          TextStyle(color: currentTheme.accent),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      // Back button
                      Positioned(
                        top: 20,
                        left: 20,
                        child: _BackButton(
                          onPressed: () => Navigator.pop(context),
                          theme: currentTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom 1/3 — Control panel
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    CreatorControlSquare(
                      label: 'GENRE',
                      value: selectedGenre ?? '—',
                      onPressed: () => selectOption('genre'),
                      theme: currentTheme,
                      isActive: selectedGenre != null,
                    ),
                    CreatorControlSquare(
                      label: 'STYLE',
                      value: selectedStyle ?? '—',
                      onPressed: () => selectOption('style'),
                      theme: currentTheme,
                      isActive: selectedStyle != null,
                    ),
                    CreatorControlSquare(
                      label: 'FLOW',
                      value: selectedFlow ?? '—',
                      onPressed: () => selectOption('flow'),
                      theme: currentTheme,
                      isActive: selectedFlow != null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreatorControlSquare extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onPressed;
  final AppTheme theme;
  final bool isActive;

  const CreatorControlSquare({
    super.key,
    required this.label,
    required this.value,
    required this.onPressed,
    required this.theme,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          splashColor: theme.accent.withValues(alpha: 0.5),
          highlightColor: theme.accent.withValues(alpha: 0.3),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? theme.accent : theme.dim,
                width: 2,
              ),
              color: isActive
                  ? theme.accent.withValues(alpha: 0.2)
                  : theme.darker.withValues(alpha: 0.6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? theme.accent : theme.fg,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: isActive ? theme.fg : theme.dim,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple back button — local to this screen
class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final AppTheme theme;

  const _BackButton({required this.onPressed, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.accent, width: 2),
            color: theme.darker.withValues(alpha: 0.8),
          ),
          child: Text(
            '← BACK',
            style: TextStyle(
              color: theme.accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ),
      ),
    );
  }
}
