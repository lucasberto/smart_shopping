import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/widgets/my_shopping_lists.dart';
import 'package:smart_shopping/widgets/shared_with_me.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserShoppingLists extends StatelessWidget {
  const UserShoppingLists({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.myShoppingListsTitle,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                MyShoppingLists(user: user),
                const SizedBox(height: 12),
                Divider(color: currentMaterialScheme.outline),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.sharedWithMeTitle,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                SharedWithMe(user: user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
