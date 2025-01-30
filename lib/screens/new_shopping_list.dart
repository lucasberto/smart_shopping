import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewShoppingListScreen extends StatefulWidget {
  const NewShoppingListScreen({super.key});

  @override
  State<NewShoppingListScreen> createState() => _NewShoppingListScreenState();
}

class _NewShoppingListScreenState extends State<NewShoppingListScreen> {
  final _listNameController = TextEditingController();

  final database = FirestoreDatabase();

  @override
  void dispose() {
    super.dispose();
    _listNameController.dispose();
  }

  void _submit() async {
    if (_listNameController.text.trim().isEmpty) {
      return;
    }

    await database.createShoppingList(name: _listNameController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.listCreatedMessage),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentMaterialScheme.surfaceContainer,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: currentMaterialScheme.onPrimary,
        ),
        title: Text(
          AppLocalizations.of(context)!.newListPageTitle,
          style: TextStyle(
            color: currentMaterialScheme.onPrimary,
          ),
        ),
        backgroundColor: currentMaterialScheme.primary,
        elevation: 0.1,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    autofocus: true,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.listName),
                    controller: _listNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentMaterialScheme.primary,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.createListButtonLabel,
                    style: TextStyle(
                      color: currentMaterialScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.cancelButtonLabel),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
