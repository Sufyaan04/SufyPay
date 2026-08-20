import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'transaction_detail_screen.dart';
import 'history_screen.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import 'profile_screen.dart';
import 'send_money_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // =========================================================
    // USER NOT LOGGED IN
    // =========================================================

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not logged in',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    final String uid = user.uid;

    final FirestoreService firestoreService =
        FirestoreService();

    // =========================================================
    // HOME SCREEN
    // =========================================================

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FF),

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7FF),
        elevation: 0,

        title: const Text(
          'SufyPay',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
  tooltip: 'Profile',
  icon: const Icon(Icons.person_outline),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  },
),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),

        builder: (context, userSnapshot) {
          // ===================================================
          // LOADING
          // ===================================================

          if (userSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ===================================================
          // ERROR
          // ===================================================

          if (userSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
          }

          // ===================================================
          // USER DOCUMENT DOES NOT EXIST
          // ===================================================

          if (!userSnapshot.hasData ||
              !userSnapshot.data!.exists) {
            return const Center(
              child: Text(
                'User profile not found.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // ===================================================
          // USER DATA
          // ===================================================

          final Map<String, dynamic> data =
              userSnapshot.data!.data() ??
                  <String, dynamic>{};

          final String name =
              (data['name'] ??
                      data['fullName'] ??
                      'User')
                  .toString();

          final String upiId =
              (data['upiId'] ??
                      '${name.toLowerCase()}@sufypay')
                  .toString();

          final double balance =
              (data['balance'] ?? 0).toDouble();

          // ===================================================
          // MAIN CONTENT
          // ===================================================

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =================================================
                // WELCOME
                // =================================================

                Text(
                  'Welcome, $name 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // BALANCE CARD
                // =================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6D43C5),
                        Color(0xFF966BD8),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '₹${balance.toStringAsFixed(2)}',

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        upiId,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // QUICK ACTIONS
                // =================================================

                const Text(
                  'Quick Actions',

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [

                    // =============================================
                    // ADD MONEY
                    // =============================================

                    Expanded(
                      child: _ActionCard(
                        icon: Icons.add,
                        title: 'Add Money',

                        onTap: () {
                          _showAddMoneyDialog(
                            context,
                            firestoreService,
                            uid,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    // =============================================
                    // SEND MONEY
                    // =============================================

                    Expanded(
                      child: _ActionCard(
                        icon: Icons.send,
                        title: 'Send Money',

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SendMoneyScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // MY UPI ID
                // =================================================

                const Text(
                  'My UPI ID',

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),

                    borderRadius:
                        BorderRadius.circular(15),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.account_balance_wallet,
                        size: 25,
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          upiId,

                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                        ),

                        tooltip: 'Copy UPI ID',

                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'UPI ID copied!',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // RECENT TRANSACTIONS
                // =================================================

                Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'Recent Transactions',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const HistoryScreen(),
          ),
        );
      },
      child: const Text(
        'View All',
      ),
    ),
  ],
),

const SizedBox(height: 15),

                // =================================================
                // IMPORTANT:
                //
                // FirestoreService.getTransactions()
                // RETURNS:
                //
                // Stream<List<TransactionModel>>
                //
                // Therefore this MUST be:
                //
                // StreamBuilder<List<TransactionModel>>
                // =================================================

StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(                  stream:
                      firestoreService.getTransactions(uid),

                  builder: (
                    context,
                    transactionSnapshot,
                  ) {
                    // ===========================================
                    // LOADING
                    // ===========================================

                    if (transactionSnapshot
                            .connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(30),

                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Colors.grey.shade300,
                          ),

                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    }

                    // ===========================================
                    // ERROR
                    // ===========================================

                    if (transactionSnapshot.hasError) {
                      return Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(25),

                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Colors.grey.shade300,
                          ),

                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: const Center(
                          child: Text(
                            'Unable to load transactions.',
                          ),
                        ),
                      );
                    }

                    // ===========================================
                    // GET TRANSACTIONS
                    // ===========================================
final List<TransactionModel> transactions =
    transactionSnapshot.data!.docs.map((doc) {
  return TransactionModel.fromMap(
    doc.id,
    doc.data(),
  );
}).toList();

                    // ===========================================
                    // NO TRANSACTIONS
                    // ===========================================

                    if (transactions.isEmpty) {
                      return Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(30),

                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Colors.grey.shade300,
                          ),

                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: const Column(
                          children: [

                            Icon(
                              Icons.receipt_long,
                              size: 50,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 10),

                            Text(
                              'No transactions yet.',

                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ===========================================
                    // TRANSACTIONS LIST
                    // ===========================================

                    return Column(
                      children:
                          transactions.map(
                        (TransactionModel transaction) {

                          final bool isCredit =
                              transaction.type ==
                                  'credit';

                          String dateText = '';

                          if (transaction.timestamp !=
                              null) {
                            final DateTime date =
                                transaction.timestamp!;

                            dateText =
                                '${date.day.toString().padLeft(2, '0')}/'
                                '${date.month.toString().padLeft(2, '0')}/'
                                '${date.year}';
                          }

                          return Container(
                            width: double.infinity,

                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),

                            padding:
                                const EdgeInsets.all(15),

                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Colors.grey.shade300,
                              ),

                              borderRadius:
                                  BorderRadius.circular(15),
                            ),

                            child: Row(
                              children: [

                                // =============================
                                // TRANSACTION ICON
                                // =============================

                                Container(
                                  width: 45,
                                  height: 45,

                                  decoration:
                                      BoxDecoration(
                                    color: isCredit
                                        ? Colors.green
                                            .withOpacity(
                                            0.12,
                                          )
                                        : Colors.red
                                            .withOpacity(
                                            0.12,
                                          ),

                                    shape:
                                        BoxShape.circle,
                                  ),

                                  child: Icon(
                                    isCredit
                                        ? Icons
                                            .arrow_downward
                                        : Icons
                                            .arrow_upward,

                                    color: isCredit
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // =============================
                                // DETAILS
                                // =============================

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        transaction
                                            .description,

                                        style:
                                            const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),

                                      if (dateText
                                          .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets
                                                  .only(
                                            top: 5,
                                          ),

                                          child: Text(
                                            dateText,

                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors
                                                  .grey
                                                  .shade600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // =============================
                                // AMOUNT
                                // =============================

                                Text(
                                  '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,

                                    color: isCredit
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =============================================================
  // ADD MONEY DIALOG
  // =============================================================

  static void _showAddMoneyDialog(
    BuildContext context,
    FirestoreService firestoreService,
    String uid,
  ) {
    final TextEditingController amountController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
            return AlertDialog(

              title: const Text(
                'Add Money',
              ),

              content: TextField(
                controller: amountController,

                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),

              actions: [

                // =============================================
                // CANCEL
                // =============================================

                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },

                  child: const Text(
                    'Cancel',
                  ),
                ),

                // =============================================
                // ADD
                // =============================================

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final double? amount =
                              double.tryParse(
                            amountController.text
                                .trim(),
                          );

                          // -----------------------------------
                          // INVALID AMOUNT
                          // -----------------------------------

                          if (amount == null ||
                              amount <= 0) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter a valid amount.',
                                ),
                              ),
                            );

                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            // ---------------------------------
                            // ADD MONEY TO FIRESTORE
                            // ---------------------------------

                            await firestoreService
                                .addMoney(
                              uid,
                              amount,
                            );

                            // ---------------------------------
                            // CLOSE DIALOG
                            // ---------------------------------

                            if (dialogContext.mounted) {
                              Navigator.pop(
                                dialogContext,
                              );
                            }

                            // ---------------------------------
                            // SUCCESS MESSAGE
                            // ---------------------------------

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '₹${amount.toStringAsFixed(2)} added successfully!',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            // ---------------------------------
                            // ERROR
                            // ---------------------------------

                            setState(() {
                              isLoading = false;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to add money: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },

                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add',
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// =================================================================
// ACTION CARD
// =================================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(15),

      child: Container(
        height: 100,

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),

          borderRadius:
              BorderRadius.circular(15),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 30,
              color: Colors.black87,
            ),

            const SizedBox(height: 8),

            Text(
              title,

              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}