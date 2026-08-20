import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.type == 'credit';

    final Color amountColor =
        isCredit ? Colors.green : Colors.red;

    final IconData transactionIcon =
        isCredit
            ? Icons.arrow_downward
            : Icons.arrow_upward;

    final String sign =
        isCredit ? '+' : '-';

    String dateText = 'Processing...';
    String timeText = '';

    if (transaction.timestamp != null) {
      final DateTime date = transaction.timestamp!;

      dateText =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';

      timeText =
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // =================================================
            // TRANSACTION ICON
            // =================================================

            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),

              child: Icon(
                transactionIcon,
                size: 45,
                color: amountColor,
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // AMOUNT
            // =================================================

            Text(
              '$sign₹${transaction.amount.toStringAsFixed(2)}',

              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isCredit
                  ? 'Money Received'
                  : 'Money Sent',

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 35),

            // =================================================
            // PAYMENT DETAILS
            // =================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Payment Details',

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION
                  _DetailRow(
                    icon: Icons.description_outlined,
                    title: 'Description',
                    value: transaction.description,
                  ),

                  const Divider(height: 28),

                  // AMOUNT
                  _DetailRow(
                    icon: Icons.currency_rupee,
                    title: 'Amount',
                    value:
                        '₹${transaction.amount.toStringAsFixed(2)}',
                  ),

                  const Divider(height: 28),

                  // TYPE
                  _DetailRow(
                    icon: Icons.swap_vert,
                    title: 'Transaction Type',
                    value:
                        isCredit
                            ? 'Credit'
                            : 'Debit',
                  ),

                  const Divider(height: 28),

                  // DATE
                  _DetailRow(
                    icon:
                        Icons.calendar_today_outlined,
                    title: 'Date',
                    value: dateText,
                  ),

                  // TIME
                  if (timeText.isNotEmpty) ...[
                    const Divider(height: 28),

                    _DetailRow(
                      icon: Icons.access_time,
                      title: 'Time',
                      value: timeText,
                    ),
                  ],

                  const Divider(height: 28),

                  // STATUS
                  _DetailRow(
                    icon:
                        Icons.check_circle_outline,
                    title: 'Status',
                    value: 'Successful',
                    valueColor: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // DONE
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  'Done',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// DETAIL ROW
// =============================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        // ICON
        Icon(
          icon,
          size: 23,
          color: Colors.deepPurple,
        ),

        const SizedBox(width: 14),

        // TEXT
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

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}