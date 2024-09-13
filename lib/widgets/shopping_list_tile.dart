import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/screens/shopping_list.dart';
import 'package:smart_shopping/services/firestore_database.dart';

class ShoppingListTile extends StatelessWidget {
  const ShoppingListTile({
    super.key,
    required this.listItem,
    required this.isShared,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> listItem;
  final bool isShared;

  @override
  Widget build(BuildContext context) {
    final sharedWithCount = listItem.data().containsKey('shared_with')
        ? listItem['shared_with'].length
        : 0;

    Widget? sharedIconWidget;

    if (sharedWithCount > 0) {
      sharedIconWidget = FittedBox(
        child: Row(
          children: [
            Icon(
              Icons.people,
              size: 20,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            const SizedBox(width: 4),
            Text(
              '$sharedWithCount',
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => ShoppingListScreen(
            shoppingListId: listItem.id,
            shoppingListName: listItem['name'],
            isShared: isShared,
          ),
        ));
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
        title: Text(
          listItem['name'],
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: 0.8,

                // color: currentMaterialScheme.onSurface,
              ),
        ),
        subtitle: Row(children: [
          StreamBuilder(
              stream: FirestoreDatabase().shoppingListItemsStream(
                  shoppingListId: listItem.id, isShared: isShared),
              builder: (BuildContext ctx, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Text(
                          '${snapshot.data!.docs.length} item(s)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ]),
        trailing: Wrap(
          children: [
            if (sharedWithCount > 0) sharedIconWidget!,
            const SizedBox(width: 20),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).textTheme.bodyLarge!.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
