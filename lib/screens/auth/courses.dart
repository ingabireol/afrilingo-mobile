import 'package:afrilingo/widgets/auth/navigation_bar.dart';
import 'package:flutter/material.dart';

import 'notifications.dart';

/// This widget uses a TabController to let the user switch between
/// the "Course Review" and "Categories" subscreens.
class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState
    extends State<Courses> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Two tabs: "Course Review" and "Categories"
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light background color
      backgroundColor: const Color.fromRGBO(239, 243, 251, 1),
      body: SafeArea(
        child: Center(
          // Constrain width for responsiveness (max width: 480)
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                // Curved header with a custom TabBar
                _buildCurvedHeader(),
                // Tab content that changes when a tab is tapped or swiped.
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // "Course Review" content
                      _buildCourseReviewTab(),
                      // "Categories" content
                      _buildCategoriesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 0),
    );
  }

  /// Builds the curved header that includes a TabBar.
  Widget _buildCurvedHeader() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(41),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Centered title (optional)
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Kinyarwanda-Courses',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
              ),
            ),
          ),
          // Bell icon at the top-right
          Positioned(
            right: 28,
            top: 27,
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                MaterialPageRoute(builder:  (context)=> const NotificationsScreen()),
                );
              },
            ),
          ),
          // TabBar positioned at the bottom of the header.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  // Tapping a tab will update the TabBarView automatically.
                  setState(() {}); // Trigger rebuild if needed.
                },
                indicatorColor: const Color.fromRGBO(0,110, 150, 1),
                indicatorWeight: 2,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Course Review'),
                  Tab(text: 'Categories'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Course Review" tab content: displays clickable chapter tiles.
  Widget _buildCourseReviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // First group: chapters 1 and 2.
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 24, 21, 15),
            child: Column(
              children: [
                _buildChapterTile(
                  chapter: '1',
                  title: 'Important Phrases in Kinyarwanda',
                  color: const Color.fromRGBO(252, 124, 108, 0.39),
                  imageUrl:
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/2b14c4bce83d00b08e536caa51d8a3cbacc01ca3eef32e2b0fe8cd9b52baddc4',
                  onTap: () => debugPrint("Chapter 1 tapped"),
                ),
                const SizedBox(height: 13),
                _buildChapterTile(
                  chapter: '2',
                  title: 'Introductions in Kinyarwanda',
                  color: const Color.fromRGBO(86, 123, 243, 0.49),
                  imageUrl:
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/dfc79d4f9709cb7bbbef48c8f0f954d1014def763439c3dd6a912538a91a40fe',
                  onTap: () => debugPrint("Chapter 2 tapped"),
                ),
              ],
            ),
          ),
          // Second group: chapters 3, 4, 5, and 6.
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 13, 21, 17),
            child: Column(
              children: [
                _buildChapterTile(
                  chapter: '3',
                  title: 'More essential Phrases',
                  color: const Color.fromRGBO(79, 75, 69, 0.54),
                  imageUrl:
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/c2689b060ad59efb4a351a3b823513141c3605cf0dc153330685f40c891c49fe',
                  onTap: () => debugPrint("Chapter 3 tapped"),
                ),
                const SizedBox(height: 13),
                _buildChapterTile(
                  chapter: '4',
                  title: 'Simple adjectives and numbers',
                  color: const Color.fromRGBO(178, 103, 134, 0.31),
                  imageUrl:
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/ebf22147e24521155f8951add819f403fd34566dfa3a863f14396249f162d682',
                  onTap: () => debugPrint("Chapter 4 tapped"),
                ),
                const SizedBox(height: 13),
                _buildChapterTile(
                  chapter: '5',
                  title: 'Verbs and Tenses',
                  color: const Color.fromRGBO(88, 40, 5, 0.48),
                  imageUrl:
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/123a4b229fc09fd69a5154988df2fc0bb7db81b1483a1ceb00173f7e9bfdfc85',
                  onTap: () => debugPrint("Chapter 5 tapped"),
                ),
                const SizedBox(height: 13),
                _buildChapterTile(
                  chapter: '6',
                  title: 'Common expresions and preoverbs',
                  color: const Color.fromRGBO(244, 213, 149, 0.77),
                  imageUrl:
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/b0a56aece2fbb64dc6cf0f89bcd43a26f2e432fa33180f9d901a808ed374a5ee',
                  onTap: () => debugPrint("Chapter 6 tapped"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Categories" tab content: displays a clickable search bar and category items.
  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Interactive search bar with a writing cursor
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(0, 0, 0, 0.28),
                ),
                prefixIcon: const Icon(Icons.search, size: 28, color: Colors.grey),
                filled: true,
                fillColor: const Color.fromRGBO(196, 196, 196, 0.27),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(126, 143, 205, 1),
                    width: 3,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change color on focus
                    width: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // List of category items
            _buildCategoryItem('Foundations'),
            const SizedBox(height: 13),
            _buildCategoryItem('Daily Life'),
            const SizedBox(height: 13),
            _buildCategoryItem('Expanding expression'),
            const SizedBox(height: 13),
            _buildCategoryItem('Society and culture'),
            const SizedBox(height: 13),
            _buildCategoryItem('Comprehension and explanation'),
            const SizedBox(height: 13),
            _buildCategoryItem('Advanced communication'),
            const SizedBox(height: 13),
            _buildCategoryItem('Creation and analysis'),
          ],
        ),
      ),
    );
  }


  }

  /// Builds a clickable chapter tile (for the Course Review tab).
  Widget _buildChapterTile({
    required String chapter,
    required String title,
    required Color color,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 23),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Chapter text and title.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chapter $chapter',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
                  ),
                ),
              ],
            ),
            // Chapter icon image.
            Image.network(
              imageUrl,
              width: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a clickable category item (for the Categories tab).
  Widget _buildCategoryItem(String title) {
    return InkWell(
      onTap: () => debugPrint("$title tapped"),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.6),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
}
