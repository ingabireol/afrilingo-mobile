import 'package:flutter/material.dart';

import '../../widgets/auth/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _handleTryNowPressed() {
    // Handle try now button press
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF2E70E8),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Unread'),
                Tab(text: 'Read'),
                Tab(text: 'Archived'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(), // Unread Tab
                _buildNotificationList(), // Read Tab (use same for now)
                _buildNotificationList(), // Archived Tab (use same for now)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        children: [
          NotificationCard(
            title: 'New Feature Alert!',
            description:
                "We're pleased to introduce the latest enhancements in our templating experience.",
            timestamp: '14h',
            avatarUrl:
                'https://cdn.builder.io/api/v1/image/assets/TEMP/49881c985c47e523d8a51ba581fe0efe3bdc5d7bcd0f73974abb99541b250b75',
            iconUrl:
                'https://cdn.builder.io/api/v1/image/assets/TEMP/0498b696ee28634c0aa8ce013dcc47ff9e7d3a2047c7173257eacc874daf2f8a',
            onTryNowPressed: _handleTryNowPressed,
          ),
          const SizedBox(height: 16),
          NotificationCard(
            title: 'Afrilingo',
            description: 'welcome in the best African language learning app',
            timestamp: '14h',
            avatarUrl:
                'https://cdn.builder.io/api/v1/image/assets/TEMP/49881c985c47e523d8a51ba581fe0efe3bdc5d7bcd0f73974abb99541b250b75',
            iconUrl:
                'https://cdn.builder.io/api/v1/image/assets/TEMP/0498b696ee28634c0aa8ce013dcc47ff9e7d3a2047c7173257eacc874daf2f8a',
            onTryNowPressed: _handleTryNowPressed,
          ),
        ],
      ),
    );
  }
}
