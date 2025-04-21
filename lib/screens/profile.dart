import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Profile Header with gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFC78539), // Light brown
                    Color(0xFF532708), // Dark brown
                    Color(0xFF2D1505), // Even darker brown
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Close button at top right
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          // Handle close button tap
                          Navigator.pop(context); // Close the profile screen
                        },
                      ),
                    ),

                    // Profile picture and name
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              'https://via.placeholder.com/60',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ishimwe Shakilla',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content - List of settings options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem('Set Profile Photo', Icons.camera_alt_outlined, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('Set Username', Icons.person_outline, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('Notifications and Sounds', Icons.notifications_none, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('Privacy and Security', Icons.lock_outline, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('Data and Storage', Icons.storage_outlined, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('Appearance', Icons.palette_outlined, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('My stars', Icons.star_outline, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('My streaks', Icons.whatshot_outlined, onTap: () {}),
                  _buildDivider(),
                  const SizedBox(height: 16), // Space between sections
                  _buildMenuItem('Ask a Question', Icons.help_outline, onTap: () {}),
                  _buildDivider(),
                  _buildMenuItem('FAQ', Icons.info_outline, onTap: () {}),
                  _buildDivider(),
                  const SizedBox(height: 16), // Space between sections
                  _buildMenuItem('Log Out', Icons.logout, onTap: () {}),
                  _buildDivider(),
                  const SizedBox(height: 40), // Bottom padding for final emoji

                  // Bottom emoji
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '👋',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 20,
      endIndent: 20,
    );
  }
}