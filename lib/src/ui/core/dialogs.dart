import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'theme.dart';

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(loc.logoutConfirmationTitle),
      content: Text(loc.logoutConfirmationMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(loc.cancelAction),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: EdenredColors.redAlert,
            foregroundColor: Colors.white,
            minimumSize: Size.zero,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(loc.logoutConfirmationConfirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
