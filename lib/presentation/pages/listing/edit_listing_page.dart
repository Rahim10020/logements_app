import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logements_app/core/constants/amenities.dart';
import 'package:logements_app/core/constants/togo_locations.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';
import 'package:logements_app/presentation/providers/listing_provider.dart';

/// Page d'édition d'une annonce existante
class EditListingPage extends ConsumerStatefulWidget {
  final String listingId;

  const EditListingPage({super.key, required this.listingId});

  @override
  ConsumerState<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends ConsumerState<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();

  ListingType? _selectedType;
  String? _selectedCity;
  String? _selectedNeighborhood;
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  final Set<String> _selectedAmenities = {};
  List<String> _existingImages = [];
  final List<XFile> _newImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  ListingModel? _originalListing;

  @override
  void initState() {
    super.initState();
    _loadListing();
  }

  Future<void> _loadListing() async {
    final listingAsync = ref.read(listingByIdProvider(widget.listingId));

    listingAsync.when(
      data: (listing) {
        if (listing != null) {
          setState(() {
            _originalListing = listing;
            _titleController.text = listing.title;
            _descriptionController.text = listing.description;
            _priceController.text = listing.price.toString();
            _areaController.text = listing.area.toString();
            _addressController.text = listing.address;
            _selectedType = listing.type;
            _selectedCity = listing.city;
            _selectedNeighborhood = listing.neighborhood;
            _selectedBedrooms = listing.bedrooms;
            _selectedBathrooms = listing.bathrooms;
            _selectedAmenities.addAll(listing.amenities);
            _existingImages = List.from(listing.images);
            _isLoading = false;
          });
        }
      },
      loading: () => setState(() => _isLoading = true),
      error: (_, __) => setState(() => _isLoading = false),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload new images to Firebase Storage
      final newImageUrls = <String>[];
      for (var i = 0; i < _newImages.length; i++) {
        final imagePath = _newImages[i].path;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('listings')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}_$i.jpg');

        await storageRef.putFile(File(imagePath));
        final url = await storageRef.getDownloadURL();
        newImageUrls.add(url);
      }

      // Combine existing and new images
      final allImages = [..._existingImages, ...newImageUrls];

      // Create updated listing
      final updatedListing = _originalListing!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        price: double.parse(_priceController.text),
        city: _selectedCity!,
        neighborhood: _selectedNeighborhood!,
        address: _addressController.text.trim(),
        area: double.parse(_areaController.text),
        bedrooms: _selectedBedrooms!,
        bathrooms: _selectedBathrooms!,
        amenities: _selectedAmenities.toList(),
        images: allImages,
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await ref
          .read(listingControllerProvider.notifier)
          .updateListing(updatedListing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce mise à jour avec succès!')),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_originalListing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Annonce non trouvée'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'annonce'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            TextButton(
              onPressed: _updateListing,
              child: const Text('Enregistrer'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations de base
            Text(
              'Informations de base',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'Ex: Appartement moderne 2 chambres',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Décrivez le logement...',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<ListingType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de logement',
              ),
              items: ListingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value),
              validator: (value) {
                if (value == null) {
                  return 'Sélectionnez un type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix (FCFA/mois)',
                hintText: '50000',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le prix est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Localisation
            Text(
              'Localisation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ville',
              ),
              items: TogoLocations.allCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                  _selectedNeighborhood = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Sélectionnez une ville';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_selectedCity != null)
              DropdownButtonFormField<String>(
                initialValue: _selectedNeighborhood,
                decoration: const InputDecoration(
                  labelText: 'Quartier',
                ),
                items: TogoLocations.getNeighborhoods(_selectedCity!)
                    .map((neighborhood) {
                  return DropdownMenuItem(
                    value: neighborhood,
                    child: Text(neighborhood),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedNeighborhood = value),
                validator: (value) {
                  if (value == null) {
                    return 'Sélectionnez un quartier';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse complète',
                hintText: 'Ex: Rue 123, près de...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'adresse est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Détails
            Text(
              'Détails',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Surface (m²)',
                hintText: '50',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La surface est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _selectedBedrooms,
              decoration: const InputDecoration(
                labelText: 'Nombre de chambres',
              ),
              items: List.generate(6, (i) => i).map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value == 0
                      ? 'Studio'
                      : '$value chambre${value > 1 ? 's' : ''}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedBedrooms = value),
              validator: (value) {
                if (value == null) {
                  return 'Sélectionnez le nombre de chambres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _selectedBathrooms,
              decoration: const InputDecoration(
                labelText: 'Nombre de salles de bain',
              ),
              items: List.generate(5, (i) => i + 1).map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value salle${value > 1 ? 's' : ''} de bain'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedBathrooms = value),
              validator: (value) {
                if (value == null) {
                  return 'Sélectionnez le nombre de salles de bain';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Commodités
            Text(
              'Commodités',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            ...AmenityCategory.values.map((category) {
              final categoryAmenities =
                  Amenities.all.where((a) => a.category == category).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: categoryAmenities.map((amenity) {
                      final isSelected =
                          _selectedAmenities.contains(amenity.id);
                      return FilterChip(
                        label: Text(amenity.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity.id);
                            } else {
                              _selectedAmenities.remove(amenity.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Images
            Text(
              'Photos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Ajouter des photos'),
            ),
            const SizedBox(height: 16),

            // Existing images
            if (_existingImages.isNotEmpty) ...[
              Text(
                'Photos actuelles',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _existingImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () => _removeExistingImage(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // New images
            if (_newImages.isNotEmpty) ...[
              Text(
                'Nouvelles photos',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _newImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_newImages[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () => _removeNewImage(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
