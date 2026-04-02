import 'package:flutter/material.dart';

class DialogWrapper extends StatelessWidget {
  const DialogWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: child,
    );
  }
}

class KeyboardAwareDialog extends StatelessWidget {
  const KeyboardAwareDialog({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      ),
    );
  }
}
