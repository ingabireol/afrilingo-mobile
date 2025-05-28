import 'package:flutter/material.dart';
import 'package:afrilingo/models/lesson.dart';
import 'package:afrilingo/services/audio_service.dart';
import 'package:afrilingo/widgets/audio_player_widget.dart';

class LessonContentWidget extends StatefulWidget {
  final Lesson lesson;

  const LessonContentWidget({Key? key, required this.lesson}) : super(key: key);

  @override
  State<LessonContentWidget> createState() => _LessonContentWidgetState();
}

class _LessonContentWidgetState extends State<LessonContentWidget> {
  int currentStepIndex = 0;
  final PageController _pageController = PageController();
  List<LearningStep> learningSteps = [];

  @override
  void initState() {
    super.initState();
    _parseLearningSteps();
  }

  void _parseLearningSteps() {
    learningSteps = [];
    if (widget.lesson.contents != null) {
      for (var content in widget.lesson.contents!) {
        if (content.contentType == 'TEXT' && content.contentData != null) {
          final lines = content.contentData.split('\n');
          String? currentSection;
          for (var line in lines) {
            // Remove markdown symbols
            final trimmed = line.trim();
            if (trimmed.isEmpty) continue;
            // Section headers
            final headerMatch = RegExp(r'^(#+)\s*(.*)').firstMatch(trimmed);
            if (headerMatch != null) {
              currentSection = headerMatch.group(2)!.replaceAll(RegExp(r'[\*`_]'), '').trim();
              learningSteps.add(LearningStep(
                type: StepType.section,
                content: currentSection,
                mediaUrl: null,
              ));
              continue;
            }
            // Bullet points or phrases
            if (trimmed.startsWith('*')) {
              // Remove all markdown and asterisks
              final cleanLine = trimmed.replaceAll(RegExp(r'\*'), '').replaceAll(RegExp(r'[\*`_]'), '').trim();
              if (cleanLine.isNotEmpty) {
                learningSteps.add(LearningStep(
                  type: StepType.phrase,
                  content: cleanLine,
                  mediaUrl: null,
                  section: currentSection,
                ));
              }
              continue;
            }
            // Fallback: treat as plain text
            final cleanText = trimmed.replaceAll(RegExp(r'[\*`_]'), '').trim();
            if (cleanText.isNotEmpty) {
              learningSteps.add(LearningStep(
                type: StepType.phrase,
                content: cleanText,
                mediaUrl: null,
                section: currentSection,
              ));
            }
          }
        } else if (content.contentType == 'AUDIO' && content.mediaUrl != null) {
          learningSteps.add(LearningStep(
            type: StepType.audio,
            content: 'Listen to the pronunciation',
            mediaUrl: content.mediaUrl,
          ));
        }
      }
    }
    print('DEBUG: Parsed learning steps:');
    for (var step in learningSteps) {
      print('  - ${step.type} | ${step.section ?? ''} | ${step.content}');
    }
  }

  void _nextStep() {
    if (currentStepIndex < learningSteps.length - 1) {
      setState(() {
        currentStepIndex++;
      });
      _pageController.animateToPage(
        currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStepIndex > 0) {
      setState(() {
        currentStepIndex--;
      });
      _pageController.animateToPage(
        currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (learningSteps.isEmpty) {
      return const Center(child: Text('No learning content available.'));
    }
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: learningSteps.length,
            onPageChanged: (index) {
              setState(() {
                currentStepIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final step = learningSteps[index];
              return _buildStepCard(step);
            },
          ),
        ),
        _buildNavigationControls(),
      ],
    );
  }

  Widget _buildStepCard(LearningStep step) {
    switch (step.type) {
      case StepType.section:
        return _buildSectionCard(step);
      case StepType.phrase:
        return _buildPhraseCard(step);
      case StepType.audio:
        return _buildAudioCard(step);
    }
  }

  Widget _buildSectionCard(LearningStep step) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
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

  Widget _buildPhraseCard(LearningStep step) {
    // Try to split phrase and translation by ' - '
    final parts = step.content.split(' - ');
    final phrase = parts[0].trim();
    final translation = parts.length > 1 ? parts[1].trim() : '';

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (step.section != null) ...[
              Text(
                step.section!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              phrase,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (translation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                translation,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Icon(
              Icons.arrow_forward,
              color: Colors.blue.shade400,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard(LearningStep step) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.headphones,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Listen to the pronunciation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            AudioPlayerWidget(audioUrl: step.mediaUrl!),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: currentStepIndex > 0 ? _previousStep : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: TextButton.styleFrom(
              foregroundColor: currentStepIndex > 0 ? Colors.blue : Colors.grey,
            ),
          ),
          Text(
            '${currentStepIndex + 1} / ${learningSteps.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton.icon(
            onPressed: currentStepIndex < learningSteps.length - 1 ? _nextStep : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: TextButton.styleFrom(
              foregroundColor: currentStepIndex < learningSteps.length - 1 ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

enum StepType {
  section,
  phrase,
  audio,
}

class LearningStep {
  final StepType type;
  final String content;
  final String? mediaUrl;
  final String? section;

  LearningStep({
    required this.type,
    required this.content,
    this.mediaUrl,
    this.section,
  });
} 