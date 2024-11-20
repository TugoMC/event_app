// add_event_space_screen.dart
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/phone_number_validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventSpaceScreen extends StatefulWidget {
  const AddEventSpaceScreen({Key? key}) : super(key: key);

  @override
  _AddEventSpaceScreenState createState() => _AddEventSpaceScreenState();
}

class _AddEventSpaceScreenState extends State<AddEventSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final List<TextEditingController> _photoUrlControllers = [
    TextEditingController()
  ];

  City? selectedCity;
  Commune? selectedCommune;
  List<Activity> selectedActivities = [];
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    for (var controller in _photoUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }

    final phoneRegExp = RegExp(r'^\+?[\d\s-]{8,}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Format de numéro de téléphone invalide';
    }

    return null;
  }

  String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        return 'L\'URL doit commencer par http:// ou https://';
      }
      return null;
    } catch (e) {
      return 'URL invalide';
    }
  }

  Future<void> _createEventSpace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins une activité')),
      );
      return;
    }

    final photoUrls = _photoUrlControllers
        .map((controller) => controller.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (photoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Au moins une URL de photo est requise')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Création d'un ID unique pour l'espace événementiel
      final eventSpaceId =
          FirebaseFirestore.instance.collection('event_spaces').doc().id;

      final eventSpace = EventSpace(
        id: eventSpaceId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        commune: selectedCommune!,
        city: selectedCity!,
        activities: selectedActivities,
        reviews: [],
        hours: _hoursController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        phoneNumber: _phoneController.text.trim(),
        photoUrls: photoUrls,
        location: _locationController.text.trim(),
        createdAt: DateTime.now(),
        createdBy: user.uid,
      );

      // Création du document dans Firestore
      await FirebaseFirestore.instance
          .collection('event_spaces')
          .doc(eventSpaceId)
          .set(eventSpace.toJson())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Timeout lors de la sauvegarde'),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Espace créé avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('Erreur détaillée: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildPhotoUrlFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'URLs des photos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _photoUrlControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _photoUrlControllers[index],
                      decoration: InputDecoration(
                        labelText: 'URL de la photo ${index + 1}',
                        hintText: 'https://example.com/photo.jpg',
                      ),
                      validator: validateUrl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_photoUrlControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          _photoUrlControllers[index].dispose();
                          _photoUrlControllers.removeAt(index);
                        });
                      },
                      color: Colors.red,
                    ),
                ],
              ),
            );
          },
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _photoUrlControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une URL de photo'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un espace'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (value.length < EventSpace.minDescriptionLength) {
                    return 'Description trop courte (minimum ${EventSpace.minDescriptionLength} caractères)';
                  }
                  if (value.length > EventSpace.maxDescriptionLength) {
                    return 'Description trop longue (maximum ${EventSpace.maxDescriptionLength} caractères)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('cities').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  List<City> cities = snapshot.data!.docs
                      .map((doc) =>
                          City.fromJson(doc.data() as Map<String, dynamic>))
                      .toList();

                  return DropdownButtonFormField<City>(
                    value: selectedCity,
                    items: cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (City? value) {
                      setState(() {
                        selectedCity = value;
                        selectedCommune = null;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Ville'),
                    validator: (value) =>
                        value == null ? 'Ce champ est requis' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (selectedCity != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('communes')
                      .where('cityId', isEqualTo: selectedCity!.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    List<Commune> communes = snapshot.data!.docs
                        .map((doc) => Commune.fromJson(
                            doc.data() as Map<String, dynamic>))
                        .toList();

                    return DropdownButtonFormField<Commune>(
                      value: selectedCommune,
                      items: communes.map((commune) {
                        return DropdownMenuItem(
                          value: commune,
                          child: Text(commune.name),
                        );
                      }).toList(),
                      onChanged: (Commune? value) {
                        setState(() {
                          selectedCommune = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Commune'),
                      validator: (value) =>
                          value == null ? 'Ce champ est requis' : null,
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Text('Activités disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  List<Activity> activities = snapshot.data!.docs
                      .map((doc) => Activity.fromJson(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: activities.map((activity) {
                      return FilterChip(
                        label: Text(activity.type),
                        selected: selectedActivities.contains(activity),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedActivities.add(activity);
                            } else {
                              selectedActivities
                                  .removeWhere((a) => a.id == activity.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(labelText: 'Horaires'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              PhoneNumberInput(
                controller: _phoneController,
                validator: validatePhoneNumber,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localisation (Google Maps URL)',
                  hintText: 'https://maps.google.com/...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null ||
                      !uri.host.contains('google.com') ||
                      !uri.path.contains('maps')) {
                    return 'L\'URL doit être une URL Google Maps valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPhotoUrlFields(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _createEventSpace,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Créer l\'espace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
