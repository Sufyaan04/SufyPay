import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================================================
  // CREATE USER
  // =========================================================

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  // =========================================================
  // GET USER
  // =========================================================

  Stream<UserModel?> getUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return UserModel.fromMap(snapshot.data()!);
    });
  }

  // =========================================================
  // ADD MONEY
  // =========================================================

  Future<void> addMoney(String uid, double amount) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    final userRef = _firestore.collection('users').doc(uid);

    final transactionRef = userRef.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception('User profile not found');
      }

      final data = userSnapshot.data();

      final currentBalance =
          (data?['balance'] ?? 0).toDouble();

      final newBalance = currentBalance + amount;

      // Update balance
      transaction.update(userRef, {
        'balance': newBalance,
      });

      // Create transaction record
      transaction.set(transactionRef, {
        'transactionId': transactionRef.id,
        'type': 'credit',
        'amount': amount,
        'description': 'Money Added',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // =========================================================
  // SEND MONEY
  // =========================================================

  Future<void> sendMoney({
    required String senderUid,
    required String receiverUpiId,
    required double amount,
  }) async {
    // ---------------------------------------------------------
    // BASIC VALIDATION
    // ---------------------------------------------------------

    if (receiverUpiId.trim().isEmpty) {
      throw Exception('Please enter receiver UPI ID');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    // ---------------------------------------------------------
    // FIND RECEIVER USING UPI ID
    // ---------------------------------------------------------

    final receiverQuery = await _firestore
        .collection('users')
        .where(
          'upiId',
          isEqualTo: receiverUpiId.trim(),
        )
        .limit(1)
        .get();

    if (receiverQuery.docs.isEmpty) {
      throw Exception('Receiver UPI ID not found');
    }

    final receiverDoc = receiverQuery.docs.first;
    final receiverUid = receiverDoc.id;

    // ---------------------------------------------------------
    // PREVENT SENDING TO YOURSELF
    // ---------------------------------------------------------

    if (receiverUid == senderUid) {
      throw Exception('You cannot send money to yourself');
    }

    final senderRef =
        _firestore.collection('users').doc(senderUid);

    final receiverRef =
        _firestore.collection('users').doc(receiverUid);

    // ---------------------------------------------------------
    // TRANSACTION DOCUMENTS
    // ---------------------------------------------------------

    final senderTransactionRef =
        senderRef.collection('transactions').doc();

    final receiverTransactionRef =
        receiverRef.collection('transactions').doc();

    // ---------------------------------------------------------
    // ATOMIC FIRESTORE TRANSACTION
    // ---------------------------------------------------------

    await _firestore.runTransaction((transaction) async {
      // IMPORTANT:
      // All reads happen BEFORE writes.

      final senderSnapshot =
          await transaction.get(senderRef);

      final receiverSnapshot =
          await transaction.get(receiverRef);

      // -------------------------------------------------------
      // VALIDATE SENDER
      // -------------------------------------------------------

      if (!senderSnapshot.exists) {
        throw Exception('Sender profile not found');
      }

      // -------------------------------------------------------
      // VALIDATE RECEIVER
      // -------------------------------------------------------

      if (!receiverSnapshot.exists) {
        throw Exception('Receiver profile not found');
      }

      // -------------------------------------------------------
      // GET BALANCES
      // -------------------------------------------------------

      final senderData = senderSnapshot.data();
      final receiverData = receiverSnapshot.data();

      final senderBalance =
          (senderData?['balance'] ?? 0).toDouble();

      final receiverBalance =
          (receiverData?['balance'] ?? 0).toDouble();

      // -------------------------------------------------------
      // CHECK SUFFICIENT BALANCE
      // -------------------------------------------------------

      if (senderBalance < amount) {
        throw Exception('Insufficient balance');
      }

      // -------------------------------------------------------
      // CALCULATE NEW BALANCES
      // -------------------------------------------------------

      final newSenderBalance =
          senderBalance - amount;

      final newReceiverBalance =
          receiverBalance + amount;

      // -------------------------------------------------------
      // UPDATE SENDER
      // -------------------------------------------------------

      transaction.update(senderRef, {
        'balance': newSenderBalance,
      });

      // -------------------------------------------------------
      // UPDATE RECEIVER
      // -------------------------------------------------------

      transaction.update(receiverRef, {
        'balance': newReceiverBalance,
      });

      // -------------------------------------------------------
      // SENDER TRANSACTION
      // -------------------------------------------------------

      transaction.set(senderTransactionRef, {
        'transactionId': senderTransactionRef.id,
        'type': 'debit',
        'amount': amount,
        'description': 'Money Sent to $receiverUpiId',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // -------------------------------------------------------
      // RECEIVER TRANSACTION
      // -------------------------------------------------------

      transaction.set(receiverTransactionRef, {
        'transactionId': receiverTransactionRef.id,
        'type': 'credit',
        'amount': amount,
        'description': 'Money Received',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // =========================================================
  // GET RECENT TRANSACTIONS
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }
}