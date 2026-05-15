import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF777587)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF191C1D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How can we help you today?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for articles...',
                    hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF777587)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 16),
              
              // FAQ Items
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildFaqItem('How do I reset my password?'),
                    const Divider(height: 1, color: Color(0x1AC7C4D8)),
                    _buildFaqItem('How do I delete a task?'),
                    const Divider(height: 1, color: Color(0x1AC7C4D8)),
                    _buildFaqItem('Can I sync across devices?'),
                    const Divider(height: 1, color: Color(0x1AC7C4D8)),
                    _buildFaqItem('How to enable push notifications?'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Contact Support
              const Text(
                'CONTACT US',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildContactItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Live Chat',
                      subtitle: 'Start a conversation now',
                    ),
                    const SizedBox(height: 24),
                    _buildContactItem(
                      icon: Icons.email_outlined,
                      title: 'Email Support',
                      subtitle: 'support@dofirst.app',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF191C1D),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF777587)),
      onTap: () {},
    );
  }

  Widget _buildContactItem({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5), // Light purple
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4A148C)), // Purple
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF777587),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
