import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
  static const int maxPhotos = 15;

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
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedPhotos = [];
  bool _isScrolled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > AddEventSpaceStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <=
            AddEventSpaceStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedPhotos.length >= AddEventSpaceStyles.maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Maximum ${AddEventSpaceStyles.maxPhotos} photos autorisées'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPhotos.add(File(image.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
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
                        color: Colors.transparent,
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
        color: Colors.transparent,
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

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Photos de l\'espace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_selectedPhotos.length}/${AddEventSpaceStyles.maxPhotos}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (_selectedPhotos.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedPhotos[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
            label: const Text(
              'Ajouter une photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9747FF),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AddEventSpaceStyles.borderRadius),
              ),
              elevation: 0,
            ),
          ),
        )
      ],
    );
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 1,
                    maxLines: null,
                    decoration:
                        AddEventSpaceStyles.inputDecoration('Description')
                            .copyWith(
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ExampleSection(),
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
                  DropdownButtonFormField<String>(
                    decoration: AddEventSpaceStyles.inputDecoration('Ville')
                        .copyWith(prefixIcon: const Icon(Icons.location_city)),
                    items: const [],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: AddEventSpaceStyles.inputDecoration('Commune')
                        .copyWith(prefixIcon: const Icon(Icons.place)),
                    items: const [],
                    onChanged: (value) {},
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
              child: const Center(
                child: Text("Sélectionnez les activités"),
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: AddEventSpaceStyles.inputDecoration('Téléphone')
                        .copyWith(prefixIcon: const Icon(Icons.phone))
                        .copyWith(
                          hintText: '+225 XX XX XX XX XX',
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration:
                        AddEventSpaceStyles.inputDecoration('Prix').copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          '₣',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      suffixText: 'FCFA',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildPhotoSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Implement form submission with photos
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AddEventSpaceStyles.borderRadius),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Demander la création de l\'espace',
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

class ExampleSection extends StatefulWidget {
  const ExampleSection({Key? key}) : super(key: key);

  @override
  State<ExampleSection> createState() => _ExampleSectionState();
}

class _ExampleSectionState extends State<ExampleSection> {
  bool _isExpanded = false;

  static const String exampleText = '''Nom de l'espace : Le Jardin des Rêves
Description : Situé en plein cœur d'Abidjan, Le Jardin des Rêves est un espace événementiel unique, conçu pour transformer vos moments spéciaux en souvenirs inoubliables. Avec une capacité d'accueil de 300 personnes, cet espace offre une combinaison parfaite entre modernité et nature.
✨ Caractéristiques principales :
* Cadre enchanteur : Un jardin verdoyant et aménagé, idéal pour les mariages, réceptions, et soirées en plein air.
* Équipements modernes : Salle climatisée avec système audio haut de gamme, éclairage LED personnalisable, et Wi-Fi gratuit.
* Espaces polyvalents : Une salle principale modulable, une terrasse extérieure et un espace lounge.
📍 Localisation : Situé à Cocody Riviera, à 10 minutes du centre-ville et facilement accessible avec un parking privé sécurisé.
🎉 Services inclus :
* Organisation clé en main avec décoration personnalisée.
* Traiteur gastronomique sur demande.
* Service de sécurité et nettoyage.
Tarifs : À partir de 200,000 FCFA selon les prestations choisies. Contactez-nous dès aujourd'hui pour réserver votre date et créer des moments magiques !''';

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(const ClipboardData(text: exampleText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exemple copié dans le presse-papiers'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AddEventSpaceStyles.borderRadius),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Titre avec flex pour prendre l'espace disponible
                Expanded(
                  child: const Text(
                    'Exemple',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Boutons avec taille minimale
                IconButton(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copier',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  tooltip: _isExpanded ? 'Voir moins' : 'Voir plus',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SelectableText(
                exampleText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
