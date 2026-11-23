import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../../core/consts/animation_consts.dart';
import '../../../../../core/utils/app_theme_colors.dart';

/// Gemeinsames Grundgerüst der Authentifizierungsseiten.
///
/// - zentrierter, in der Breite begrenzter Inhalt (auch auf Tablets gut lesbar)
/// - die Seite passt ohne Scrollen auf den Bildschirm: das Icon im [AuthHeader]
///   wird dafür zwischen [minIconSize] und [maxIconSize] an den Platz angepasst
/// - bei geöffneter Tastatur bleibt das Layout gleich und lässt sich scrollen
/// - dezenter Farbverlauf im Hintergrund und sanftes Einblenden beim Öffnen
/// - Tippen außerhalb der Eingabefelder schließt die Tastatur
class AuthScaffold extends StatefulWidget {
  static const double maxIconSize = 128.0;
  static const double minIconSize = 56.0;

  final Widget child;
  final Widget? footer;
  final VoidCallback? onBackPressed;

  const AuthScaffold({
    super.key,
    required this.child,
    this.footer,
    this.onBackPressed,
  });

  /// Größe, in der das Icon im Kopfbereich der Seite dargestellt werden soll.
  static double iconSizeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AuthIconSizeScope>()?.iconSize ?? maxIconSize;
  }

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> with SingleTickerProviderStateMixin {
  static const double _maxContentWidth = 440.0;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  double _iconSize = AuthScaffold.maxIconSize;

  /// Sichtbare Höhe ohne geöffnete Tastatur.
  double? _viewportHeight;
  double? _topBarHeight;
  double? _contentHeight;
  double? _footerHeight;

  /// Icongröße, mit der [_contentHeight] gemessen wurde.
  double? _measuredIconSize;

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

  bool _isKeyboardOpen(BuildContext context) => MediaQuery.viewInsetsOf(context).bottom > 0.0;

  /// Verkleinert oder vergrößert das Icon so, dass die ganze Seite ohne Scrollen sichtbar ist.
  void _fitIconToViewport() {
    if (!mounted || _isKeyboardOpen(context)) {
      return;
    }
    final viewportHeight = _viewportHeight;
    final topBarHeight = _topBarHeight;
    final contentHeight = _contentHeight;
    final footerHeight = _footerHeight;
    final measuredIconSize = _measuredIconSize;
    if (viewportHeight == null || topBarHeight == null || contentHeight == null || footerHeight == null || measuredIconSize == null) {
      return;
    }

    final double overflow = topBarHeight + contentHeight + footerHeight - viewportHeight;
    final double fittedIconSize = (measuredIconSize - overflow).floorToDouble().clamp(AuthScaffold.minIconSize, AuthScaffold.maxIconSize).toDouble();
    if ((fittedIconSize - _iconSize).abs() < 1.0) {
      return;
    }
    setState(() {
      _iconSize = fittedIconSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.appAccentColor;
    final bool isKeyboardOpen = _isKeyboardOpen(context);
    final double iconSize = _iconSize;

    if (isKeyboardOpen == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitIconToViewport());
    }

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
                  // Bei geöffneter Tastatur behält die Seite ihre Höhe und wird scrollbar,
                  // damit sich das Layout (und die Icongröße) nicht verändert.
                  if (isKeyboardOpen == false || _viewportHeight == null) {
                    _viewportHeight = constraints.maxHeight;
                  }
                  final double minHeight = isKeyboardOpen ? _viewportHeight! : constraints.maxHeight;

                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MeasureHeight(
                            onHeightChanged: (height) {
                              _topBarHeight = height;
                              _fitIconToViewport();
                            },
                            child: _buildTopBar(context),
                          ),
                          _MeasureHeight(
                            onHeightChanged: (height) {
                              _contentHeight = height;
                              _measuredIconSize = iconSize;
                              _fitIconToViewport();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: _AuthIconSizeScope(
                                      iconSize: iconSize,
                                      child: widget.child,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _MeasureHeight(
                            onHeightChanged: (height) {
                              _footerHeight = height;
                              _fitIconToViewport();
                            },
                            child: widget.footer == null
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                                    child: widget.footer,
                                  ),
                          ),
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

class _AuthIconSizeScope extends InheritedWidget {
  final double iconSize;

  const _AuthIconSizeScope({
    required this.iconSize,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AuthIconSizeScope oldWidget) => oldWidget.iconSize != iconSize;
}

/// Meldet die Höhe des Kindes nach jeder Größenänderung.
class _MeasureHeight extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onHeightChanged;

  const _MeasureHeight({
    required this.onHeightChanged,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasureHeight(onHeightChanged);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasureHeight renderObject) {
    renderObject.onHeightChanged = onHeightChanged;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  ValueChanged<double> onHeightChanged;
  double? _lastHeight;

  _RenderMeasureHeight(this.onHeightChanged);

  @override
  void performLayout() {
    super.performLayout();
    final double height = size.height;
    if (height == _lastHeight) {
      return;
    }
    _lastHeight = height;
    final ValueChanged<double> callback = onHeightChanged;
    WidgetsBinding.instance.addPostFrameCallback((_) => callback(height));
  }
}
