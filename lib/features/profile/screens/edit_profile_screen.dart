import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/cities_data.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Écran d'édition du profil
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedCity;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user;

    if (user != null) {
      _displayNameController.text = user.displayName;
      _phoneController.text = user.phone;
      _selectedCity = user.city;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Si non connecté, afficher un loader (le redirect global gère la redirection vers /auth/login)
    if (authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBack(),
          color: AppColors.textDark,
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const LoadingIndicator(message: 'Chargement...');
          }

          final user = profileProvider.user;
          if (user == null) {
            return const Center(child: Text('Erreur de chargement'));
          }

          return Form(
            key: _formKey,
            onChanged: () {
              setState(() {
                _hasChanges = true;
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Photo de profil
                _buildProfilePhotoSection(profileProvider, user),
                const SizedBox(height: 32),

                // Nom complet
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    if (value.length < 3) {
                      return 'Minimum 3 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Téléphone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone *',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    hintText: '90 00 00 00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    if (value.length < 8) {
                      return 'Numéro invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ville
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'Ville *',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: TogoLocations.cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      _hasChanges = true;
                    });
                  },
                  validator: (value) => value == null ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Email (non modifiable)
                TextFormField(
                  initialValue: user.email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'L\'email ne peut pas être modifié',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton enregistrer
                _buildSaveButton(profileProvider, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Section photo de profil
  Widget _buildProfilePhotoSection(ProfileProvider provider, user) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: provider.selectedImage != null
                  ? Image.file(
                      provider.selectedImage!,
                      fit: BoxFit.cover,
                    )
                  : (user.photoURL != null && user.photoURL!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.photoURL!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildAvatarPlaceholder(user),
                        )
                      : _buildAvatarPlaceholder(user)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                await provider.pickProfileImage();
                setState(() {
                  _hasChanges = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserModel user) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Bouton enregistrer
  Widget _buildSaveButton(ProfileProvider provider, AuthProvider authProvider) {
    return Column(
      children: [
        // Barre de progression upload
        if (provider.isUpdating && provider.uploadProgress > 0) ...[
          LinearProgressIndicator(
            value: provider.uploadProgress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload de la photo... ${(provider.uploadProgress * 100).toInt()}%',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
        ],

        // Bouton
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isUpdating || !_hasChanges
                ? null
                : () => _saveProfile(provider, authProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: provider.isUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Gérer le retour
  void _handleBack() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Modifications non enregistrées'),
          content: const Text(
            'Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuer à éditer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Quitter'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  /// Enregistrer le profil
  Future<void> _saveProfile(
    ProfileProvider provider,
    AuthProvider authProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await provider.updateProfile(
        userId: authProvider.currentUser!.uid,
        displayName: _displayNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _selectedCity,
        uploadNewImage: provider.selectedImage != null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _hasChanges = false;
        });
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Une erreur est survenue'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
