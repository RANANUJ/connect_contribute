import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_models.dart';
import '../services/firestore_service.dart';
import 'dart:math' as math;

class CreateNGOScreen extends StatefulWidget {
  const CreateNGOScreen({super.key});

  @override
  State<CreateNGOScreen> createState() => _CreateNGOScreenState();
}

class _CreateNGOScreenState extends State<CreateNGOScreen> {
  final PageController _pageController = PageController();
  final FirestoreService _firestoreService = FirestoreService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String _generatedCode = '';

  // Form keys
  final _basicFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  // Basic Information Controllers
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Detailed Information Controllers
  final _establishedYearController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _websiteController = TextEditingController();
  final _activitiesController = TextEditingController();

  // Contact Information Controllers
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _establishedYearController.dispose();
    _registrationNumberController.dispose();
    _websiteController.dispose();
    _activitiesController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  String _generateNGOCode(String ngoName) {
    final prefix = ngoName.length >= 3 
        ? ngoName.substring(0, 3).toUpperCase()
        : ngoName.toUpperCase().padRight(3, 'X');
    final random = math.Random();
    final number = random.nextInt(9999).toString().padLeft(4, '0');
    return '$prefix$number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Create NGO Organization'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                _buildStepIndicator(0, 'Basic Info'),
                _buildStepConnector(),
                _buildStepIndicator(1, 'Details'),
                _buildStepConnector(),
                _buildStepIndicator(2, 'Contact'),
                _buildStepConnector(),
                _buildStepIndicator(3, 'Review'),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildDetailsStep(),
                _buildContactStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentStep < 3 ? 'Next' : 'Create NGO',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
                ? const Color(0xFF2E7D32)
                : isActive 
                    ? const Color(0xFF2E7D32)
                    : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _basicFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s start with the essential details of your NGO',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildFormField(
              controller: _nameController,
              label: 'NGO Name',
              hint: 'Enter your organization name',
              icon: Icons.business,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter NGO name';
                }
                if (value.length < 3) {
                  return 'NGO name must be at least 3 characters';
                }
                return null;
              },
              onChanged: (value) {
                if (value.length >= 3) {
                  setState(() {
                    _generatedCode = _generateNGOCode(value);
                  });
                }
              },
            ),
            
            if (_generatedCode.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E7D32)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generated Organization Code',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _generatedCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _generatedCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Code copied to clipboard'),
                                    backgroundColor: Color(0xFF2E7D32),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.copy,
                                size: 20,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _categoryController,
              label: 'Category',
              hint: 'e.g., Education, Healthcare, Environment',
              icon: Icons.category,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _locationController,
              label: 'Location',
              hint: 'City, State, Country',
              icon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Brief description of your NGO\'s mission and goals',
              icon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                if (value.length < 50) {
                  return 'Description must be at least 50 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Additional details about your organization',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildFormField(
              controller: _establishedYearController,
              label: 'Established Year',
              hint: 'YYYY',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter established year';
                }
                final year = int.tryParse(value);
                if (year == null || year < 1800 || year > DateTime.now().year) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _registrationNumberController,
              label: 'Registration Number',
              hint: 'Official registration number (optional)',
              icon: Icons.badge,
            ),
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _websiteController,
              label: 'Website',
              hint: 'https://www.yourwebsite.com (optional)',
              icon: Icons.web,
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _activitiesController,
              label: 'Main Activities',
              hint: 'Separate activities with commas (e.g., Education, Healthcare, Community Development)',
              icon: Icons.work,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter main activities';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How can people reach your organization?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildFormField(
              controller: _contactEmailController,
              label: 'Contact Email',
              hint: 'contact@yourorganization.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            _buildFormField(
              controller: _contactPhoneController,
              label: 'Contact Phone',
              hint: '+1 234 567 8900',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact phone';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Social Media Links (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFormField(
              controller: _facebookController,
              label: 'Facebook',
              hint: 'https://facebook.com/yourpage',
              icon: Icons.facebook,
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 16),
            _buildFormField(
              controller: _twitterController,
              label: 'Twitter',
              hint: 'https://twitter.com/yourhandle',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 16),
            _buildFormField(
              controller: _instagramController,
              label: 'Instagram',
              hint: 'https://instagram.com/yourhandle',
              icon: Icons.camera_alt,
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 16),
            _buildFormField(
              controller: _linkedinController,
              label: 'LinkedIn',
              hint: 'https://linkedin.com/company/yourcompany',
              icon: Icons.business,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Create',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review all information before creating your NGO',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildReviewSection(
            title: 'Basic Information',
            items: [
              ReviewItem('NGO Name', _nameController.text),
              ReviewItem('Organization Code', _generatedCode),
              ReviewItem('Category', _categoryController.text),
              ReviewItem('Location', _locationController.text),
              ReviewItem('Description', _descriptionController.text),
            ],
          ),
          
          const SizedBox(height: 24),
          _buildReviewSection(
            title: 'Detailed Information',
            items: [
              ReviewItem('Established Year', _establishedYearController.text),
              ReviewItem('Registration Number', _registrationNumberController.text.isEmpty ? 'Not provided' : _registrationNumberController.text),
              ReviewItem('Website', _websiteController.text.isEmpty ? 'Not provided' : _websiteController.text),
              ReviewItem('Main Activities', _activitiesController.text),
            ],
          ),
          
          const SizedBox(height: 24),
          _buildReviewSection(
            title: 'Contact Information',
            items: [
              ReviewItem('Email', _contactEmailController.text),
              ReviewItem('Phone', _contactPhoneController.text),
              if (_facebookController.text.isNotEmpty) ReviewItem('Facebook', _facebookController.text),
              if (_twitterController.text.isNotEmpty) ReviewItem('Twitter', _twitterController.text),
              if (_instagramController.text.isNotEmpty) ReviewItem('Instagram', _instagramController.text),
              if (_linkedinController.text.isNotEmpty) ReviewItem('LinkedIn', _linkedinController.text),
            ],
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Note',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your organization code ($_generatedCode) will be used by members to join your NGO. Keep it secure and share it only with authorized members.',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({required String title, required List<ReviewItem> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '${item.label}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() async {
    switch (_currentStep) {
      case 0:
        if (_basicFormKey.currentState!.validate()) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      case 1:
        if (_detailsFormKey.currentState!.validate()) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      case 2:
        if (_contactFormKey.currentState!.validate()) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      case 3:
        await _createNGO();
        break;
    }
  }

  Future<void> _createNGO() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure NGO code is generated
      if (_generatedCode.isEmpty) {
        _generatedCode = _generateNGOCode(_nameController.text);
      }
      
      if (_generatedCode.isEmpty) {
        throw 'Failed to generate NGO code';
      }
      
      // Parse activities
      final activities = _activitiesController.text
          .split(',')
          .map((activity) => activity.trim())
          .where((activity) => activity.isNotEmpty)
          .toList();

      // Build social media links
      final socialMediaLinks = <String, String>{};
      if (_facebookController.text.isNotEmpty) {
        socialMediaLinks['facebook'] = _facebookController.text;
      }
      if (_twitterController.text.isNotEmpty) {
        socialMediaLinks['twitter'] = _twitterController.text;
      }
      if (_instagramController.text.isNotEmpty) {
        socialMediaLinks['instagram'] = _instagramController.text;
      }
      if (_linkedinController.text.isNotEmpty) {
        socialMediaLinks['linkedin'] = _linkedinController.text;
      }

      final ngo = NGOModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        location: _locationController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        website: _websiteController.text.trim(),
        establishedYear: int.parse(_establishedYearController.text),
        registrationNumber: _registrationNumberController.text.trim(),
        isVerified: true,
        isActive: true,
        memberCount: 0,
        activities: activities,
        socialMediaLinks: socialMediaLinks,
        additionalInfo: {},
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        ngoCode: _generatedCode,
      );

      print('Attempting to create NGO with code: ${_generatedCode}');
      print('NGO name: ${ngo.name}');
      
      await _firestoreService.createNGO(ngo);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NGO "${ngo.name}" created successfully! Code: ${ngo.ngoCode}'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Create NGO error details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating NGO: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class ReviewItem {
  final String label;
  final String value;

  ReviewItem(this.label, this.value);
}
