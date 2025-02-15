import 'package:flutter/material.dart';

import '/widgets/auth/navigation_bar.dart'; // Adjust the path accordingly

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 243, 251, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildMotivationalCard(),
              _buildLatestResults(),
              // Removed the inline bottom navigation bar from here.
            ],
          ),
        ),
      ),
      // Use the custom navigation bar as the Scaffold's bottomNavigationBar.
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AppBar(
          title: const Column(
            children: [
              Text(
                'Shakilla Ishimwe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Kinyarwanda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF4A63BF)),
              onPressed: () {
                // Handle menu button press.
              },
            ),
          ],
        ),
        Container(
          color: Colors.white,
          child: const Column(
            children: [
              SizedBox(height: 12),
              Text(
                'Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Divider(
                thickness: 2,
                indent: 600,
                endIndent: 600,
                color: Color(0xFF2E70E8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalCard() {
    return InkWell(
      onTap: () {
        // Handle tap on motivational card.
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5078FC), Color(0xFF715AE5)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Adjust opacity if needed.
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep it up!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You learned 80% of your goal this week!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/0f9693818e474846de6af361977533938afc94bbf6629e8ec7131c9ab74eb37a?placeholderIfAbsent=true&apiKey=116c718011a3489b93103e46cb1ee39c',
              width: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestResults() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildResultCard(
              'Travel', 'Achievement : 45/50', 'Sunday', '17/03/2021', false),
          _buildResultCard('Conversation', 'Achievement : 12/38', 'Friday',
              '10/03/2021', true),
          _buildResultCard('Speaking', 'Achievement : 26/40', 'Wednesday',
              '06/03/2021', false),
          _buildResultCard('Reading', 'Achievement : 40/69', 'Saturday',
              '01/03/2021', false),
        ],
      ),
    );
  }

  Widget _buildResultCard(
      String title, String achievement, String day, String date, bool isRed) {
    return InkWell(
      onTap: () {
        // Handle tap on result card.
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isRed ? Colors.red : Colors.transparent),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  achievement,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRed ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
