import 'package:flutter/material.dart';
import '../../../shared/widgets/history_item_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191C1D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 8),
              Text(
                'History',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xFF191C1D),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 24),
              HistoryItemCard(title: 'Finish PRD Draft', subtitle: 'Today, 5:00 PM'),
              HistoryItemCard(title: 'Client Feedback Review', subtitle: 'Yesterday, 2:00 PM'),
              HistoryItemCard(title: 'Weekly Team Sync', subtitle: 'Wed, 10:00 AM'),
              HistoryItemCard(title: 'Update Product Roadmap', subtitle: 'Tue, 4:30 PM'),
              HistoryItemCard(title: 'Finish PRD Draft', subtitle: 'Today, 5:00 PM'),
              HistoryItemCard(title: 'Client Feedback Review', subtitle: 'Yesterday, 2:00 PM'),
              HistoryItemCard(title: 'Weekly Team Sync', subtitle: 'Wed, 10:00 AM'),
              HistoryItemCard(title: 'Update Product Roadmap', subtitle: 'Tue, 4:30 PM'),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
