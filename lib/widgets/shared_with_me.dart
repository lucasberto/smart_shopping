import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:smart_shopping/widgets/shopping_list_tile.dart';

class SharedWithMe extends StatelessWidget {
  const SharedWithMe({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    final database = FirestoreDatabase();

    return StreamBuilder(
      stream: database.shoppingListsStream(isShared: true),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('Nenhuma lista compartilhada aqui.'),
          );
        }

        if (snapshots.hasError) {
          return const Center(
            child: Text('Algo deu errado  =('),
          );
        }

        final loadedShoppingLists = snapshots.data!.docs;

        return Column(
          children: loadedShoppingLists
              .map<Widget>((shoppingList) => Column(
                    children: [
                      ShoppingListTile(listItem: shoppingList, isShared: true),
                      if (shoppingList != loadedShoppingLists.last)
                        Divider(
                          indent: 5,
                          endIndent: 5,
                          color: currentMaterialScheme.outlineVariant,
                        ),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }
}
