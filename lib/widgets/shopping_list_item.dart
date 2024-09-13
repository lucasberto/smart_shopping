import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';

class ShoppingListItem extends StatelessWidget {
  const ShoppingListItem({
    super.key,
    required this.name,
    required this.id,
    required this.quantity,
    required this.checked,
    required this.onCheckItem,
  });

  final String id;
  final String name;
  final int quantity;
  final bool checked;
  final void Function(String itemId, bool checked) onCheckItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: (checked) {
          onCheckItem(id, checked!);
        },
        value: checked,
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              decoration: TextDecoration.combine(
                [checked ? TextDecoration.lineThrough : TextDecoration.none],
              ),
              color: checked
                  ? currentMaterialScheme.onSurface.withAlpha(180)
                  : null,
              letterSpacing: 0.8,
            ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: currentMaterialScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          quantity.toString(),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: currentMaterialScheme.onPrimary,
              ),
        ),
      ),
      dense: true,
    );
  }
}
