import 'package:flutter/material.dart';

class CertificatesScreen extends StatefulWidget {
  @override
  _CertificatesScreenState createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final CertificationService _certificationService = CertificationService();
  List<Certificate> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      final certificates = await _certificationService.getUserCertificates();
      setState(() {
        _certificates = certificates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load certificates: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Certificates'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _certificates.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _certificates.length,
                  itemBuilder: (context, index) {
                    return _buildCertificateCard(_certificates[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No Certificates Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete certification tests to earn your first certificate!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/languages'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Start Certification'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    final languageName = _getLanguageName(certificate.languageTested);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 32,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$languageName Proficiency',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Text(
                            certificate.proficiencyLevel,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        '${certificate.finalScore}%',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Issued: ${_formatDate(certificate.issuedAt)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Spacer(),
                    Icon(Icons.fingerprint, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Text(
                      certificate.certificateId,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewCertificate(certificate),
                        icon: Icon(Icons.visibility, size: 18),
                        label: Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadCertificate(certificate),
                        icon: Icon(Icons.download, size: 18),
                        label: Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _shareCertificate(certificate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Icon(Icons.share, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  void _viewCertificate(Certificate certificate) {
    // Navigate to certificate detail view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificateDetailScreen(certificate: certificate),
      ),
    );
  }

  void _downloadCertificate(Certificate certificate) async {
    if (certificate.certificateUrl != null) {
      try {
        final Uri url = Uri.parse(certificate.certificateUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareCertificate(Certificate certificate) {
    final languageName = _getLanguageName(certificate.languageTested);
    final text = 'I just earned my ${certificate.proficiencyLevel} certification in $languageName with a score of ${certificate.finalScore}%! 🎓\n\nVerify at: ${certificate.certificateUrl}';
    Share.share(text);
  }
}