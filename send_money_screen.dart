import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() =>
      _SendMoneyScreenState();
}

class _SendMoneyScreenState
    extends State<SendMoneyScreen> {

  final upiController = TextEditingController();
  final amountController = TextEditingController();

  bool isLoading = false;

  final auth = AuthService();
  final firestore = FirestoreService();

  @override
  void dispose() {
    upiController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> sendMoney() async {
    final receiverUpi =
        upiController.text.trim();

    final amount =
        double.tryParse(
          amountController.text.trim(),
        );

    if (receiverUpi.isEmpty) {
      showMessage('Enter receiver UPI ID');
      return;
    }

    if (amount == null || amount <= 0) {
      showMessage('Enter a valid amount');
      return;
    }

    final currentUser = auth.currentUser;

    if (currentUser == null) {
      showMessage('User not logged in');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await firestore.sendMoney(
        senderUid: currentUser.uid,
        receiverUpiId: receiverUpi,
        amount: amount,
      );

      if (!mounted) return;

      showMessage(
        '₹${amount.toStringAsFixed(2)} sent successfully!',
      );

      upiController.clear();
      amountController.clear();

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 30),

            const Text(
              'Send Money',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Transfer money to another SufyPay user',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: upiController,

              keyboardType:
                  TextInputType.emailAddress,

              decoration: const InputDecoration(
                labelText: 'Receiver UPI ID',
                hintText: 'example@sufypay',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.account_balance_wallet,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: amountController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.currency_rupee,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading ? null : sendMoney,

                child: isLoading
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child:
                            CircularProgressIndicator(),
                      )
                    : const Text(
                        'Send Money',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}