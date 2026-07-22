import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/upload_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  File? _localAvatarFile;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final initials = user != null
        ? '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
        : 'U';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
                      child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text('Edit Profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar
                      Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadAvatar,
                          child: Stack(
                            children: [
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.shadowMd,
                                ),
                                child: _isUploadingAvatar
                                  ? const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                                  : _localAvatarFile != null
                                    ? ClipOval(child: Image.file(_localAvatarFile!, width: 100, height: 100, fit: BoxFit.cover))
                                    : user?.avatar != null && user!.avatar!.trim().isNotEmpty
                                      ? ClipOval(child: Image.network(user.avatar!.trim(), width: 100, height: 100, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)))))
                                      : Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(color: AppTheme.primaryAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        'Tap to upload or change your photo',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),

                      // Phone (read-only)
                      _buildField(label: 'Phone Number', value: user?.phone ?? '', readOnly: true, icon: Icons.phone_outlined),
                      const SizedBox(height: AppTheme.spacingMd),

                      // First Name
                      _buildFormField(controller: _firstNameController, label: 'First Name', icon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Last Name
                      _buildFormField(controller: _lastNameController, label: 'Last Name', icon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Email
                      _buildFormField(controller: _emailController, label: 'Email (optional)', icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: AppTheme.spacingXl),

                      // Role badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(color: AppTheme.pastelBlue, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        child: Row(
                          children: [
                            Icon(Icons.verified, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 10),
                            Text('Role: ${user?.role == 'technician' ? 'Technician' : 'Customer'}',
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),

                      // Save button
                      SoftGradientButton(
                        text: 'Save Changes',
                        isLoading: _isSaving,
                        onPressed: _save,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null) return;
    setState(() {
      _localAvatarFile = File(picked.path);
      _isUploadingAvatar = true;
    });
    final url = await UploadService().uploadAvatar(File(picked.path));
    if (!mounted) return;
    if (url == null) {
      setState(() {
        _isUploadingAvatar = false;
        _localAvatarFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to upload photo'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final err = await ref.read(authProvider.notifier).updateProfile(avatar: url);
    if (!mounted) return;
    setState(() {
      _isUploadingAvatar = false;
      _localAvatarFile = null;
    });
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile photo updated'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final error = await ref.read(authProvider.notifier).updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildField({required String label, required String value, bool readOnly = false, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textTertiary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.lock_outline, color: AppTheme.textTertiary, size: 16),
        ],
      ),
    );
  }

  Widget _buildFormField({required TextEditingController controller, required String label, required IconData icon, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textTertiary),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
      ),
    );
  }
}
