import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_shopping/main.dart';
import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirestoreDatabase {
  final _db = FirebaseFirestore.instance;

  @NonNls
  Future syncShoppingListItems({
    required bool isShared,
    required String shoppingListId,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final collectionName = isShared ? 'shared_with_me' : 'my_shopping_lists';

    String userId = user.uid;

    if (isShared) {
      final shoppingList =
          await _db.doc('/users/$userId/shared_with_me/$shoppingListId').get();
      if (shoppingList.data() != null) {
        userId = shoppingList.data()!['ownerId'];
      }
    }

    final ownerShoppingList =
        await _db.doc('/users/$userId/my_shopping_lists/$shoppingListId').get();

    final origin = '/users/${user.uid}/$collectionName/$shoppingListId';
    final List<String> destinations = [];

    for (final id in ownerShoppingList.data()!['shared_with']) {
      if (id != user.uid) {
        destinations.add('/users/$id/shared_with_me/$shoppingListId');
      }
    }

    if (isShared) {
      destinations.add('/users/$userId/my_shopping_lists/$shoppingListId');
    }

    // Trazer os itens da lista de compras de origem
    final originItems = await _db.doc(origin).collection('items').get();

    for (final destination in destinations) {
      var batch = _db.batch();
      // Remove todos os itens da lista de destino
      final destinationItems =
          await _db.doc(destination).collection('items').get();

      for (final item in destinationItems.docs) {
        batch.delete(_db.doc(destination).collection('items').doc(item.id));
      }

      await batch.commit();
      batch = _db.batch();

      // Adiciona os itens na lista compartilhada
      for (final item in originItems.docs) {
        batch.set(
          _db.doc(destination).collection('items').doc(item.id),
          item.data(),
        );
      }

      await batch.commit();
    }
  }

  @NonNls
  Stream shoppingListsStream({required bool isShared}) {
    final user = FirebaseAuth.instance.currentUser!;
    return _db
        .collection('users')
        .doc(user.uid)
        .collection(isShared ? 'shared_with_me' : 'my_shopping_lists')
        .orderBy('name', descending: false)
        .snapshots();
  }

  @NonNls
  Future createShoppingList({required String name}) {
    final user = FirebaseAuth.instance.currentUser!;
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('my_shopping_lists')
        .add(
      {
        'name': name,
        'shared_with': [],
      },
    );
  }

  @NonNls
  Future deleteShoppingList({required String id}) async {
    final user = FirebaseAuth.instance.currentUser!;

    final shoppingList =
        await _db.doc('/users/${user.uid}/my_shopping_lists/$id').get();
    if (shoppingList.data() == null) {
      return;
    }

    final batch = _db.batch();

    for (final userId in shoppingList.data()!['shared_with']) {
      batch.delete(_db.doc('/users/$userId/shared_with_me/$id'));
    }

    batch.delete(_db.doc('/users/${user.uid}/my_shopping_lists/$id'));

    return await batch.commit();
  }

  @NonNls
  Future<Map<String, dynamic>> shareShoppingList({
    required String shoppingListId,
    required receiver,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    // Trazer a lista de compras
    final DocumentSnapshot<Map<String, dynamic>> shoppingList = await _db
        .collection('users')
        .doc(currentUser.uid)
        .collection('my_shopping_lists')
        .doc(shoppingListId)
        .get();

    if (shoppingList.data() == null) {
      return {
        'error': AppLocalizations.of(navigatorKey.currentContext!)!
            .listNotFoundError,
        'success': false,
      };
    }

    // Cria a lista de compras no recebedor
    await _db
        .collection('users')
        .doc(receiver.id)
        .collection('shared_with_me')
        .doc(shoppingListId)
        .set({
      ...shoppingList.data()!,
      'ownerId': currentUser.uid,
    });

    // Acrescenta o recebedor na lista original
    await _db
        .collection('users')
        .doc(currentUser.uid)
        .collection('my_shopping_lists')
        .doc(shoppingListId)
        .set({
      'shared_with': FieldValue.arrayUnion([receiver.id]),
    }, SetOptions(merge: true));

    syncShoppingListItems(isShared: false, shoppingListId: shoppingListId);

    return {
      'success': true,
    };
  }

  @NonNls
  Future<List<Map<String, dynamic>>> getSharedWithUsers(
      {required String shoppingListId}) async {
    final user = FirebaseAuth.instance.currentUser!;
    final shoppingList = await _db
        .doc('/users/${user.uid}/my_shopping_lists/$shoppingListId')
        .get();

    if (shoppingList.data() == null) {
      return [];
    }

    final List<Map<String, dynamic>> returnData = [];

    final sharedWithIds = shoppingList.data()!['shared_with'];
    for (final userId in sharedWithIds) {
      final user = await _db.doc('/users/$userId').get();
      if (user.data() != null) {
        returnData.add({...user.data()!, 'uid': userId});
      }
    }

    return returnData;
  }

  @NonNls
  Future removeShare({
    required String userId,
    required String shoppingListId,
  }) async {
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    final batch = _db.batch();

    batch.delete(_db.doc('/users/$userId/shared_with_me/$shoppingListId'));

    batch.update(_db.doc('/users/$ownerId/my_shopping_lists/$shoppingListId'), {
      'shared_with': FieldValue.arrayRemove([userId])
    });

    return batch.commit();
  }

  /* ****************** Shopping List Items ******************** */
  @NonNls
  Stream shoppingListItemsStream(
      {required String shoppingListId, required bool isShared}) {
    final user = FirebaseAuth.instance.currentUser!;
    return _db
        .collection('users')
        .doc(user.uid)
        .collection(isShared ? 'shared_with_me' : 'my_shopping_lists')
        .doc(shoppingListId)
        .collection('items')
        .orderBy('checked', descending: false)
        .orderBy('name')
        .snapshots();
  }

  @NonNls
  Future createShoppingListItem({
    required String shoppingListId,
    required String name,
    required int quantity,
    required bool isShared,
    String ownerId = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    final collectionName = isShared ? 'shared_with_me' : 'my_shopping_lists';

    await _db
        .doc('/users/${user.uid}/$collectionName/$shoppingListId')
        .collection('items')
        .add({
      'name': name,
      'quantity': quantity,
      'createdAt': Timestamp.now(),
      'checked': false,
    });

    syncShoppingListItems(isShared: isShared, shoppingListId: shoppingListId);
  }

  @NonNls
  Future deleteShoppingListItem({
    required String shoppingListId,
    required String id,
    required bool isShared,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    final collectionName = isShared ? 'shared_with_me' : 'my_shopping_lists';

    await _db
        .doc('/users/${user.uid}/$collectionName/$shoppingListId')
        .collection('items')
        .doc(id)
        .delete();

    syncShoppingListItems(isShared: isShared, shoppingListId: shoppingListId);
  }

  @NonNls
  Future toggleShoppingListItem({
    required String shoppingListId,
    required String id,
    required bool isShared,
    required bool checked,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection(isShared ? 'shared_with_me' : 'my_shopping_lists')
        .doc(shoppingListId)
        .collection('items')
        .doc(id)
        .update({'checked': checked});

    syncShoppingListItems(isShared: isShared, shoppingListId: shoppingListId);
  }
}
