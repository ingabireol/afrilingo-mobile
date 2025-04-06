import 'package:afrilingo/screens/auth/createset.dart';
import 'package:flutter/material.dart';

class FoodAndDrinks extends StatelessWidget {
  const FoodAndDrinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Food & Drinks',
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
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildVocabularyRow('Amafiriti', 'Chips'),
                  const SizedBox(height: 20),
                  _buildVocabularyRow('Umuceri', 'Rice'),
                  const SizedBox(height: 20),
                  _buildVocabularyRow('Ibishyimbo', 'Beans'),
                  const SizedBox(height: 20),
                  _buildVocabularyRow('Inkoko', 'Chicken'),
                  const SizedBox(height: 20),
                  _buildVocabularyRow('Icyayi', 'Tea'),
                  const SizedBox(height: 20),
                  _buildVocabularyRow('Amata', 'Milk'),
                  const SizedBox(height: 20),
                  _buildVocabularyRow('Amazi', 'Water'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCreateSetButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyRow(String leftText, String rightText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildVocabularyBox(leftText, true),
        const SizedBox(width: 20),
        _buildVocabularyBox(rightText, false),
      ],
    );
  }

  Widget _buildVocabularyBox(String text, bool isHighlighted) {
    return Container(
      width: 150,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFD7DFF6) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? null : Border.all(color: Colors.black),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Noto Sans Devanagari UI SemiCondensed',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateSetButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF546CC3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black),
        ),
        minimumSize: const Size.fromHeight(60),
      ),
      onPressed: () {
        // Handle button press
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateSetPage()),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create Set',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.add, size: 28, color: Colors.white),
        ],
      ),
    );
  }
}
