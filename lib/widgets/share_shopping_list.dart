import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/Extensions/email_validator.dart';
import 'package:smart_shopping/services/firestore_database.dart';

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
  String _errorText = '';
  bool isProcessing = false;

  void _handleSubmit() async {
    setState(() {
      _errorText = '';
      isProcessing = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = FirebaseAuth.instance.currentUser!;

      if (currentUser.email == _emailController.text) {
        setState(() {
          _errorText = 'Voce não pode compartilhar com você mesmo.';
          isProcessing = false;
        });
        return;
      }

      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (users.docs.isNotEmpty) {
        final result = await database.shareShoppingList(
          shoppingListId: widget.shoppingListId,
          receiver: users.docs.first,
        );

        if (!result['success']) {
          setState(() {
            _errorText = result['error'];
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Lista compartilhada com sucesso!'),
            ));
            Navigator.of(context).pop();
          }
        }
      } else {
        setState(() {
          _errorText = 'Nenhum usuário encontrado com o email informado.';
        });
      }
    }
    setState(() {
      isProcessing = false;
    });
  }

  String? _validateEmail(String value) {
    if (!value.isValidEmail()) {
      return 'Email inválido';
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
                      decoration: const InputDecoration(
                        labelText:
                            'Email da pessoa com quem deseja compartilhar',
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
