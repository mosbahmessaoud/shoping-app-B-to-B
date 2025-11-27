import 'package:flutter/material.dart';
import '../theme_toggle_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showThemeToggle;
  final Widget? leading;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showThemeToggle = true,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      backgroundColor: isDark 
          ? theme.colorScheme.surface 
          : theme.colorScheme.primaryContainer,
      foregroundColor: isDark 
          ? theme.colorScheme.onSurface 
          : theme.colorScheme.onPrimaryContainer,
      elevation: 0,
      actions: [
        if (showThemeToggle) const ThemeToggleButton(),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}