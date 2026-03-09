import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_press_scale.dart';
import '../../../core/widgets/surface_container.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  bool _isUploadingAvatar = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.displayName);
    _usernameController = TextEditingController(text: profile.username);
    _phoneController = TextEditingController(text: profile.phone);
    _bioController = TextEditingController(text: profile.bio);

    _nameController.addListener(_markChanged);
    _usernameController.addListener(_markChanged);
    _phoneController.addListener(_markChanged);
    _bioController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    final bytes = await image.readAsBytes();
    final extension = image.path.split('.').last;
    await ref
        .read(profileProvider.notifier)
        .uploadAvatar(bytes, 'avatar.$extension');
    if (mounted) setState(() => _isUploadingAvatar = false);
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    final updates = <String, dynamic>{};

    final profile = ref.read(profileProvider);
    if (_nameController.text.trim() != profile.displayName) {
      updates['display_name'] = _nameController.text.trim();
    }
    if (_usernameController.text.trim() != profile.username) {
      updates['username'] = _usernameController.text.trim();
    }
    if (_phoneController.text.trim() != profile.phone) {
      updates['phone'] = _phoneController.text.trim();
    }
    if (_bioController.text.trim() != profile.bio) {
      updates['bio'] = _bioController.text.trim();
    }

    if (updates.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final success = await ref.read(profileProvider.notifier).updateProfile(updates);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              bottom: 16,
            ),
            child: Row(
              children: [
                AnimatedPressScale(
                  onTap: () => Navigator.pop(context),
                  child: SurfaceContainer(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.close,
                        color: AppColors.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Edit Profile', style: AppTypography.displaySmall),
                const Spacer(),
                AnimatedPressScale(
                  onTap: profile.isSaving ? null : _save,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _hasChanges
                          ? AppColors.buttonPrimary
                          : AppColors.buttonSecondary,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    child: profile.isSaving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                        : Text(
                      'Save',
                      style: AppTypography.labelLarge.copyWith(
                        color: _hasChanges
                            ? AppColors.buttonPrimaryText
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Avatar section
                  Center(
                    child: Column(
                      children: [
                        AnimatedPressScale(
                          onTap: _isUploadingAvatar ? null : _pickAvatar,
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceElevated,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _isUploadingAvatar
                                      ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accent,
                                    ),
                                  )
                                      : profile.avatarUrl.isNotEmpty
                                      ? Image.network(
                                    profile.avatarUrl,
                                    fit: BoxFit.cover,
                                    width: 96,
                                    height: 96,
                                    errorBuilder: (_, __, ___) =>
                                        _AvatarFallback(
                                            name: profile.displayName),
                                  )
                                      : _AvatarFallback(
                                      name: profile.displayName),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.textSecondary,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change photo',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Form fields
                  _FieldLabel(label: 'DISPLAY NAME'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _nameController,
                    hint: 'Your full name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),

                  _FieldLabel(label: 'USERNAME'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _usernameController,
                    hint: '@username',
                    icon: Icons.alternate_email,
                    prefix: '@',
                  ),
                  const SizedBox(height: 24),

                  _FieldLabel(label: 'EMAIL'),
                  const SizedBox(height: 8),
                  SurfaceContainer(
                    borderRadius: AppSpacing.inputRadius,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.mail_outline,
                            color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          profile.email,
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Verified',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.success,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Email cannot be changed here. Contact support.',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _FieldLabel(label: 'PHONE NUMBER'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _phoneController,
                    hint: '+1 (555) 000-0000',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  _FieldLabel(label: 'BIO'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _bioController,
                    hint: 'Tell us about yourself...',
                    icon: Icons.edit_outlined,
                    maxLines: 3,
                    maxLength: 160,
                  ),
                  const SizedBox(height: 36),

                  // Danger zone
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.04),
                      borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danger Zone',
                            style: AppTypography.labelLarge.copyWith(
                                color: AppColors.error)),
                        const SizedBox(height: 12),
                        AnimatedPressScale(
                          onTap: () => _showDeleteConfirmation(context),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Delete Account',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.error),
                              ),
                              const Spacer(),
                              Icon(Icons.chevron_right,
                                  color: AppColors.error.withValues(alpha: 0.5),
                                  size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: bottomPadding + 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 20),
              Text('Delete Account?',
                  style: AppTypography.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'This action is permanent and cannot be undone. All your data, bookings, and loyalty points will be deleted.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedPressScale(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.buttonSecondary,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: AppTypography.labelLarge),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedPressScale(
                      onTap: () {
                        Navigator.pop(ctx);
                        // Account deletion handled server-side
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius),
                        ),
                        child: Center(
                          child: Text('Delete',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Reusable Form Components
// ─────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.overline);
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? prefix;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.prefix,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceContainer(
      borderRadius: AppSpacing.inputRadius,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
            child: Icon(icon, color: AppColors.textTertiary, size: 18),
          ),
          const SizedBox(width: 12),
          if (prefix != null)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(prefix!,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary)),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14),
                counterText: '',
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTypography.displayMedium
              .copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}