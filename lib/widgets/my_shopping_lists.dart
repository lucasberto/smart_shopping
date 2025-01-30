import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:smart_shopping/widgets/shopping_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyShoppingLists extends StatefulWidget {
  const MyShoppingLists({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<MyShoppingLists> createState() => _MyShoppingListsState();
}

class _MyShoppingListsState extends State<MyShoppingLists> {
  final database = FirestoreDatabase();

  final _confirmationController = TextEditingController();

  void _deleteShoppingList(String id) async {
    await database.deleteShoppingList(id: id);
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.listDeletedMessage),
      ));
    }
  }

  Future<bool> removeShoppingList(String id) async {
    _confirmationController.clear();
    return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:
                    Text(AppLocalizations.of(context)!.listDeleteButtonLabel),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!
                        .listDeleteConfirmationMessage),
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!
                        .listDeleteConfirmationText),
                    TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .listDeleteConfirmHintText,
                      ),
                      controller: _confirmationController,
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child:
                        Text(AppLocalizations.of(context)!.cancelButtonLabel),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_confirmationController.text ==
                          AppLocalizations.of(context)!
                              .listDeleteConfirmHintText) {
                        _deleteShoppingList(id);
                        Navigator.of(context).pop(true);
                      } else {
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: Text(
                        AppLocalizations.of(context)!.deleteButtonLabelUpper),
                  ),
                ],
              );
            }) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: database.shoppingListsStream(isShared: false),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noListsText),
          );
        }

        if (snapshots.hasError) {
          return Center(
            child: Text(AppLocalizations.of(context)!.somethingWentWrong),
          );
        }

        final loadedShoppingLists = snapshots.data!.docs;

        return Column(
          children: loadedShoppingLists.map<Widget>((shoppingList) {
            return Column(
              children: [
                Dismissible(
                  key: ValueKey(shoppingList.id),
                  confirmDismiss: ((direction) =>
                      removeShoppingList(shoppingList.id)),
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color.fromARGB(255, 255, 214, 212),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.deleteButtonLabelUpper,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 194, 47, 36),
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: ShoppingListTile(
                    listItem: shoppingList,
                    isShared: false,
                  ),
                ),
                if (shoppingList != loadedShoppingLists.last)
                  Divider(
                    indent: 5,
                    endIndent: 5,
                    color: currentMaterialScheme.outlineVariant,
                  ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
