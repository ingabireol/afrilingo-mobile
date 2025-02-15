import 'package:flutter/material.dart';

import '../../widgets/auth/navigation_bar.dart';
import 'foodanddrinks.dart';

class FilesPage extends StatefulWidget {
  final int initialTabIndex;

  const FilesPage({super.key, this.initialTabIndex = 0});

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color scaffoldBgColor = const Color(0xFFF5F5F5);
  final Color appBarBgColor = Colors.white;
  final Color indicatorColor = const Color(0xFF4A63BF);
  final Color unselectedColor = Colors.grey;
  final Color tileBorderColor = const Color(0xFF4A63BF);
  final Color tileShadowColor = const Color(0x40000000);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: indicatorColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: const Column(
          children: [
            Text(
              'Shakilla Ishimwe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Noto Sans Devanagari UI',
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kinyarwanda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Noto Sans Devanagari UI',
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Color(0xFF4A63BF),
            ),
            onPressed: () {
              // Handle menu tap
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4A63BF),
          labelColor: indicatorColor,
          unselectedLabelColor: unselectedColor,
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
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _buildGridSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 21,
          runSpacing: 31,
          children: [
            _buildGridItem(title: 'Colors', iconData: Icons.palette),
            _buildGridItem(title: 'Numbers', iconData: Icons.numbers),
            _buildGridItem(
                title: 'Body parts', iconData: Icons.accessibility_new),
            _buildGridItem(
              title: 'Food&Drinks',
              iconData: Icons.fastfood,
              hasBorder: true,
            ),
            _buildGridItem(title: 'Beauty', iconData: Icons.face),
            _buildGridItem(title: 'Clothes', iconData: Icons.checkroom),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String title,
    required IconData iconData,
    bool hasBorder = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (title == 'Colors') {
          } else if (title == 'Numbers') {
          } else if (title == 'Body parts') {
          } else if (title == 'Food&Drinks') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodAndDrinks()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No page defined for $title')),
            );
          }
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border:
                hasBorder ? Border.all(color: tileBorderColor, width: 4) : null,
            boxShadow: [
              BoxShadow(
                color: tileShadowColor,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 46, color: tileBorderColor),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Noto Sans Devanagari UI',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
