import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/core/theme/theme_provider.dart';
import 'package:afrilingo/features/exercises/screens/foodanddrinks.dart';
import 'package:afrilingo/features/auth/widgets/navigation_bar.dart';
import 'package:afrilingo/utils/app_theme.dart';

// African-inspired color palette
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class FilesPage extends StatefulWidget {
  final int initialTabIndex;

  const FilesPage({super.key, this.initialTabIndex = 0});

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _username = 'buntu Levy Caleb';
  final String _language = 'Kinyarwanda';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        systemOverlayStyle: themeProvider.isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Column(
          children: [
            Text(
              _username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _language,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: themeProvider.lightTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: themeProvider.primaryColor,
            ),
            onPressed: () {
              // Handle search
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: themeProvider.primaryColor,
          labelColor: themeProvider.primaryColor,
          unselectedLabelColor: themeProvider.lightTextColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicator: UnderlineTabIndicator(
            borderSide:
                BorderSide(width: 3.0, color: themeProvider.primaryColor),
            insets: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          tabs: const [
            Tab(text: 'Sets'),
            Tab(text: 'Created'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGridSection(themeProvider),
          _buildEmptyTab('No created files yet.', themeProvider),
          _buildEmptyTab('No saved files yet.', themeProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new file/set
        },
        backgroundColor: themeProvider.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _buildGridSection(ThemeProvider themeProvider) {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Colors', 'icon': Icons.palette, 'color': Colors.red.shade300},
      {
        'title': 'Numbers',
        'icon': Icons.numbers,
        'color': Colors.blue.shade300
      },
      {
        'title': 'Body parts',
        'icon': Icons.accessibility_new,
        'color': Colors.green.shade300
      },
      {
        'title': 'Food & Drinks',
        'icon': Icons.fastfood,
        'color': Colors.orange.shade300,
        'isSelected': true
      },
      {'title': 'Beauty', 'icon': Icons.face, 'color': Colors.purple.shade300},
      {
        'title': 'Clothes',
        'icon': Icons.checkroom,
        'color': Colors.teal.shade300
      },
      {'title': 'Animals', 'icon': Icons.pets, 'color': Colors.brown.shade300},
      {
        'title': 'Family',
        'icon': Icons.family_restroom,
        'color': Colors.indigo.shade300
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            'Learning Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore these categories to learn Kinyarwanda vocabulary',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.lightTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Categories grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final bool isSelected = category['isSelected'] == true;

              return _buildCategoryCard(
                title: category['title'],
                icon: category['icon'],
                color: category['color'],
                isSelected: isSelected,
                themeProvider: themeProvider,
                onTap: () {
                  if (category['title'] == 'Food & Drinks') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FoodAndDrinks()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${category['title']} category coming soon'),
                        backgroundColor: themeProvider.primaryColor,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    bool isSelected = false,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: themeProvider.primaryColor, width: 2)
              : Border.all(color: themeProvider.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '25 words',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.lightTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String message, ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: themeProvider.lightTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
