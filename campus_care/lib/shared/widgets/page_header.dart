import 'package:flutter/material.dart';

/// Back button (optional), CUT name and optional action widgets (such as the
/// notification bell), as in the Figma pages. The header knows nothing about
/// notifications: screens decide which actions to show.
/// Add the CUT logo image here once exported (assets/images/cut_logo.png).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.showBack = true,
    this.actions = const [],
    this.trailing,
    this.onBack,
  });

  final bool showBack;

  /// Replaces the default "go back" (used by multi-step flows).
  final VoidCallback? onBack;

  /// Shown on the right, in order (e.g. the notification bell).
  final List<Widget> actions;

  /// Shown after [actions] (e.g. the profile avatar on Home).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          IconButton.filledTonal(
            tooltip: 'Back',
            icon: const Icon(Icons.chevron_left),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
        ],
        const Icon(Icons.school_outlined, color: Colors.white, size: 30),
        const SizedBox(width: 8),
        const Flexible(
          child: Text(
            'Central University\nof Technology',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.2),
          ),
        ),
        const Spacer(),
        ...actions,
        if (trailing != null) trailing!,
      ],
    );
  }
}
