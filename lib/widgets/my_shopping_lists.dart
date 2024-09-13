import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:smart_shopping/widgets/shopping_list_tile.dart';

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
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lista removida com sucesso!'),
      ));
    }
  }

  Future<bool> removeShoppingList(String id) async {
    _confirmationController.clear();
    return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Remover Lista'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tem certeza que deseja remover esta lista?'),
                    const SizedBox(height: 20),
                    const Text(
                        'Digite CONFIRMAR abaixo para confirmar a remocão:'),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'CONFIRMAR',
                      ),
                      controller: _confirmationController,
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_confirmationController.text == 'CONFIRMAR') {
                        _deleteShoppingList(id);
                        Navigator.of(context).pop(true);
                      } else {
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: const Text('Remover'),
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
          return const Center(
            child: Text('Sem listas de compra. Que tal criar uma?'),
          );
        }

        if (snapshots.hasError) {
          return const Center(
            child: Text('Algo deu errado  =('),
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
                    child: const Row(
                      children: [
                        Text(
                          'EXCLUIR',
                          style: TextStyle(
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
