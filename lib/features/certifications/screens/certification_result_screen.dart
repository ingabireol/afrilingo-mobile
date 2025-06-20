// certification_result_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificationResultScreen extends StatelessWidget {
  final CertificationSession session;
  final Certificate? certificate;

  const CertificationResultScreen({
    Key? key,
    required this.session,
    this.certificate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool passed = certificate != null;
    final String languageName = _getLanguageName(session.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text('Test Results'),
        backgroundColor: passed ? Colors.green.shade700 : Colors.orange.shade700,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Result Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed 
                      ? [Colors.green.shade700, Colors.green.shade500]
                      : [Colors.orange.shade700, Colors.orange.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.celebration : Icons.refresh,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    passed ? 'Congratulations!' : 'Keep Learning!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    passed 
                        ? 'You have successfully passed your $languageName certification!'
                        : 'You scored ${session.finalScore}% on your $languageName certification.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Score Details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Test Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  _buildResultRow('Final Score', '${session.finalScore}%'),
                  _buildResultRow('Questions Answered', '${session.correctAnswers}/${session.totalQuestions}'),
                  _buildResultRow('Test Level', session.testLevel),
                  _buildResultRow('Language', languageName),
                  _buildResultRow('Date Completed', _formatDate(session.endTime!)),
                  
                  if (certificate != null) ...[
                    Divider(height: 32),
                    _buildResultRow('Proficiency Level', certificate!.proficiencyLevel),
                    _buildResultRow('Certificate ID', certificate!.certificateId),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Certificate Section
            if (certificate != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your Certificate is Ready!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your official language proficiency certificate has been generated and is ready for download.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    
                    // Certificate Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadCertificate(context),
                            icon: Icon(Icons.download),
                            label: Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareCertificate(context),
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Failed test guidance
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 50,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Keep Learning!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You need 70% or higher to earn certification. Continue practicing and try again when you\'re ready!',
                      style: TextStyle(color: Colors.orange.shade700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/lessons',
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                      ),
                      child: Text('Continue Learning'),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 32),
            
            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Return to Dashboard',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                if (!passed)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        '/certification-start',
                        arguments: {
                          'languageCode': session.languageCode,
                          'languageName': languageName,
                        },
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue.shade600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Retake Test',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'rw': case 'kin': return 'Kinyarwanda';
      case 'sw': case 'swa': return 'Swahili';
      case 'am': case 'amh': return 'Amharic';
      case 'ha': case 'hau': return 'Hausa';
      case 'yo': case 'yor': return 'Yoruba';
      case 'ig': case 'ibo': return 'Igbo';
      case 'zu': case 'zul': return 'Zulu';
      case 'af': case 'afr': return 'Afrikaans';
      default: return languageCode.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _downloadCertificate(BuildContext context) async {
    if (certificate?.certificateUrl != null) {
      try {
        final Uri url = Uri.parse(certificate!.certificateUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showError(context, 'Unable to download certificate');
        }
      } catch (e) {
        _showError(context, 'Error downloading certificate: $e');
      }
    }
  }

  void _shareCertificate(BuildContext context) {
    if (certificate != null) {
      final text = 'I just earned my ${certificate!.proficiencyLevel} certification in ${_getLanguageName(certificate!.languageTested)} with a score of ${certificate!.finalScore}%! 🎓\n\nVerify at: ${certificate!.certificateUrl}';
      Share.share(text);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}