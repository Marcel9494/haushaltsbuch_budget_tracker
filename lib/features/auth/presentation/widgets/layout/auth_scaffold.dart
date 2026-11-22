import 'package:flutter/material.dart';

import '../../../../../core/consts/animation_consts.dart';
import '../../../../../core/utils/app_theme_colors.dart';

/// Gemeinsames Grundgerüst der Authentifizierungsseiten.
///
/// - zentrierter, in der Breite begrenzter Inhalt (auch auf Tablets gut lesbar)
/// - dezenter Farbverlauf im Hintergrund
/// - sanftes Einblenden beim Öffnen der Seite
/// - Footer bleibt unten und überlappt den Inhalt auf kleinen Displays nicht
/// - Tippen außerhalb der Eingabefelder schließt die Tastatur
class AuthScaffold extends StatefulWidget {
  final Widget child;
  final Widget? footer;
  final VoidCallback? onBackPressed;

  const AuthScaffold({
    super.key,
    required this.child,
    this.footer,
    this.onBackPressed,
  });

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> with SingleTickerProviderStateMixin {
  static const double _maxContentWidth = 440.0;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: fadeInAnimationDurationInMs),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: fadeInAnimationDelayInMs), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.appAccentColor;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: -220.0,
              left: -120.0,
              right: -120.0,
              height: 520.0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.5,
                      colors: [
                        accentColor.withValues(alpha: theme.isDark ? 0.16 : 0.12),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTopBar(context),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: widget.child,
                                ),
                              ),
                            ),
                          ),
                          if (widget.footer != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                              child: widget.footer,
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    if (widget.onBackPressed == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, top: 4.0),
        child: IconButton(
          onPressed: widget.onBackPressed,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }
}
