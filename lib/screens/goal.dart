import 'package:flutter/material.dart';
import 'auth/user_dashboard.dart';

class GoalScreen extends StatefulWidget {
  final String hearAboutUsOption;
  final String levelOfUser;
  final String whyOption;

  const GoalScreen({super.key, 
    required this.hearAboutUsOption,
    required this.levelOfUser,
    required this.whyOption,
  });

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String _selectedOption = '';

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
                  'What is your goal?',
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
                const SizedBox(height: 30),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOptionContainer(
                        'casual                                   5min',
                        isSelected: _selectedOption == 'casual'),
                    const SizedBox(height: 30),
                    _buildOptionContainer(
                        'regular                                 10min',
                        isSelected: _selectedOption == 'regular'),
                    const SizedBox(height: 30),
                    _buildOptionContainer(
                        'Serious                                  15min',
                        isSelected: _selectedOption == 'Serious'),
                    const SizedBox(height: 30),
                    _buildOptionContainer(
                        'Intense                                  20min',
                        isSelected: _selectedOption == 'Intense'),
                    const SizedBox(height: 30),
                  ],
                ),
                const SizedBox(height: 30),
                _buildNextButton(
                  context: context,
                  selectedOption: _selectedOption,
                  nextScreen: UserDashboard(),
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
        _buildDot(Colors.black),
        const SizedBox(width: 10),
        _buildDot(Colors.black),
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
        backgroundColor:
            selectedOption.isNotEmpty ? Color(0xFF582805) : Colors.white,
        foregroundColor:
            selectedOption.isNotEmpty ? Colors.white : Color(0xFF582805),
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
