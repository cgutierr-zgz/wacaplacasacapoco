import 'package:flutter/material.dart';

enum SnackbarType {
  generic,
  error;

  Color get color => switch (this) {
        SnackbarType.generic => Colors.green,
        SnackbarType.error => Colors.red,
      };

  IconData get icon => switch (this) {
        SnackbarType.generic => Icons.check,
        SnackbarType.error => Icons.error,
      };
}

extension BuildContextX on BuildContext {
  void showSnackBar(
    String message, {
    SnackbarType type = SnackbarType.generic,
  }) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(type.icon, color: type.color),
              Text(
                message,
                style: TextStyle(color: type.color),
              ),
            ],
          ),
        ),
      );
  }
}
