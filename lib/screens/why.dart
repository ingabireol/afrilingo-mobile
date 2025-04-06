import 'package:afrilingo/screens/goal.dart';
import 'package:flutter/material.dart';
//import '../screens/auth/sign_in_screen.dart';

class WhyScreen extends StatefulWidget {
  final String hearAboutUsOption;
  final String levelOfUser;

  const WhyScreen({
    super.key,
    required this.hearAboutUsOption,
    required this.levelOfUser,
  });

  @override
  _WhyScreenState createState() => _WhyScreenState();
}

class _WhyScreenState extends State<WhyScreen> {
  String _selectedOption = '';
  String _hearAboutUsOption = '';
  String _levelOfUser = '';

  @override
  void initState() {
    super.initState();
    _hearAboutUsOption = widget.hearAboutUsOption;
    _levelOfUser = widget.levelOfUser;
    print('Heard about us from: ${widget.hearAboutUsOption}');
    print('Level of user: ${widget.levelOfUser}');
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
                  'Why are you learning kinyarwanda? ',
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
                const SizedBox(height: 26),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOptionContainer('Job opportunities',
                        isSelected: _selectedOption == 'Job opportunities'),
                    const SizedBox(height: 26),
                    _buildOptionContainer('culture',
                        isSelected: _selectedOption == 'culture'),
                    const SizedBox(height: 26),
                    _buildOptionContainer('Family/friends',
                        isSelected: _selectedOption == 'Family/friends'),
                    const SizedBox(height: 26),
                    _buildOptionContainer('Schools',
                        isSelected: _selectedOption == 'Schools'),
                    const SizedBox(height: 26),
                    _buildOptionContainer('Others (please specify)',
                        isSelected:
                            _selectedOption == 'Others (please specify)'),
                  ],
                ),
                const SizedBox(height: 40),
                _buildNextButton(
                  context: context,
                  selectedOption: _selectedOption,
                  nextScreen: GoalScreen(
                    hearAboutUsOption: _hearAboutUsOption,
                    levelOfUser: _levelOfUser,
                    whyOption: _selectedOption,
                  ),
                )
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
