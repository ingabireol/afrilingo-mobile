import 'package:flutter/material.dart';

import '../screens/why.dart';

class Levelofuser extends StatefulWidget {
  final String? hearAboutUsOption;

  const Levelofuser({super.key, this.hearAboutUsOption});

  @override
  State<Levelofuser> createState() => _LevelofuserState();
}

class _LevelofuserState extends State<Levelofuser> {
  String _selectedOption = '';

  @override
  void initState() {
    super.initState();
    // Initialize _selectedOption with the passed hearAboutUsOption if available
    if (widget.hearAboutUsOption != null) {
      _selectedOption = widget.hearAboutUsOption!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'What is your level ? ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF582805),
                    fontSize: 32,
                    fontFamily: 'DM Serif Display',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                _buildProgressIndicator(),
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOptionContainer('I’m just starting to learn.',
                        isSelected:
                            _selectedOption == 'I’m just starting to learn.'),
                    const SizedBox(height: 20),
                    _buildOptionContainer('I know a few words and phrases',
                        isSelected: _selectedOption ==
                            'I know a few words and phrases'),
                    const SizedBox(height: 20),
                    _buildOptionContainer(
                        'I can understand and have simple conversations.',
                        isSelected: _selectedOption ==
                            'I can understand and have simple conversations.'),
                    const SizedBox(height: 20),
                    _buildOptionContainer(
                        'I can hold conversations and understand most things',
                        isSelected: _selectedOption ==
                            'I can hold conversations and understand most things'),
                    const SizedBox(height: 20),
                    _buildOptionContainer(
                        'I can speak fluently and understand everything',
                        isSelected: _selectedOption ==
                            'I can speak fluently and understand everything'),
                  ],
                ),
                const SizedBox(height: 26),
                _buildNextButton(
                  context: context,
                  selectedOption: _selectedOption,
                  nextScreen: WhyScreen(
                    hearAboutUsOption: widget.hearAboutUsOption ?? '',
                    levelOfUser: _selectedOption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(Colors.black),
        const SizedBox(width: 10),
        _buildDot(Color(0xFF080808)),
        const SizedBox(width: 10),
        _buildDot(Colors.black),
        const SizedBox(width: 10),
        _buildDot(Color(0xFFC4C4C4)),
        const SizedBox(width: 10),
        _buildDot(Color(0xFFC4C4C4)),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: ShapeDecoration(
        color: color,
        shape: StadiumBorder(),
      ),
    );
  }

  Widget _buildOptionContainer(String text, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: isSelected ? Color(0xFF582805) : Color(0xBFD6C3B5),
          shape: RoundedRectangleBorder(
            side: isSelected
                ? BorderSide.none
                : BorderSide(width: 1, color: Color(0xFF582805)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF582805),
                  fontSize: 24,
                  fontFamily: 'DM Serif Display',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton({
    required BuildContext context,
    required String selectedOption,
    required Widget nextScreen,
  }) {
    return ElevatedButton(
      onPressed: selectedOption.isNotEmpty
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => nextScreen,
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF582805),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Next',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
