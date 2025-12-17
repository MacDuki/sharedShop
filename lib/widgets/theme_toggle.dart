import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return IconButton(
      icon: Icon(appProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        appProvider.toggleTheme();
      },
      tooltip:
          appProvider.isDarkMode
              ? 'Cambiar a tema claro'
              : 'Cambiar a tema oscuro',
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.light_mode,
          color:
              appProvider.isDarkMode
                  ? Theme.of(context).iconTheme.color?.withOpacity(0.5)
                  : Theme.of(context).iconTheme.color,
        ),
        const SizedBox(width: 8),
        Switch(
          value: appProvider.isDarkMode,
          onChanged: (value) {
            appProvider.setTheme(value);
          },
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.dark_mode,
          color:
              appProvider.isDarkMode
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
      ],
    );
  }
}
