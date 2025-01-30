import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/screens/manage_shares.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:smart_shopping/widgets/new_item.dart';
import 'package:smart_shopping/widgets/shopping_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({
    super.key,
    required this.shoppingListId,
    required this.shoppingListName,
    required this.isShared,
  });
  final bool isShared;
  final String shoppingListId;
  final String shoppingListName;

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  final database = FirestoreDatabase();

  void _removeItem(String id) async {
    await database.deleteShoppingListItem(
      shoppingListId: widget.shoppingListId,
      id: id,
      isShared: widget.isShared,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.listItemRemovedMessage),
      ));
    }
  }

  void _toggleItem(String id, bool checked) async {
    await database.toggleShoppingListItem(
      shoppingListId: widget.shoppingListId,
      id: id,
      checked: checked,
      isShared: widget.isShared,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: currentMaterialScheme.onPrimary,
        ),
        title: Text(
          AppLocalizations.of(context)!.listPageTitle,
          style: TextStyle(
              color: currentMaterialScheme.onPrimary, letterSpacing: 1),
        ),
        backgroundColor: currentMaterialScheme.primary,
        elevation: 0.1,
        actions: [
          if (!widget.isShared)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ManageSharesScreen(
                      shoppingListId: widget.shoppingListId,
                      shoppingListName: widget.shoppingListName,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.share,
                color: currentMaterialScheme.onPrimary,
              ),
            ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                useSafeArea: true,
                isScrollControlled: true,
                context: context,
                builder: (ctx) => NewItem(
                  uid: user.uid,
                  shoppingListId: widget.shoppingListId,
                  isShared: widget.isShared,
                ),
              );
            },
            icon: Icon(
              Icons.add,
              color: currentMaterialScheme.onPrimary,
            ),
          ),
        ],
      ),
      backgroundColor: currentMaterialScheme.surfaceContainer,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: currentMaterialScheme.onSurface,
                  size: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.shoppingListName,
                    style: TextStyle(
                      color: currentMaterialScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: database.shoppingListItemsStream(
                    shoppingListId: widget.shoppingListId,
                    isShared: widget.isShared),
                builder: (context, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.noItemsInList),
                    );
                  }

                  if (snapshots.hasError) {
                    return Center(
                      child: Text(
                          AppLocalizations.of(context)!.somethingWentWrong),
                    );
                  }

                  final loadedItems = snapshots.data!.docs;

                  return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: loadedItems.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Dismissible(
                              key: ValueKey(loadedItems[index].id),
                              onDismissed: ((direction) =>
                                  _removeItem(loadedItems[index].id)),
                              background: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                color: const Color.fromARGB(255, 255, 214, 212),
                                child: Row(children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .deleteButtonLabelUpper,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 194, 47, 36),
                                    ),
                                  ),
                                ]),
                              ),
                              child: ShoppingListItem(
                                id: loadedItems[index].id,
                                name: loadedItems[index]['name'], //NON-NLS
                                quantity: loadedItems[index]
                                    ['quantity'], //NON-NLS
                                checked: loadedItems[index]
                                    ['checked'], //NON-NLS
                                onCheckItem: _toggleItem,
                              ),
                            ),
                            Divider(
                              indent: 30,
                              endIndent: 30,
                              color: currentMaterialScheme.outlineVariant,
                            ),
                          ],
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
