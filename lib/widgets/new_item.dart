import 'package:flutter/material.dart';
import 'package:smart_shopping/services/firestore_database.dart';

class NewItem extends StatefulWidget {
  const NewItem({
    super.key,
    required this.uid,
    required this.shoppingListId,
    required this.isShared,
  });

  final String uid;
  final String shoppingListId;
  final bool isShared;

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final database = FirestoreDatabase();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _quantityController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';
  }

  void _addItem() async {
    if (_nameController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        int.tryParse(_quantityController.text) == null) {
      return;
    } else {
      setState(() {
        _isProcessing = true;
      });
      await database.createShoppingListItem(
          shoppingListId: widget.shoppingListId,
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
          isShared: widget.isShared);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kbSpace = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, kbSpace + 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nome do item'),
                    maxLength: 50,
                    autocorrect: true,
                    enableSuggestions: true,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Quantidade'),
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
