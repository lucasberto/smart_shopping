import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/Extensions/email_validator.dart';
import 'package:smart_shopping/services/firestore_database.dart';
import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShareShoppingList extends StatefulWidget {
  const ShareShoppingList({super.key, required this.shoppingListId});

  final String shoppingListId;

  @override
  State<ShareShoppingList> createState() => _ShareShoppingListState();
}

class _ShareShoppingListState extends State<ShareShoppingList> {
  final database = FirestoreDatabase();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _errorText = ''; // NON-NLS
  bool isProcessing = false;

  void _handleSubmit() async {
    setState(() {
      _errorText = ''; // NON-NLS
      isProcessing = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = FirebaseAuth.instance.currentUser!;

      if (currentUser.email == _emailController.text) {
        setState(() {
          _errorText =
              AppLocalizations.of(context)!.cannotShareWithYourselfError;
          isProcessing = false;
        });
        return;
      }

      final users = await FirebaseFirestore.instance
          .collection('users') // NON-NLS
          .where('email', isEqualTo: _emailController.text) // NON-NLS
          .get();

      if (users.docs.isNotEmpty) {
        final result = await database.shareShoppingList(
          shoppingListId: widget.shoppingListId,
          receiver: users.docs.first,
        );

        if (!result[nonNls('success')]) {
          setState(() {
            _errorText = result['error']; // NON-NLS
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.listSharedMessage),
            ));
            Navigator.of(context).pop();
          }
        }
      } else {
        setState(() {
          _errorText = AppLocalizations.of(context)!.noUserFoundError;
        });
      }
    }
    setState(() {
      isProcessing = false;
    });
  }

  String? _validateEmail(String value) {
    if (!value.isValidEmail()) {
      return AppLocalizations.of(context)!.invalidEmailError;
    }

    return null;
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
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.emailShareLabel,
                      ),
                      maxLength: 50,
                      enableSuggestions: true,
                      textCapitalization: TextCapitalization.none,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => _validateEmail(value.toString()),
                    ),
                  ),
                ),
              ],
            ),
            if (_errorText.isNotEmpty)
              Text(
                _errorText,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isProcessing ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator()
                      : Text(
                          AppLocalizations.of(context)!.addButtonLabel,
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
                  child: Text(AppLocalizations.of(context)!.cancelButtonLabel),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
