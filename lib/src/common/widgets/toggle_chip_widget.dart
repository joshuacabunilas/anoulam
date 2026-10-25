import 'package:flutter/material.dart';

/// An on/off chip whose width never changes when toggled.
///
/// Material's [FilterChip] adds a checkmark in front of the label when
/// selected, which widens it and reflows the chips around it. This keeps a
/// fixed icon slot that swaps between [icon] and a check instead, so rows
/// stay put under the thumb and selection is never shown by colour alone.
class ToggleChipWidget extends StatelessWidget {
  const ToggleChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon = Icons.add,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  /// Shown when not selected.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      showCheckmark: false,
      avatar: ExcludeSemantics(
        child: Icon(
          selected ? Icons.check : icon,
          size: 18,
          color: selected ? scheme.onPrimary : scheme.onSurface,
        ),
      ),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
