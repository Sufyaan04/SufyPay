import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // =========================================================
    // USER NOT LOGGED IN
    // =========================================================

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
        ),
        body: const Center(
          child: Text(
            'Please login first.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
        ),
      ),

      // =======================================================
      // TRANSACTIONS
      // =======================================================

      body: StreamBuilder<List<TransactionModel>>(
        stream: firestoreService
            .getTransactions(user.uid)
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(
              doc.id,
              doc.data(),
            );
          }).toList();
        }),

        builder: (context, snapshot) {
          // ===================================================
          // LOADING
          // ===================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ===================================================
          // ERROR
          // ===================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.shade400,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Unable to load transactions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ===================================================
          // GET TRANSACTIONS
          // ===================================================

          final List<TransactionModel> transactions =
              snapshot.data ?? <TransactionModel>[];

          // ===================================================
          // EMPTY
          // ===================================================

          if (transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 75,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Your payment activity will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ===================================================
          // TRANSACTION LIST
          // ===================================================

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: transactions.length,

            itemBuilder: (context, index) {
              final TransactionModel transaction =
                  transactions[index];

              // IMPORTANT:
              // Return the actual transaction card.
              // This was the reason your previous screen
              // was completely blank.

              return _TransactionCard(
                transaction: transaction,
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================
// TRANSACTION CARD
// =============================================================

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // CREDIT / DEBIT
    // =========================================================

    final bool isCredit =
        transaction.type == 'credit';

    final Color amountColor =
        isCredit ? Colors.green : Colors.red;

    final IconData icon =
        isCredit
            ? Icons.arrow_downward
            : Icons.arrow_upward;

    final String sign =
        isCredit ? '+' : '-';

    // =========================================================
    // DATE / TIME
    // =========================================================

    String dateText = 'Processing...';
    String timeText = '';

    if (transaction.timestamp != null) {
      final DateTime date =
          transaction.timestamp!;

      dateText =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';

      timeText =
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    // =========================================================
    // CARD
    // =========================================================

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(16),

          // ===================================================
          // OPEN TRANSACTION DETAILS
          // ===================================================

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailsScreen(
                  transaction: transaction,
                ),
              ),
            );
          },

          child: Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Row(
              children: [
                // =============================================
                // ICON
                // =============================================

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color:
                        amountColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    icon,
                    color: amountColor,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 15),

                // =============================================
                // DESCRIPTION + DATE
                // =============================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        transaction.description,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Text(
                            dateText,

                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),

                          if (timeText.isNotEmpty) ...[
                            const SizedBox(width: 8),

                            Text(
                              timeText,

                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // =============================================
                // AMOUNT + ARROW
                // =============================================

                Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Text(
                      '$sign₹${transaction.amount.toStringAsFixed(2)}',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color: amountColor,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color:
                          Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}