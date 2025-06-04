import 'package:flutter/material.dart';
import 'package:afrilingo/models/lesson.dart';
import 'package:afrilingo/services/audio_service.dart';
import 'package:afrilingo/widgets/audio_player_widget.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:afrilingo/services/theme_provider.dart';

// African-inspired color palette (kept as fallback)
const Color kPrimaryColor = Color(0xFF8B4513); // Brown
const Color kSecondaryColor = Color(0xFFC78539); // Light brown
const Color kAccentColor = Color(0xFF546CC3); // Blue accent
const Color kBackgroundColor = Color(0xFFF9F5F1); // Cream background
const Color kTextColor = Color(0xFF333333); // Dark text
const Color kLightTextColor = Color(0xFF777777); // Light text
const Color kCardColor = Color(0xFFFFFFFF); // White card background
const Color kDividerColor = Color(0xFFEEEEEE); // Light divider

class LessonContentWidget extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onContentCompleted;

  const LessonContentWidget({
    Key? key,
    required this.lesson,
    this.onContentCompleted,
  }) : super(key: key);

  @override
  State<LessonContentWidget> createState() => _LessonContentWidgetState();
}

class _LessonContentWidgetState extends State<LessonContentWidget>
    with SingleTickerProviderStateMixin {
  int currentStepIndex = 0;
  final PageController _pageController = PageController();
  List<LearningStep> learningSteps = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _parseLearningSteps();
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _parseLearningSteps() {
    learningSteps = [];
    if (widget.lesson.contents != null) {
      for (var content in widget.lesson.contents!) {
        if (content.contentType == 'TEXT' && content.contentData != null) {
          final lines = content.contentData.split('\n');
          String? currentSection;
          List<String> currentSectionBullets = [];

          for (var line in lines) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) continue;

            // Section headersment (# or ##)
            final headerMatch = RegExp(r'^(#+)\s*(.*)').firstMatch(trimmed);
            if (headerMatch != null) {
              // If we have accumulated bullets for a previous section, add them first
              if (currentSection != null && currentSectionBullets.isNotEmpty) {
                learningSteps.add(LearningStep(
                  type: StepType.bulletList,
                  content: currentSectionBullets.join('\n'),
                  section: currentSection,
                ));
                currentSectionBullets = [];
              }

              // Add the new section header
              final headerLevel = headerMatch.group(1)!.length;
              currentSection = headerMatch
                  .group(2)!
                  .replaceAll(RegExp(r'[\*`_]'), '')
                  .trim();

              // Only add level 1 and 2 headers as separate cards
              if (headerLevel <= 2) {
                learningSteps.add(LearningStep(
                  type: headerLevel == 1
                      ? StepType.mainHeader
                      : StepType.subHeader,
                  content: currentSection,
                ));
              }
              continue;
            }

            // Bullet points
            if (trimmed.startsWith('*')) {
              // Extract the bullet content, handling "term - definition" format
              final bulletContent = trimmed.replaceFirst('*', '').trim();
              final cleanBullet =
                  bulletContent.replaceAll(RegExp(r'[\*`_]'), '').trim();

              if (cleanBullet.isNotEmpty) {
                // Check if this is a phrase with translation
                if (cleanBullet.contains(' - ')) {
                  final parts = cleanBullet.split(' - ');
                  final phrase = parts[0].trim();
                  final translation = parts.length > 1 ? parts[1].trim() : '';

                  learningSteps.add(LearningStep(
                    type: StepType.phrase,
                    content: phrase,
                    translation: translation,
                    section: currentSection,
                  ));
                } else {
                  // Collect bullets for the current section
                  currentSectionBullets.add(cleanBullet);
                }
              }
              continue;
            }

            // Regular text paragraph
            final cleanText = trimmed.replaceAll(RegExp(r'[\*`_]'), '').trim();
            if (cleanText.isNotEmpty) {
              learningSteps.add(LearningStep(
                type: StepType.paragraph,
                content: cleanText,
                section: currentSection,
              ));
            }
          }

          // Add any remaining bullet points
          if (currentSectionBullets.isNotEmpty) {
            learningSteps.add(LearningStep(
              type: StepType.bulletList,
              content: currentSectionBullets.join('\n'),
              section: currentSection,
            ));
          }
        } else if (content.contentType == 'AUDIO' && content.mediaUrl != null) {
          learningSteps.add(LearningStep(
            type: StepType.audio,
            content: 'Listen to the pronunciation',
            mediaUrl: content.mediaUrl,
          ));
        } else if (content.contentType == 'IMAGE' && content.mediaUrl != null) {
          learningSteps.add(LearningStep(
            type: StepType.image,
            content: 'Visual example',
            mediaUrl: content.mediaUrl,
            section: 'Visual Aid',
          ));
        }
      }
    }
  }

  void _nextStep() {
    if (currentStepIndex < learningSteps.length - 1) {
      _animationController.reset();
      setState(() {
        currentStepIndex++;
      });
      _pageController.animateToPage(
        currentStepIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
      HapticFeedback.lightImpact();

      // Check if this is the last step
      if (currentStepIndex == learningSteps.length - 1 && !_hasReachedEnd) {
        setState(() {
          _hasReachedEnd = true;
        });
        // Call the callback if provided
        if (widget.onContentCompleted != null) {
          widget.onContentCompleted!();
        }
      }
    }
  }

  void _previousStep() {
    if (currentStepIndex > 0) {
      _animationController.reset();
      setState(() {
        currentStepIndex--;
      });
      _pageController.animateToPage(
        currentStepIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (learningSteps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 64, color: themeProvider.lightTextColor),
            const SizedBox(height: 16),
            Text(
              'No learning content available.',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.lightTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Column(
        children: [
          _buildProgressBar(themeProvider),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: learningSteps.length,
              onPageChanged: (index) {
                setState(() {
                  currentStepIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemBuilder: (context, index) {
                final step = learningSteps[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStepCard(step, themeProvider),
                );
              },
            ),
          ),
          _buildNavigationControls(themeProvider),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lesson Progress',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${((currentStepIndex + 1) / learningSteps.length * 100).toInt()}%',
                style: TextStyle(
                  color: themeProvider.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: (currentStepIndex + 1) / learningSteps.length,
            backgroundColor: themeProvider.dividerColor,
            progressColor: themeProvider.primaryColor,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(LearningStep step, ThemeProvider themeProvider) {
    switch (step.type) {
      case StepType.mainHeader:
        return _buildMainHeaderCard(step, themeProvider);
      case StepType.subHeader:
        return _buildSubHeaderCard(step, themeProvider);
      case StepType.phrase:
        return _buildPhraseCard(step, themeProvider);
      case StepType.bulletList:
        return _buildBulletListCard(step, themeProvider);
      case StepType.paragraph:
        return _buildParagraphCard(step, themeProvider);
      case StepType.audio:
        return _buildAudioCard(step, themeProvider);
      case StepType.image:
        return _buildImageCard(step, themeProvider);
    }
  }

  Widget _buildMainHeaderCard(LearningStep step, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeProvider.primaryColor, themeProvider.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              step.content,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.lesson.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeaderCard(LearningStep step, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeProvider.accentColor.withOpacity(0.8),
              themeProvider.accentColor
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForSection(step.content),
              size: 56,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              step.content,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseCard(LearningStep step, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: themeProvider.secondaryColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (step.section != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeProvider.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  step.section!,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                step.content,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (step.translation != null && step.translation!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1.5,
                    width: 40,
                    color: themeProvider.dividerColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.translate,
                      size: 20,
                      color: themeProvider.lightTextColor,
                    ),
                  ),
                  Container(
                    height: 1.5,
                    width: 40,
                    color: themeProvider.dividerColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                step.translation!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.textColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tap to hear icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: themeProvider.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tap to hear pronunciation',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.lightTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletListCard(LearningStep step, ThemeProvider themeProvider) {
    final bullets = step.content.split('\n');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.section != null) ...[
              Text(
                step.section!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 2,
                width: 80,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
            ],
            ...bullets.map((bullet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: themeProvider.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        bullet,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.textColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraphCard(LearningStep step, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.section != null) ...[
              Text(
                step.section!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              step.content,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.textColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard(LearningStep step, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: themeProvider.accentColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.headphones,
                size: 56,
                color: themeProvider.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Listen to the Pronunciation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap play and repeat after the audio',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.lightTextColor,
              ),
            ),
            const SizedBox(height: 24),
            AudioPlayerWidget(audioUrl: step.mediaUrl!),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(LearningStep step, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (step.section != null) ...[
              Text(
                step.section!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                step.mediaUrl!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: themeProvider.dividerColor,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: themeProvider.lightTextColor,
                        size: 40,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: themeProvider.dividerColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: themeProvider.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              step.content,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: currentStepIndex > 0 ? _previousStep : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStepIndex > 0
                  ? themeProvider.cardColor
                  : Colors.grey.shade200,
              foregroundColor: currentStepIndex > 0
                  ? themeProvider.primaryColor
                  : Colors.grey,
              elevation: currentStepIndex > 0 ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: currentStepIndex > 0
                      ? themeProvider.primaryColor.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
            ),
          ),

          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeProvider.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentStepIndex + 1} / ${learningSteps.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: themeProvider.primaryColor,
              ),
            ),
          ),

          // Next button
          ElevatedButton.icon(
            onPressed:
                currentStepIndex < learningSteps.length - 1 ? _nextStep : null,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStepIndex < learningSteps.length - 1
                  ? themeProvider.primaryColor
                  : Colors.grey.shade200,
              foregroundColor: currentStepIndex < learningSteps.length - 1
                  ? Colors.white
                  : Colors.grey,
              elevation: currentStepIndex < learningSteps.length - 1 ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSection(String section) {
    // Determine appropriate icon based on section title
    if (section.contains('Greetings')) return Icons.waving_hand;
    if (section.contains('Numbers')) return Icons.pin;
    if (section.contains('Family')) return Icons.family_restroom;
    if (section.contains('Days')) return Icons.calendar_today;
    if (section.contains('Phrases')) return Icons.chat_bubble;
    if (section.contains('Colors')) return Icons.palette;
    if (section.contains('Food')) return Icons.restaurant;
    if (section.contains('Weather')) return Icons.cloud;
    if (section.contains('Verbs')) return Icons.directions_run;
    if (section.contains('Introduction')) return Icons.emoji_people;
    if (section.contains('Cultural')) return Icons.public;
    if (section.contains('Grammar')) return Icons.menu_book;
    if (section.contains('Questions')) return Icons.help;
    if (section.contains('Practice')) return Icons.fitness_center;

    // Default icon
    return Icons.menu_book;
  }
}

enum StepType {
  mainHeader, // Main lesson header (# Title)
  subHeader, // Section header (## Subtitle)
  phrase, // Language phrase with translation
  bulletList, // A list of bullet points
  paragraph, // Regular text paragraph
  audio, // Audio content
  image, // Image content
}

class LearningStep {
  final StepType type;
  final String content;
  final String? mediaUrl;
  final String? section;
  final String? translation;

  LearningStep({
    required this.type,
    required this.content,
    this.mediaUrl,
    this.section,
    this.translation,
  });
}
