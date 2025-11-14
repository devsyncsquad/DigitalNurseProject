import 'package:flutter/material.dart';

import '../theme/modern_surface_theme.dart';

/// Provides a gradient-backed scaffold that matches the modern dashboard
/// surfaces while still exposing the familiar [Scaffold] API.
class ModernScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool safeAreaBottom;
  final bool safeAreaTop;

  const ModernScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.safeAreaBottom = true,
    this.safeAreaTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: body,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: ModernSurfaceTheme.backgroundGradient(context),
      ),
      child: scaffold,
    );
  }
}

