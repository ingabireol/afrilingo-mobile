import 'package:flutter/material.dart';
import 'package:afrilingo/services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioService.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioService.positionStream.listen((position) {
      if (position != null) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioService.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (_isPlaying) {
                  _audioService.pauseAudio();
                } else {
                  _audioService.playAudio(widget.audioUrl);
                }
              },
            ),
            const SizedBox(width: 16),
            Text(
              _formatDuration(_position),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  // TODO: Implement seeking
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(_duration),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
} 