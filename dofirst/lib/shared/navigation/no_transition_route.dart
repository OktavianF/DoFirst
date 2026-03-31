import 'package:flutter/material.dart';

Route<T> noTransitionRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

Future<T?> pushNoTransition<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(noTransitionRoute<T>(page));
}

Future<T?> pushReplacementNoTransition<T, TO>(
  BuildContext context,
  Widget page,
) {
  return Navigator.of(
    context,
  ).pushReplacement<T, TO>(noTransitionRoute<T>(page));
}
