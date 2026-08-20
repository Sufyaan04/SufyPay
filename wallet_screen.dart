import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'send_money_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
        ),
        body: const Center(
          child: Text(
            'Please login first.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          // =====================================================
          // LOADING
          // =====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =====================================================
          // ERROR
          // =====================================================

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
                      'Unable to load wallet.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Please try again later.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =====================================================
          // GET BALANCE
          // =====================================================

          final Map<String, dynamic> data =
              snapshot.data?.data() ??
                  <String, dynamic>{};

          final dynamic balanceValue =
              data['balance'];

          double balance = 0.0;

          if (balanceValue is num) {
            balance = balanceValue.toDouble();
          } else if (balanceValue is String) {
            balance =
                double.tryParse(balanceValue) ?? 0.0;
          }

          // =====================================================
          // WALLET UI
          // =====================================================

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =================================================
                // BALANCE CARD
                // =================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.deepPurple.shade400,
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(24),
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
                          fontWeight: FontWeight.w500,
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

                      const SizedBox(height: 15),

                      Text(
                        user.email ??
                            'SufyPay User',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
                    fontSize: 21,
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
                      child: _WalletAction(
                        icon: Icons.add,
                        title: 'Add Money',
                        onTap: () {
                          _showAddMoneyDialog(
                            context,
                            user.uid,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    // =============================================
                    // SEND MONEY
                    // =============================================

                    Expanded(
                      child: _WalletAction(
                        icon: Icons.send,
                        title: 'Send Money',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SendMoneyScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // WALLET INFORMATION
                // =================================================

                const Text(
                  'Wallet Information',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _WalletInfoTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Current Balance',
                  value:
                      '₹${balance.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 12),

                _WalletInfoTile(
                  icon: Icons.security_outlined,
                  title: 'Wallet Status',
                  value: 'Active',
                ),

                const SizedBox(height: 12),

                _WalletInfoTile(
                  icon: Icons.verified_outlined,
                  title: 'Payment Security',
                  value: 'Protected',
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

  void _showAddMoneyDialog(
    BuildContext context,
    String uid,
  ) {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Money'),

          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),

            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final double? amount =
                    double.tryParse(
                  controller.text.trim(),
                );

                if (amount == null || amount <= 0) {
                  return;
                }

                final DocumentReference<
                        Map<String, dynamic>> userRef =
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid);

                await FirebaseFirestore.instance
                    .runTransaction(
                  (transaction) async {
                    final DocumentSnapshot<
                            Map<String, dynamic>> snapshot =
                        await transaction.get(userRef);

                    final Map<String, dynamic> data =
                        snapshot.data() ??
                            <String, dynamic>{};

                    final dynamic oldBalanceValue =
                        data['balance'];

                    double oldBalance = 0.0;

                    if (oldBalanceValue is num) {
                      oldBalance =
                          oldBalanceValue.toDouble();
                    } else if (oldBalanceValue
                        is String) {
                      oldBalance =
                          double.tryParse(
                                oldBalanceValue,
                              ) ??
                              0.0;
                    }

                    transaction.set(
                      userRef,
                      {
                        'balance':
                            oldBalance + amount,
                      },
                      SetOptions(merge: true),
                    );
                  },
                );

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '₹${amount.toStringAsFixed(2)} added successfully.',
                    ),
                  ),
                );
              },

              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================
// WALLET ACTION BUTTON
// =============================================================

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _WalletAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,

      child: Container(
        height: 110,

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
              BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// WALLET INFORMATION TILE
// =============================================================

class _WalletInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _WalletInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}