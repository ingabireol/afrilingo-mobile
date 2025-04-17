import 'package:afrilingo/screens/speaking.dart';
import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  double playbackSpeed = 1.0;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening - Kinyarwanda'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5D4037), // Dark brown
                Color(0xFF8D6E63), // Medium brown
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFFAF9F6), // Cream milk white background
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Kinyarwanda text
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'U Rwanda ruzwi cyane kubera imisazi yuburanga\n'
                              'Rangaje, Rwamenyekuaye ku izina ry\'igihugu\n'
                              'Cy\'imisozi igihumbi n\'ibibaya by\'icyatsi\n'
                              'Muri iyo misozi harimo Parike y\'Igihugu y\'Ibirunga,\n'
                              'aho usanga ingagi z\'umusozi, zituma u Rwanda\n'
                              'ruba aho abashyitsi benshi bakunda kujya.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF5D4037),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Playback controls between paragraphs
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            IconButton(
                              iconSize: 48,
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                color: const Color(0xFF8D6E63),
                              ),
                              onPressed: () {
                                setState(() {
                                  isPlaying = !isPlaying;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['0.5x', '1.0x', '1.5x', '2.0x'].map((speed) {
                                return ChoiceChip(
                                  label: Text(speed),
                                  selected: playbackSpeed == double.parse(speed.replaceAll('x', '')),
                                  onSelected: (selected) {
                                    setState(() {
                                      playbackSpeed = double.parse(speed.replaceAll('x', ''));
                                    });
                                  },
                                  selectedColor: const Color(0xFF8D6E63),
                                  labelStyle: TextStyle(
                                    color: playbackSpeed == double.parse(speed.replaceAll('x', ''))
                                        ? Colors.white
                                        : const Color(0xFF5D4037),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // English text
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Rwanda is famous for its breathtaking natural landscapes\n'
                              'Known as the "Land of a Thousand Hills" with its lush\n'
                              'green mountains and valleys\n'
                              'Among these mountains is Volcanoes National Park,\n'
                              'where mountain gorillas live, making Rwanda\n'
                              'a favorite destination for many visitors.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF5D4037),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation bar with brown Next button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
                    label: const Text('Previous', style: TextStyle(color: Color(0xFF5D4037))),
                    onPressed: () {},
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text('Next', style: TextStyle(color: Colors.white)),
                    onPressed: () {Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SpeakingScreen()),
                    );},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63), // Brown color
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}