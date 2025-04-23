import 'package:afrilingo/screens/profile.dart';
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
                    border: Border.all(color: kPinkBorderColor, width: 2),
                    // Slightly rounded corners at bottom to match your screenshot
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        // Top row: hamburger & overflow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // IconButton(
                            //   icon: const Icon(Icons.menu),
                            //   onPressed: () {
                            //     // TODO: handle hamburger menu
                            //   },
                            // ),
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                               showRightSidePanel(context);
                              },
                            ),
                          ],
                        ),

                        // Centered user avatar with "+" badge
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 50,
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
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: kPinkBorderColor, width: 2),
                                ),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: kPinkBorderColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2) LEARNING PROGRESS (own container)
              InkWell(
                onTap: () {
                  // TODO: handle tap on Learning Progress
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kPinkBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: "Learning Progress" + "50%"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Learning  Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '50%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Gradient progress bar (approx. 50% wide)
                      _GradientProgressBar(percentage: 0.5),

                      SizedBox(height: 12),
                      Text(
                        'You completed 3 Chapters',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3) ACHIEVEMENTS
              InkWell(
                onTap: () {
                  // TODO: handle tap on Achievements
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kLightPinkBgColor,
                    border: Border.all(color: kPinkBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Streaks row
                      InkWell(
                        onTap: () {
                          // TODO: handle tap on Streaks
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Streaks',
                                style: TextStyle(fontSize: 14)),
                            Row(
                              children: [
                                const Text(
                                  '3',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.local_fire_department,
                                    color: Colors.orange[700]),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Points row
                      InkWell(
                        onTap: () {
                          // TODO: handle tap on Points
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Points',
                                style: TextStyle(fontSize: 14)),
                            Row(
                              children: [
                                const Text(
                                  '10',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.star, color: Colors.yellow[700]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4) PERSONAL INFORMATION
              InkWell(
                onTap: () {
                  // TODO: handle tap on Personal Info
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kLightPinkBgColor,
                    border: Border.all(color: kPinkBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name
                      InkWell(
                        onTap: () {
                          // TODO: handle tap on Name
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Shakilla Ishimwe'),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey, height: 24),

                      // Email
                      InkWell(
                        onTap: () {
                          // TODO: handle tap on Email
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('shaks@gmail.com'),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey, height: 24),

                      // Password
                      InkWell(
                        onTap: () {
                          // TODO: handle tap on Password
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('.....'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5) INVITE FRIENDS BUTTON
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: handle invite friends
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPinkBorderColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Invite friends',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 4),
    );
  }

  void showRightSidePanel(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.centerRight, // Align the panel to the right side
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5, // Half width of the screen
            height: MediaQuery.of(context).size.height, // Full height
            color: Colors.white, // Background color for the panel
            child: ProfileScreen(), // Your ProfileScreen widget
          ),
        ),
      );
    },
  );
}
}

/// A custom widget to show a gradient progress bar
/// from [kGradientStart] to [kGradientEnd].
class _GradientProgressBar extends StatelessWidget {
  final double percentage; // 0.0 to 1.0

  const _GradientProgressBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    // We'll stack two containers:
    // 1) a gray background
    // 2) a partial container with a gradient
    return SizedBox(
      height: 10,
      child: Stack(
        children: [
          // Gray background
          Container(
            decoration: BoxDecoration(
              color: kGreyProgress,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Gradient overlay for the "filled" portion
          LayoutBuilder(
            builder: (ctx, constraints) {
              final width = constraints.maxWidth * percentage;
              return Container(
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [kGradientStart, kGradientEnd],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}