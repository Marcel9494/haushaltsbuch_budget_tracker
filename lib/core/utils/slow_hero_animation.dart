import 'package:flutter/material.dart';

import '../consts/animation_consts.dart';

Route slowHeroRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: createBookingPageAnimationDurationInMs),
    reverseTransitionDuration: Duration(milliseconds: createBookingPageReverseAnimationDurationInMs),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
