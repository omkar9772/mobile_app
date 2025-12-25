import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/user_bull_service.dart';
import '../../models/user_bull_sell.dart';

// If dotted_border is not in pubspec, we can use a custom painter or just a dashed border logic.
// For now, let's assume standard border with dash effect or just a solid styled border if package missing.
// Actually, let's try to use a standardized container first.

class AddBullScreen extends StatefulWidget {
  final UserBullSell? bullToEdit;

  const AddBullScreen({Key? key, this.bullToEdit}) : super(key: key);

  @override
  State<AddBullScreen> createState() => _AddBullScreenState();
}

class _AddBullScreenState extends State<AddBullScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserBullService _bullService = UserBullService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form fields
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _breedController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  File? _imageFile;
  XFile? _imageXFile; // Store XFile for web upload
  String? _imageUrl; // For web blob URLs or existing image URL
  bool _isSubmitting = false;
  bool _isEditMode = false;
  String? _existingImageUrl; // Store the existing image URL when editing

  // Constants
  static const double maxImageSizeMB = 5.0;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'];
  static const List<String> allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic', 'image/heif'];

  @override
  void initState() {
    super.initState();
    if (widget.bullToEdit != null) {
      _isEditMode = true;
      final bull = widget.bullToEdit!;
      _nameController.text = bull.name;
      _priceController.text = bull.price.toStringAsFixed(0);
      if (bull.ownerName != null) _ownerNameController.text = bull.ownerName!;
      if (bull.ownerMobile != null) _mobileController.text = bull.ownerMobile!;
      if (bull.breed != null) _breedController.text = bull.breed!;
      if (bull.birthYear != null) _birthYearController.text = bull.birthYear.toString();
      if (bull.color != null) _colorController.text = bull.color!;
      if (bull.description != null) _descriptionController.text = bull.description!;
      if (bull.location != null) _locationController.text = bull.location!;
      _existingImageUrl = bull.imageUrl;
      _imageUrl = bull.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _breedController.dispose();
    _birthYearController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        // ... (Existing validation logic)
         _imageXFile = image;
         await _cropImage(image.path);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    try {
       if (kIsWeb && MediaQuery.of(context).size.width < 600) {
        setState(() {
          _imageUrl = imagePath;
          _imageFile = File(imagePath);
        });
        return;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppTheme.primaryOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
        compressQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
          if (kIsWeb) _imageUrl = croppedFile.path;
        });
      }
    } catch (e) {
      _showError('Failed to crop image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
              ),
              title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed, behavior: SnackBarBehavior.floating),
    );
  }

   Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // For create mode, require image. For edit mode, image is optional (can keep existing)
    if (!_isEditMode && _imageFile == null) {
      _showError('Please select an image');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditMode) {
        // Update existing bull - always send required fields (name, price, owner_name, owner_mobile)
        await _bullService.updateBull(
          id: widget.bullToEdit!.id,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          ownerName: _ownerNameController.text.trim(), // Required field - always send
          ownerMobile: _mobileController.text.trim(), // Required field - always send
          imageFile: _imageFile, // null if not changed
          imageXFile: _imageXFile,
          breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
          birthYear: _birthYearController.text.trim().isEmpty ? null : int.tryParse(_birthYearController.text.trim()),
          color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully!'), backgroundColor: AppTheme.successGreen),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create new bull
        await _bullService.createBull(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          ownerName: _ownerNameController.text.trim(),
          ownerMobile: _mobileController.text.trim(),
          imageFile: _imageFile,
          imageXFile: _imageXFile,
          breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
          birthYear: _birthYearController.text.trim().isEmpty ? null : int.tryParse(_birthYearController.text.trim()),
          color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing created successfully!'), backgroundColor: AppTheme.successGreen),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: AppTheme.primaryOrange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_isEditMode ? 'Edit Bull' : 'Sell Your Bull', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Required Details'),
                    const SizedBox(height: 16),
                     _buildTextField(
                      controller: _nameController,
                      label: 'Bull Name',
                      icon: Icons.person_outline,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Price (₹)',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Name',
                      icon: Icons.person,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Contact Mobile',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Optional Details'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(controller: _breedController, label: 'Breed', icon: Icons.category_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(controller: _birthYearController, label: 'Birth Year', icon: Icons.calendar_today, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _colorController, label: 'Color', icon: Icons.palette_outlined),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _locationController, label: 'Location', icon: Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isEditMode ? 'Update Listing' : 'Add Listing', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 300, // Large square-ish area
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: _imageFile == null ? Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid) : null, // Fallback solid if Dashed not available
          boxShadow: [
             if (_imageFile != null)
               BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: _imageFile == null && _imageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo, size: 40, color: AppTheme.primaryOrange),
                  ),
                  const SizedBox(height: 16),
                  const Text('Upload Bull Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Tap to select from gallery', style: TextStyle(color: Colors.grey.shade400)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _imageFile != null
                        ? (kIsWeb && _imageUrl != null
                            ? Image.network(_imageUrl!, fit: BoxFit.cover)
                            : Image.file(_imageFile!, fit: BoxFit.cover))
                        : (_imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (_, __, ___) => const Icon(Icons.error),
                              )
                            : Container(color: Colors.grey)),
                  ),
                  Positioned(
                    top: 16, right: 16,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _imageFile = null;
                        _imageXFile = null;
                        if (!_isEditMode) _imageUrl = null; // Only clear URL in create mode
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(_isEditMode && _imageFile == null ? Icons.edit : Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),
                  ),
                   Positioned(
                    bottom: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                           Icon(Icons.crop, color: Colors.white, size: 14),
                           SizedBox(width: 4),
                           Text('Square', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          height: 20, width: 4,
          decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
