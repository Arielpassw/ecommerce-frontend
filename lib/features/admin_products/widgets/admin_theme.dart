import 'package:flutter/material.dart';

class AdminColors {
  static const background = Color(0xFF05060C);
  static const surface = Color(0xFF0D101A);
  static const surfaceAlt = Color(0xFF121522);
  static const border = Color(0x1FFFFFFF);
  static const primary = Color(0xFF7C3CFF);
  static const accent = Color(0xFFB14CFF);
  static const muted = Color(0x99FFFFFF);
}

InputDecoration adminInputDecoration(String label, {IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: AdminColors.surfaceAlt,
    labelStyle: const TextStyle(color: AdminColors.muted),
    prefixIconColor: AdminColors.muted,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AdminColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AdminColors.accent),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}

ButtonStyle adminFilledButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: AdminColors.primary,
    foregroundColor: Colors.white,
    disabledBackgroundColor: AdminColors.primary.withOpacity(0.4),
    disabledForegroundColor: Colors.white54,
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

ButtonStyle adminTextButtonStyle() {
  return TextButton.styleFrom(
    foregroundColor: AdminColors.accent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class AdminPageShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> actions;
  final Widget child;
  final Widget? leading;

  const AdminPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actions,
    required this.child,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: leading,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AdminColors.primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.border),
              ),
              child: Icon(icon, color: AdminColors.accent, size: 21),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AdminColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.border),
      ),
      child: child,
    );
  }
}

class EmptyAdminState extends StatelessWidget {
  final IconData icon;
  final String title;

  const EmptyAdminState({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AdminColors.accent, size: 42),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
