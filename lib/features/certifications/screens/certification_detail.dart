class CertificateDetailScreen extends StatelessWidget {
  final Certificate certificate;

  const CertificateDetailScreen({
    Key? key,
    required this.certificate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificate Details'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Certificate Preview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified,
                    size: 80,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'CERTIFICATE OF PROFICIENCY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'African Language Learning Platform',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'This certifies that you have achieved',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${certificate.proficiencyLevel} PROFICIENCY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'in ${_getLanguageName(certificate.languageTested)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'with a score of ${certificate.finalScore}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Certificate Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certificate Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  _buildInfoRow('Certificate ID', certificate.certificateId),
                  _buildInfoRow('Language', _getLanguageName(certificate.languageTested)),
                  _buildInfoRow('Proficiency Level', certificate.proficiencyLevel),
                  _buildInfoRow('Final Score', '${certificate.finalScore}%'),
                  _buildInfoRow('Completed', _formatDate(certificate.completedAt)),
                  _buildInfoRow('Issued', _formatDate(certificate.issuedAt)),
                  _buildInfoRow('Status', certificate.verified ? 'Verified' : 'Pending'),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadCertificate(context),
                    icon: Icon(Icons.download),
                    label: Text('Download PDF Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareCertificate(context),
                    icon: Icon(Icons.share),
                    label: Text('Share Achievement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _verifyCertificate(context),
                    icon: Icon(Icons.verified_user),
                    label: Text('Verify Certificate'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade600),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
    if (certificate.certificateUrl != null) {
      try {
        final Uri url = Uri.parse(certificate.certificateUrl!);
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
    final languageName = _getLanguageName(certificate.languageTested);
    final text = 'I just earned my ${certificate.proficiencyLevel} certification in $languageName with a score of ${certificate.finalScore}%! 🎓\n\nCertificate ID: ${certificate.certificateId}\nVerify at: ${certificate.certificateUrl}';
    Share.share(text);
  }

  void _verifyCertificate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Certificate Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To verify this certificate, use the following information:'),
            SizedBox(height: 16),
            Text('Certificate ID: ${certificate.certificateId}', 
                 style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Verification URL: ${certificate.certificateUrl}'),
            SizedBox(height: 16),
            Text('This certificate is ${certificate.verified ? "verified and authentic" : "pending verification"}.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (certificate.certificateUrl != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _launchVerificationUrl(context);
              },
              child: Text('Open Verification Page'),
            ),
        ],
      ),
    );
  }

  void _launchVerificationUrl(BuildContext context) async {
    if (certificate.certificateUrl != null) {
      try {
        final Uri url = Uri.parse(certificate.certificateUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalBrowser);
        }
      } catch (e) {
        _showError(context, 'Error opening verification page: $e');
      }
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