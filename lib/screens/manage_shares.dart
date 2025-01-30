import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:smart_shopping/widgets/share_shopping_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';

class ManageSharesScreen extends StatefulWidget {
  const ManageSharesScreen({
    super.key,
    required this.shoppingListId,
    required this.shoppingListName,
  });

  final String shoppingListId;
  final String shoppingListName;

  @override
  State<ManageSharesScreen> createState() => _ManageSharesScreenState();
}

class _ManageSharesScreenState extends State<ManageSharesScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  void removeShare(String userId, String shoppingListId) async {
    await FirestoreDatabase().removeShare(
      userId: userId,
      shoppingListId: shoppingListId,
    );
    setState(() {});
  }

  void showAddModal() async {
    await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) =>
          ShareShoppingList(shoppingListId: widget.shoppingListId),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<Map<String, dynamic>>> usersFuture = FirestoreDatabase()
        .getSharedWithUsers(shoppingListId: widget.shoppingListId);

    return Scaffold(
      backgroundColor: currentMaterialScheme.surfaceContainer,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: currentMaterialScheme.onPrimary,
        ),
        title: Text(
          AppLocalizations.of(context)!.manageSharesPageTitle,
          style: TextStyle(
            color: currentMaterialScheme.onPrimary,
          ),
        ),
        backgroundColor: currentMaterialScheme.primary,
        elevation: 0.1,
        actions: [
          IconButton(
            onPressed: showAddModal,
            icon: Icon(
              Icons.add,
              color: currentMaterialScheme.onPrimary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist,
                    color: currentMaterialScheme.onSurface,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Text(widget.shoppingListName,
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.sharedWith),
              const SizedBox(height: 16),
              FutureBuilder(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child:
                          Text(AppLocalizations.of(context)!.listNotSharedYet),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          AppLocalizations.of(context)!.somethingWentWrong),
                    );
                  }
                  final users = snapshot.data!;
                  return Column(
                    children: users
                        .map<Widget>(
                          (user) => Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                radius: 24,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user[nonNls('username')],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 18),
                                    ),
                                    Text(
                                      user[nonNls('email')],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              ElevatedButton(
                                onPressed: () {
                                  removeShare(user[nonNls('uid')],
                                      widget.shoppingListId);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                  backgroundColor:
                                      const Color.fromARGB(255, 253, 196, 196),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .removeButtonLabel,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 182, 24, 13),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          )),
    );
  }
}
