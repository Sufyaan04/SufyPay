import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
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

    final String email = user.email ?? 'No email available';

    final String upiId = email.contains('@')
        ? email
        : '$email@sufypay';

    final String displayName =
        user.displayName ??
        (email.contains('@')
            ? email.split('@').first
            : 'SufyPay User');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =====================================================
            // PROFILE AVATAR
            // =====================================================

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                displayName.isNotEmpty
                    ? displayName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =====================================================
            // NAME
            // =====================================================

            Text(
              displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // ACCOUNT INFORMATION
            // =====================================================

            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'UPI ID',
              value: upiId,
            ),

            const SizedBox(height: 12),

            _ProfileTile(
              icon: Icons.verified_user_outlined,
              title: 'Account Status',
              value: 'Active',
            ),

            const SizedBox(height: 30),

            // =====================================================
            // LOGOUT
            // =====================================================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                },

                icon: const Icon(
                  Icons.logout,
                ),

                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

// =============================================================
// PROFILE TILE
// =============================================================

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({
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
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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