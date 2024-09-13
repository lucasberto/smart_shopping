import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/providers/auth_provider.dart';
import 'package:smart_shopping/screens/new_shopping_list.dart';
import 'package:smart_shopping/widgets/user_shopping_lists.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingListsScreen extends ConsumerStatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  ConsumerState<ShoppingListsScreen> createState() =>
      _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends ConsumerState<ShoppingListsScreen> {
  void signOut() async {
    await ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: currentMaterialScheme.onPrimary,
        ),
        title: Row(
          children: [
            Icon(
              Icons.checklist,
              color: currentMaterialScheme.onPrimary,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              'Listas Inteligentes',
              style: TextStyle(
                  color: currentMaterialScheme.onPrimary, letterSpacing: 1),
            ),
          ],
        ),
        backgroundColor: currentMaterialScheme.primary,
        elevation: 0.4,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const NewShoppingListScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      backgroundColor: currentMaterialScheme.surfaceContainer,
      body: const SingleChildScrollView(child: UserShoppingLists()),
    );
  }
}
