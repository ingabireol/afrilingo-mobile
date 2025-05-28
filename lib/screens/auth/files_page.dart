import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'foodanddrinks.dart';
import '../../widgets/auth/navigation_bar.dart';
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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kTextColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Column(
          children: [
            Text(
              _username,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _language,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: kLightTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: kPrimaryColor,
            ),
            onPressed: () {
              // Handle search
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kLightTextColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: kPrimaryColor),
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
          _buildGridSection(),
          _buildEmptyTab('No created files yet.'),
          _buildEmptyTab('No saved files yet.'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new file/set
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _buildGridSection() {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Colors', 'icon': Icons.palette, 'color': Colors.red.shade300},
      {'title': 'Numbers', 'icon': Icons.numbers, 'color': Colors.blue.shade300},
      {'title': 'Body parts', 'icon': Icons.accessibility_new, 'color': Colors.green.shade300},
      {'title': 'Food & Drinks', 'icon': Icons.fastfood, 'color': Colors.orange.shade300, 'isSelected': true},
      {'title': 'Beauty', 'icon': Icons.face, 'color': Colors.purple.shade300},
      {'title': 'Clothes', 'icon': Icons.checkroom, 'color': Colors.teal.shade300},
      {'title': 'Animals', 'icon': Icons.pets, 'color': Colors.brown.shade300},
      {'title': 'Family', 'icon': Icons.family_restroom, 'color': Colors.indigo.shade300},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          const Text(
            'Learning Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore these categories to learn Kinyarwanda vocabulary',
            style: TextStyle(
              fontSize: 14,
              color: kLightTextColor,
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
                onTap: () {
                  if (category['title'] == 'Food & Drinks') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodAndDrinks()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${category['title']} category coming soon')),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? kPrimaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isSelected
              ? Border.all(color: kPrimaryColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: kTextColor,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'In Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: kLightTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Handle create new
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
