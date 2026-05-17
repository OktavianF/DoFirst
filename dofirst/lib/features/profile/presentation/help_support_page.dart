import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _allFaqs = [
    {
      'title': 'How do I reset my password?',
      'answer': 'Go to the Login page and tap "Forgot Password". Enter your registered email address and tap "Send Reset Link". You will receive an email with a link to create a new password. Please also check your spam folder if you don\'t see it in your inbox.',
    },
    {
      'title': 'How do I delete a task?',
      'answer': 'Open the task by tapping on it from your task list. On the Task Detail page, you will see a "Delete Task" button at the bottom. Tap it and confirm the deletion. Please note that this action cannot be undone.',
    },
    {
      'title': 'Can I sync across devices?',
      'answer': 'Yes! All your data is securely stored in the cloud and synced automatically. Simply log in with the same account (email or Google) on another device and all your tasks, focus sessions, and history will be available.',
    },
    {
      'title': 'How to enable push notifications?',
      'answer': 'Go to Profile > Notifications, then toggle "Enable Notifications" on. Make sure you also allow notifications in your device\'s system settings for the DoFirst app. You will receive reminders for upcoming deadlines and focus session alerts.',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _allFaqs;
    final query = _searchQuery.toLowerCase();
    return _allFaqs.where((faq) {
      return faq['title']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search for articles...',
                    hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF777587)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF777587), size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
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
              if (_filteredFaqs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'No results found.\nTry a different keyword.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777587),
                      height: 1.5,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: _filteredFaqs.asMap().entries.map((entry) {
                      final isLast = entry.key == _filteredFaqs.length - 1;
                      return Column(
                        children: [
                          _buildFaqItem(entry.value['title']!, entry.value['answer']!),
                          if (!isLast) const Divider(height: 1, color: Color(0x1AC7C4D8)),
                        ],
                      );
                    }).toList(),
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
                      title: 'Chat Now',
                      subtitle: '+62 8136 7642 730',
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

  Widget _buildFaqItem(String title, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF191C1D),
          ),
        ),
        iconColor: const Color(0xFF777587),
        collapsedIconColor: const Color(0xFF777587),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF777587),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFF3E5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4A148C)),
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
