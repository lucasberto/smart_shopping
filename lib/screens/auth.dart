import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_shopping/main.dart';
import 'package:smart_shopping/providers/auth_provider.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = ''; // NON-NLS
  var _enteredPassword = ''; // NON-NLS
  var _enteredUsername = ''; // NON-NLS
  var _isAuthenticating = false;

  void showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  @NonNls
  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });
    if (_isLogin) {
      final result =
          await ref.read(authProvider.notifier).signInWithEmailAndPassword(
                email: _enteredEmail,
                password: _enteredPassword,
              );
      if (!result['success']) {
        showErrorSnackbar(result['error']);
      }
    } else {
      final result =
          await ref.read(authProvider.notifier).signUpWithEmailAndPassword(
                email: _enteredEmail,
                password: _enteredPassword,
                username: _enteredUsername,
              );
      if (!result['success']) {
        showErrorSnackbar(result['error']);
      }
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } on Exception catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentMaterialScheme.surfaceContainerHigh,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 40,
                  right: 40,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppLocalizations.of(context)!.appTitle.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        letterSpacing: 1.5,
                      ),
                    )
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                color: currentMaterialScheme.surfaceContainerHighest,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.emailAddress,
                            ),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains(nonNls('@'))) {
                                return AppLocalizations.of(context)!
                                    .invalidEmailError;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.yourName),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return AppLocalizations.of(context)!
                                      .fieldTooShortError4;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.password),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return AppLocalizations.of(context)!
                                    .passwordTooShortError;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                _isLogin
                                    ? AppLocalizations.of(context)!
                                        .loginButtonLabel
                                    : AppLocalizations.of(context)!
                                        .createAccountButtonLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? AppLocalizations.of(context)!
                                      .createAccountLinkLabel
                                  : AppLocalizations.of(context)!
                                      .alreadyHaveAnAccountLinkLabel),
                            ),
                          if (!_isAuthenticating)
                            ClipRect(
                              child: SizedBox(
                                width: 175,
                                child: SignInButton(
                                  Buttons.GoogleDark,
                                  text: AppLocalizations.of(context)!
                                      .loginWithGoogleButtonLabel,
                                  onPressed: signInWithGoogle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
