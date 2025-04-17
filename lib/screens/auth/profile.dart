import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

// Adjust these colors to match your screenshot EXACTLY
const Color kPinkBorderColor = Color(0xFF546CC3); // Pink border & button
const Color kLightPinkBgColor =
    Color(0xFFE0E0E0); // Light-pink background for cards
const Color kGradientStart =
    Color.fromRGBO(0, 110, 150, 1); // Gradient start (pink)
const Color kGradientEnd = Color(0xFF546CC3); // Gradient end (purple-ish)
const Color kGreyProgress = Color(0xFFE0E0E0); // Background of the progress bar

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 4),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1) TOP HEADER (white background, pink border)
              InkWell(
                onTap: () {
                  // TODO: handle tap on top container
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kPinkBorderColor, width: 2.5),
                    // Slightly rounded corners at bottom to match your screenshot
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPinkBorderColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 24,
                    ),
                    child: Column(
                      children: [
                        // Top row: hamburger & overflow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu, size: 28),
                              onPressed: () {
                                // TODO: handle hamburger menu
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 28),
                              onPressed: () {
                                // TODO: handle overflow
                              },
                            ),
                          ],
                        ),

                        // Centered user avatar with "+" badge
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                'https://cdn.builder.io/api/v1/image/assets/TEMP/'
                                'f92e89ea3117bf9bc67a88d11f22f0474d7b0024321d2a4212768483bcce68c4'
                                '?placeholderIfAbsent=true&apiKey=116c718011a3489b93103e46cb1ee39c',
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: kPinkBorderColor, width: 2.5),
                                ),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: kPinkBorderColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Beginner Level',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2) LEARNING PROGRESS (own container)
              InkWell(
                onTap: () {
                  // TODO: handle tap on Learning Progress
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kPinkBorderColor, width: 2.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kPinkBorderColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: "Learning Progress" + "50%"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Learning Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '50%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Gradient progress bar (approx. 50% wide)
                      _GradientProgressBar(percentage: 0.5),

                      SizedBox(height: 16),
                      Text(
                        'You completed 3 Chapters',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3) ACHIEVEMENTS
              InkWell(
                onTap: () {
                  // TODO: handle tap on Achievements
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kLightPinkBgColor,
                    border: Border.all(color: kPinkBorderColor, width: 2.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kPinkBorderColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Streaks row
                      InkWell(
                        onTap: () {
                          // TODO: handle tap on Streaks
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Streak',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Text(
                                    '5 days',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPinkBorderColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: kPinkBorderColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Badges section
                      const Text(
                        'Badges',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBadge('First Lesson', Icons.school, true),
                          _buildBadge('Perfect Score', Icons.star, true),
                          _buildBadge('5-Day Streak', Icons.local_fire_department, false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBadge(String title, IconData icon, bool isUnlocked) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isUnlocked ? kPinkBorderColor : Colors.grey[400],
            shape: BoxShape.circle,
            boxShadow: isUnlocked ? [
              BoxShadow(
                color: kPinkBorderColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isUnlocked ? Colors.black87 : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A custom widget to show a gradient progress bar
/// from [kGradientStart] to [kGradientEnd].
class _GradientProgressBar extends StatelessWidget {
  final double percentage;

  const _GradientProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: kGreyProgress,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // The filled part with gradient
          FractionallySizedBox(
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kGradientStart, kGradientEnd],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
