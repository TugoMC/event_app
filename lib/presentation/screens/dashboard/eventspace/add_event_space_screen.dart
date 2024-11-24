import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/phone_number_validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventSpaceStyles {
  static const double appBarTotalHeight = 52.0 + kToolbarHeight + 44.0;
  static const double buttonRowHeight = 52.0;
  static const double circularButtonSize = 46.0;
  static const double bannerHeight = 44.0;
  static const double horizontalPadding = 24.0;
  static const double verticalSpacing = 20.0;
  static const double borderRadius = 16.0;
  static const double titleContainerHeight = 46.0;
  static const EdgeInsets contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets titlePadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const double spaceBetweenButtonAndTitle = 8.0;
  static const double scrollThreshold = 80.0;

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: contentPadding,
    );
  }
}

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
  final ScrollController _scrollController = ScrollController();

  City? selectedCity;
  Commune? selectedCommune;
  List<Activity> selectedActivities = [];
  bool isLoading = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  void _onScroll() {
    if (_scrollController.offset > 80 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 80 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(AddEventSpaceStyles.appBarTotalHeight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: AddEventSpaceStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: AddEventSpaceStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: AddEventSpaceStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AddEventSpaceStyles.horizontalPadding),
                        child: Row(
                          children: [
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height: AddEventSpaceStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: AddEventSpaceStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: AddEventSpaceStyles.horizontalPadding),
                      padding: AddEventSpaceStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            AddEventSpaceStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Nouvel Espace Événementiel',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: AddEventSpaceStyles.circularButtonSize,
      height: AddEventSpaceStyles.circularButtonSize,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPhotoUrlFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Photos de l\'espace'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _photoUrlControllers.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _photoUrlControllers[index],
                      decoration: AddEventSpaceStyles.inputDecoration(
                              'URL de la photo ${index + 1}')
                          .copyWith(
                        hintText: 'https://example.com/photo.jpg',
                        prefixIcon: const Icon(Icons.photo_library_outlined),
                      ),
                      validator: _validateUrl,
                    ),
                  ),
                  if (_photoUrlControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      onPressed: () => setState(() {
                        _photoUrlControllers[index].dispose();
                        _photoUrlControllers.removeAt(index);
                      }),
                    ),
                ],
              ),
            );
          },
        ),
        ElevatedButton.icon(
          onPressed: () =>
              setState(() => _photoUrlControllers.add(TextEditingController())),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Ajouter une photo'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AddEventSpaceStyles.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est requis';
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
    if (!_formKey.currentState!.validate()) return;

    if (selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins une activité')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final eventSpaceId =
          FirebaseFirestore.instance.collection('event_spaces').doc().id;
      final photoUrls = _photoUrlControllers
          .map((controller) => controller.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

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

      await FirebaseFirestore.instance
          .collection('event_spaces')
          .doc(eventSpaceId)
          .set(eventSpace.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Espace créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: AddEventSpaceStyles.appBarTotalHeight + 20,
            bottom: 32,
            left: 24,
            right: 24,
          ),
          children: [
            _buildSectionTitle('Informations générales'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        AddEventSpaceStyles.inputDecoration('Nom de l\'espace')
                            .copyWith(prefixIcon: const Icon(Icons.business)),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration:
                        AddEventSpaceStyles.inputDecoration('Description')
                            .copyWith(
                                prefixIcon: const Icon(Icons.description)),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ce champ est requis';
                      if (value.length < EventSpace.minDescriptionLength) {
                        return 'Description trop courte (minimum ${EventSpace.minDescriptionLength} caractères)';
                      }
                      if (value.length > EventSpace.maxDescriptionLength) {
                        return 'Description trop longue (maximum ${EventSpace.maxDescriptionLength} caractères)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Localisation'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cities')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<City> cities = snapshot.data!.docs
                          .map((doc) =>
                              City.fromJson(doc.data() as Map<String, dynamic>))
                          .toList();

                      return DropdownButtonFormField<City>(
                        value: selectedCity,
                        decoration: AddEventSpaceStyles.inputDecoration('Ville')
                            .copyWith(
                                prefixIcon: const Icon(Icons.location_city)),
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        List<Commune> communes = snapshot.data!.docs
                            .map((doc) => Commune.fromJson(
                                doc.data() as Map<String, dynamic>))
                            .toList();

                        return DropdownButtonFormField<Commune>(
                          value: selectedCommune,
                          decoration:
                              AddEventSpaceStyles.inputDecoration('Commune')
                                  .copyWith(
                                      prefixIcon: const Icon(Icons.place)),
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
                          validator: (value) =>
                              value == null ? 'Ce champ est requis' : null,
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration:
                        AddEventSpaceStyles.inputDecoration('Lien Google Maps')
                            .copyWith(
                      prefixIcon: const Icon(Icons.map),
                      hintText: 'https://maps.google.com/...',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ce champ est requis';
                      final uri = Uri.tryParse(value);
                      if (uri == null ||
                          !uri.host.contains('google.com') ||
                          !uri.path.contains('maps')) {
                        return 'L\'URL doit être une URL Google Maps valide';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Activités disponibles'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Activity> activities = snapshot.data!.docs
                      .map((doc) => Activity.fromJson(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
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
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                        backgroundColor: Colors.grey[50],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Informations pratiques'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _hoursController,
                    decoration: AddEventSpaceStyles.inputDecoration('Horaires')
                        .copyWith(prefixIcon: const Icon(Icons.access_time)),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                  ),
                  const SizedBox(height: 16),
                  PhoneNumberInput(
                    controller: _phoneController,
                    decoration: AddEventSpaceStyles.inputDecoration('Téléphone')
                        .copyWith(prefixIcon: const Icon(Icons.phone)),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ce champ est requis';
                      final phoneRegExp = RegExp(r'^\+?[\d\s-]{8,}$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return 'Format de numéro de téléphone invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration:
                        AddEventSpaceStyles.inputDecoration('Prix').copyWith(
                      prefixIcon: const Icon(Icons.euro),
                      suffixText: 'FCFA',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ce champ est requis';
                      final price = double.tryParse(value);
                      if (price == null || price < 0) return 'Prix invalide';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildPhotoUrlFields(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createEventSpace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Créer l\'espace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
