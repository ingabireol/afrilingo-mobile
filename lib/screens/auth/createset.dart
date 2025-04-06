import 'package:afrilingo/screens/auth/files_page.dart';
import 'package:flutter/material.dart';

class CreateSetPage extends StatelessWidget {
  const CreateSetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              // Handle save action
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const FilesPage(initialTabIndex: 1)));
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Create Set',
          style: TextStyle(
            fontFamily: 'DM Serif Display',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food & Drinks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildVocabularyBox(
                    term: 'Amafiriti',
                    description: 'Chips',
                    isHighlighted: true,
                    onEdit: () {
                      // Handle edit action
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildVocabularyBox(
                    term: 'Term',
                    description: 'Description , Translation',
                    isHighlighted: false,
                    onEdit: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildVocabularyBox(
                    term: 'Term',
                    description: 'Description , Translation',
                    isHighlighted: false,
                    onEdit: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildVocabularyBox(
                    term: 'Term',
                    description: 'Description , Translation',
                    isHighlighted: false,
                    onEdit: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyBox({
    required String term,
    required String description,
    required bool isHighlighted,
    required VoidCallback onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            isHighlighted ? Border.all(color: Colors.black, width: 2) : null,
        boxShadow: isHighlighted
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Term Area (Sky Blue)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFD7DFF6), // Sky Blue
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  term,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                    onTap: onEdit,
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit,
                            size: 24, color: Colors.black54))),
              ],
            ),
          ),
          // Description Area (White)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
