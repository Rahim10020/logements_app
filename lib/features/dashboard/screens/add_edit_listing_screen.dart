import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/cities_data.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/add_edit_listing_provider.dart';

/// Écran d'ajout/édition d'annonce
class AddEditListingScreen extends StatefulWidget {
  final String? listingId; // null = création, sinon édition

  const AddEditListingScreen({
    super.key,
    this.listingId,
  });

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();

  bool get isEditing => widget.listingId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadListing();
    }
  }

  Future<void> _loadListing() async {
    final provider = context.read<AddEditListingProvider>();
    await provider.loadListing(widget.listingId!);

    // Remplir les controllers
    _descriptionController.text = provider.description;
    _addressController.text = provider.address ?? '';
    _areaController.text = provider.area > 0 ? provider.area.toString() : '';
    _priceController.text =
        provider.monthlyPrice > 0 ? provider.monthlyPrice.toString() : '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
          color: AppColors.textDark,
        ),
        title: Text(
          isEditing ? 'Modifier l\'annonce' : 'Nouvelle annonce',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Consumer<AddEditListingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && isEditing) {
            return const LoadingIndicator(message: 'Chargement...');
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Photos
                _buildPhotosSection(provider),
                const SizedBox(height: 24),

                // Localisation
                _buildLocationSection(provider),
                const SizedBox(height: 24),

                // Détails
                _buildDetailsSection(provider),
                const SizedBox(height: 24),

                // Prix et surface
                _buildPriceAreaSection(provider),
                const SizedBox(height: 24),

                // Description
                _buildDescriptionSection(provider),
                const SizedBox(height: 24),

                // Commodités
                _buildAmenitiesSection(provider),
                const SizedBox(height: 32),

                // Bouton soumettre
                _buildSubmitButton(provider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Section photos
  Widget _buildPhotosSection(AddEditListingProvider provider) {
    final totalImages =
        provider.selectedImages.length + provider.uploadedImageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$totalImages/10',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Bouton ajouter photo
              if (totalImages < 10)
                GestureDetector(
                  onTap: provider.pickImages,
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 32, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'Ajouter',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

              // Images uploadées
              ...provider.uploadedImageUrls.asMap().entries.map((entry) {
                return _buildImagePreview(
                  imageUrl: entry.value,
                  onRemove: () => provider.removeUploadedImage(entry.key),
                );
              }),

              // Images sélectionnées
              ...provider.selectedImages.asMap().entries.map((entry) {
                return _buildImagePreview(
                  imageFile: entry.value,
                  onRemove: () => provider.removeImage(entry.key),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(
      {File? imageFile, String? imageUrl, required VoidCallback onRemove}) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: imageFile != null
              ? FileImage(imageFile)
              : NetworkImage(imageUrl!) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section localisation
  Widget _buildLocationSection(AddEditListingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        // Ville
        DropdownButtonFormField<String>(
          initialValue: provider.city.isEmpty ? null : provider.city,
          decoration: InputDecoration(
            labelText: 'Ville *',
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
            if (value != null) {
              provider.setCity(value);
              provider.setNeighborhood(''); // Reset quartier
            }
          },
          validator: (value) => value == null ? 'Champ requis' : null,
        ),
        const SizedBox(height: 16),
        // Quartier
        DropdownButtonFormField<String>(
          initialValue:
              provider.neighborhood.isEmpty ? null : provider.neighborhood,
          decoration: InputDecoration(
            labelText: 'Quartier *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: provider.city.isEmpty
              ? []
              : TogoLocations.getNeighborhoods(provider.city)
                  .map((neighborhood) {
                  return DropdownMenuItem(
                      value: neighborhood, child: Text(neighborhood));
                }).toList(),
          onChanged: (value) {
            if (value != null) provider.setNeighborhood(value);
          },
          validator: (value) => value == null ? 'Champ requis' : null,
        ),
        const SizedBox(height: 16),
        // Adresse (optionnel)
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Adresse précise (optionnel)',
            hintText: 'Ex: Rue de la Paix, près de...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
          onChanged: provider.setAddress,
        ),
      ],
    );
  }

  /// Section détails
  Widget _buildDetailsSection(AddEditListingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type et caractéristiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        // Type de propriété
        DropdownButtonFormField<String>(
          initialValue:
              provider.propertyType.isEmpty ? null : provider.propertyType,
          decoration: InputDecoration(
            labelText: 'Type de bien *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: TogoLocations.propertyTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            if (value != null) provider.setPropertyType(value);
          },
          validator: (value) => value == null ? 'Champ requis' : null,
        ),
        const SizedBox(height: 16),
        // Chambres et salles de bain
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: provider.bedrooms,
                decoration: InputDecoration(
                  labelText: 'Chambres *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: List.generate(11, (i) => i).map((value) {
                  return DropdownMenuItem(value: value, child: Text('$value'));
                }).toList(),
                onChanged: (value) {
                  if (value != null) provider.setBedrooms(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: provider.bathrooms,
                decoration: InputDecoration(
                  labelText: 'Salles de bain *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: List.generate(6, (i) => i + 1).map((value) {
                  return DropdownMenuItem(value: value, child: Text('$value'));
                }).toList(),
                onChanged: (value) {
                  if (value != null) provider.setBathrooms(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section prix et surface
  Widget _buildPriceAreaSection(AddEditListingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prix et surface',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix mensuel (FCFA) *',
                  hintText: '150000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0;
                  provider.setMonthlyPrice(price);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  if (double.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Surface (m²) *',
                  hintText: '60',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  final area = double.tryParse(value) ?? 0;
                  provider.setArea(area);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  if (double.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section description
  Widget _buildDescriptionSection(AddEditListingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Description détaillée *',
            hintText:
                'Décrivez votre bien, son environnement, ses avantages...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            alignLabelWithHint: true,
          ),
          onChanged: provider.setDescription,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Champ requis';
            if (value.length < 20) {
              return 'Description trop courte (min 20 caractères)';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Section commodités
  Widget _buildAmenitiesSection(AddEditListingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commodités',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAmenityChip(
                'Meublé', provider.furnished, provider.toggleFurnished),
            _buildAmenityChip('Climatisation', provider.airConditioning,
                provider.toggleAirConditioning),
            _buildAmenityChip('WiFi', provider.wifi, provider.toggleWifi),
            _buildAmenityChip(
                'Parking', provider.parking, provider.toggleParking),
            _buildAmenityChip('Cuisine équipée', provider.equippedKitchen,
                provider.toggleEquippedKitchen),
            _buildAmenityChip(
                'Balcon', provider.balcony, provider.toggleBalcony),
            _buildAmenityChip(
                'Générateur', provider.generator, provider.toggleGenerator),
            _buildAmenityChip(
                'Château d\'eau', provider.waterTank, provider.toggleWaterTank),
            _buildAmenityChip(
                'Forage', provider.borehole, provider.toggleBorehole),
            _buildAmenityChip(
                'Sécurité', provider.security, provider.toggleSecurity),
            _buildAmenityChip('Clôturé', provider.fence, provider.toggleFence),
            _buildAmenityChip(
                'Sol carrelé', provider.tiledFloor, provider.toggleTiledFloor),
            _buildAmenityChip(
                'Ventilateur', provider.ceilingFan, provider.toggleCeilingFan),
            _buildAmenityChip(
                'Compteur électrique',
                provider.individualElectricMeter,
                provider.toggleIndividualElectricMeter),
            _buildAmenityChip('Compteur d\'eau', provider.individualWaterMeter,
                provider.toggleIndividualWaterMeter),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey[300]!,
      ),
    );
  }

  /// Bouton soumettre
  Widget _buildSubmitButton(AddEditListingProvider provider) {
    return Column(
      children: [
        // Barre de progression upload
        if (provider.isLoading && provider.uploadProgress > 0) ...[
          LinearProgressIndicator(
            value: provider.uploadProgress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload des images... ${(provider.uploadProgress * 100).toInt()}%',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
        ],

        // Bouton
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing
                        ? 'Enregistrer les modifications'
                        : 'Publier l\'annonce',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Soumettre le formulaire
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final provider = context.read<AddEditListingProvider>();

    if (authProvider.currentUser == null) {
      // Laisser le router global gérer la redirection vers le login; informer l'utilisateur en attendant
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour publier une annonce'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      if (isEditing) {
        await provider.updateListing(
            widget.listingId!, authProvider.currentUser!.uid);
      } else {
        await provider.createListing(authProvider.currentUser!.uid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Annonce modifiée avec succès'
                  : 'Annonce publiée avec succès',
            ),
            backgroundColor: AppColors.success,
          ),
        );
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
