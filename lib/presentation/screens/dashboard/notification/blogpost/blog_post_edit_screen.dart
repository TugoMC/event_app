import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BlogEditStyles {
  static const double appBarTotalHeight = 52.0 + kToolbarHeight + 44.0;
  static const double buttonRowHeight = 52.0;
  static const double circularButtonSize = 46.0;
  static const double bannerHeight = 44.0;
  static const double circularButtonMargin = 5.0;
  static const double horizontalPadding = 24.0;
  static const double titleContainerHeight = 46.0;
  static const EdgeInsets titlePadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const double spaceBetweenButtonAndTitle = 8.0;
  static const double borderRadius = 20.0;
  static const double scrollThreshold = 80.0;
  static const double cardPadding = 16.0;
  static const double cardSpacing = 12.0;
  static const double tagSpacing = 8.0;
}

class BlogPostEditScreen extends StatefulWidget {
  final BlogPost? post;

  const BlogPostEditScreen({Key? key, this.post}) : super(key: key);

  @override
  _BlogPostEditScreenState createState() => _BlogPostEditScreenState();
}

class _BlogPostEditScreenState extends State<BlogPostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  // Scroll state
  bool _isScrolled = false;

  // Pagination variables
  static const int _pageSize = 10;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;

  // Form fields
  late String _title;
  late String _description;
  String? _selectedEventSpaceId;
  EventSpace? _selectedEventSpace;
  late List<BlogTag> _tags;
  bool _isPromotional = false;
  double? _promotionalPrice;
  DateTime? _promotionalStartDate;
  DateTime? _promotionalEndDate;
  DateTime? _validUntil;

  // Filter fields
  City? _selectedCity;
  Commune? _selectedCommune;
  List<City> _availableCities = [];
  List<Commune> _availableCommunes = [];
  List<EventSpace> _eventSpaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
    _initializeFormData();
  }

  void _onScroll() {
    if (_scrollController.offset > BlogEditStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= BlogEditStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _initializeFormData() {
    if (widget.post != null) {
      _title = widget.post!.title;
      _description = widget.post!.description;
      _selectedEventSpaceId = widget.post!.eventSpaceId;
      _tags = List.from(widget.post!.tags);

      if (widget.post!.promotionalPrice != null) {
        _isPromotional = true;
        _promotionalPrice = widget.post!.promotionalPrice!.promotionalPrice;
        _promotionalStartDate = widget.post!.promotionalPrice!.startDate;
        _promotionalEndDate = widget.post!.promotionalPrice!.endDate;
      }
      _validUntil = widget.post!.validUntil;
    } else {
      _title = '';
      _description = '';
      _tags = [];
    }
  }

  Widget _buildEditCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: BlogEditStyles.cardSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(BlogEditStyles.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(BlogEditStyles.appBarTotalHeight),
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
          toolbarHeight: BlogEditStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: BlogEditStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: BlogEditStyles.buttonRowHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: BlogEditStyles.horizontalPadding),
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
                    const SizedBox(
                        height: BlogEditStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: BlogEditStyles.titleContainerHeight,
                      margin: const EdgeInsets.symmetric(
                          horizontal: BlogEditStyles.horizontalPadding),
                      padding: BlogEditStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(BlogEditStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.post == null
                            ? 'Créer un article'
                            : 'Modifier l\'article',
                        style: const TextStyle(
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
      width: BlogEditStyles.circularButtonSize,
      height: BlogEditStyles.circularButtonSize,
      margin: const EdgeInsets.symmetric(
          horizontal: BlogEditStyles.circularButtonMargin),
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

  Future<void> _loadInitialData() async {
    try {
      final citiesSnapshot = await _firestore.collection('cities').get();
      setState(() {
        _availableCities = citiesSnapshot.docs
            .map((doc) => City.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      });
      await _loadEventSpaces();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading initial data: $e');
    }
  }

  Future<void> _loadEventSpaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Query query = _firestore.collection('event_spaces');

      if (_selectedCity != null) {
        query = query.where('city.id', isEqualTo: _selectedCity!.id);
      }

      if (_selectedCommune != null) {
        query = query.where('commune.id', isEqualTo: _selectedCommune!.id);
      }

      query = query.limit(_pageSize);
      final querySnapshot = await query.get();

      setState(() {
        _eventSpaces = querySnapshot.docs
            .map((doc) => EventSpace.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();

        _hasMoreData = querySnapshot.docs.length == _pageSize;

        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }

        // Retrouver l'espace événementiel sélectionné s'il existe
        if (_selectedEventSpaceId != null) {
          _selectedEventSpace = _eventSpaces.firstWhere(
            (space) => space.id == _selectedEventSpaceId,
            orElse: () {
              _showErrorSnackBar('Espace événementiel non trouvé');
              return _eventSpaces.first;
            },
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des espaces: $e');
    }
  }

  Future<void> _loadMoreEventSpaces() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      Query query = _firestore.collection('event_spaces');

      if (_selectedCity != null) {
        query = query.where('city.id', isEqualTo: _selectedCity!.id);
      }

      if (_selectedCommune != null) {
        query = query.where('commune.id', isEqualTo: _selectedCommune!.id);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);
      final querySnapshot = await query.get();

      setState(() {
        final newEventSpaces = querySnapshot.docs
            .map((doc) => EventSpace.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();

        _eventSpaces.addAll(newEventSpaces);
        _hasMoreData = newEventSpaces.length == _pageSize;

        if (newEventSpaces.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(
          'Erreur lors du chargement des espaces supplémentaires: $e');
    }
  }

  void _onCityChanged(City? newCity) {
    setState(() {
      _selectedCity = newCity;
      _selectedCommune = null;
      _availableCommunes = [];

      if (newCity != null) {
        _loadCommunes(newCity);
      }

      // Réinitialiser la pagination et recharger les espaces
      _lastDocument = null;
      _eventSpaces = [];
      _loadEventSpaces();
    });
  }

  Future<void> _loadCommunes(City city) async {
    try {
      final communesSnapshot = await _firestore
          .collection('communes')
          .where('cityId', isEqualTo: city.id)
          .get();

      setState(() {
        _availableCommunes = communesSnapshot.docs
            .map((doc) => Commune.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement des communes: $e');
    }
  }

  void _onCommuneChanged(Commune? newCommune) {
    setState(() {
      _selectedCommune = newCommune;

      // Réinitialiser la pagination et recharger les espaces
      _lastDocument = null;
      _eventSpaces = [];
      _loadEventSpaces();
    });
  }

  Future<void> _savePost() async {
    // Validation du prix promotionnel
    if (_isPromotional) {
      if (_promotionalPrice == null) {
        _showErrorSnackBar('Veuillez entrer un prix promotionnel');
        return;
      }
      if (_promotionalStartDate == null || _promotionalEndDate == null) {
        _showErrorSnackBar('Veuillez sélectionner les dates de promotion');
        return;
      }
      if (_promotionalStartDate!.isAfter(_promotionalEndDate!)) {
        _showErrorSnackBar(
            'La date de début doit être antérieure à la date de fin');
        return;
      }
    }

    // Validation de l'offre limitée
    if (_tags.contains(BlogTag.offreLimitee) && _validUntil == null) {
      _showErrorSnackBar('Une offre limitée doit avoir une date de validité');
      return;
    }

    if (_formKey.currentState!.validate() && _selectedEventSpace != null) {
      _formKey.currentState!.save();

      try {
        // Préparation de l'objet prix promotionnel
        BlogPromotionalPrice? promotionalPriceObj;
        if (_isPromotional &&
            _promotionalPrice != null &&
            _promotionalStartDate != null &&
            _promotionalEndDate != null) {
          if (_promotionalPrice! >= _selectedEventSpace!.price) {
            _showErrorSnackBar(
                'Le prix promotionnel doit être inférieur au prix original');
            return;
          }

          promotionalPriceObj = BlogPromotionalPrice(
            promotionalPrice: _promotionalPrice!,
            startDate: _promotionalStartDate!,
            endDate: _promotionalEndDate!,
          );
        }

        final blogPost = BlogPost(
          id: widget.post?.id,
          title: _title,
          description: _description,
          eventSpaceId: _selectedEventSpace!.id,
          eventSpacePrice: _selectedEventSpace!.price,
          createdAt: widget.post?.createdAt ?? DateTime.now(),
          validUntil: _validUntil,
          tags: _tags,
          promotionalPrice: promotionalPriceObj,
        );

        if (widget.post == null) {
          await _firestore.collection('blogPosts').add(blogPost.toJson());
          _showErrorSnackBar('Article créé avec succès');
        } else {
          await _firestore
              .collection('blogPosts')
              .doc(widget.post!.id)
              .update(blogPost.toJson());
          _showErrorSnackBar('Article mis à jour avec succès');
        }

        Navigator.pop(context);
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context,
      {bool isValidUntil = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        if (isValidUntil) {
          _validUntil = picked;
        } else if (_promotionalStartDate == null) {
          _promotionalStartDate = picked;
        } else {
          if (picked.isAfter(_promotionalStartDate!)) {
            _promotionalEndDate = picked;
          } else {
            _showErrorSnackBar(
                'La date de fin doit être postérieure à la date de début');
          }
        }
      });
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.only(
              top: BlogEditStyles.appBarTotalHeight + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditCard(
                  'Informations générales',
                  Column(
                    children: [
                      TextFormField(
                        initialValue: _title,
                        decoration: const InputDecoration(
                          labelText: 'Titre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Veuillez entrer un titre'
                            : null,
                        onSaved: (value) => _title = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Veuillez entrer une description'
                            : null,
                        onSaved: (value) => _description = value!,
                      ),
                    ],
                  ),
                ),
                _buildEditCard(
                  'Localisation',
                  Column(
                    children: [
                      DropdownButtonFormField<City>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'Ville',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableCities
                            .map((city) => DropdownMenuItem(
                                value: city, child: Text(city.name)))
                            .toList(),
                        onChanged: _onCityChanged,
                      ),
                      if (_selectedCity != null) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Commune>(
                          value: _selectedCommune,
                          decoration: const InputDecoration(
                            labelText: 'Commune',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableCommunes
                              .map((commune) => DropdownMenuItem(
                                  value: commune, child: Text(commune.name)))
                              .toList(),
                          onChanged: _onCommuneChanged,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildEditCard(
                  'Espace événementiel',
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  _eventSpaces.length + (_hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _eventSpaces.length) {
                                  return TextButton(
                                    onPressed: _loadMoreEventSpaces,
                                    child: const Text('Charger plus'),
                                  );
                                }

                                final eventSpace = _eventSpaces[index];
                                return RadioListTile<EventSpace>(
                                  title: Text(eventSpace.name),
                                  subtitle: Text(
                                      '${eventSpace.commune.name}, ${eventSpace.city.name}\nPrix: ${NumberFormat('#,##0', 'fr_FR').format(eventSpace.price)} FCFA'),
                                  value: eventSpace,
                                  groupValue: _selectedEventSpace,
                                  onChanged: (EventSpace? value) {
                                    setState(() {
                                      _selectedEventSpace = value;
                                      _selectedEventSpaceId = value?.id;
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                ),
                _buildEditCard(
                  'Étiquettes',
                  Wrap(
                    spacing: BlogEditStyles.tagSpacing,
                    runSpacing: BlogEditStyles.tagSpacing,
                    children: BlogTag.values
                        .map((tag) => FilterChip(
                              label: Text(tag.name),
                              selected: _tags.contains(tag),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _tags.add(tag);
                                  } else {
                                    _tags.remove(tag);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
                _buildEditCard(
                  'Prix promotionnel',
                  Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Activer le prix promotionnel'),
                        value: _isPromotional,
                        onChanged: (bool value) {
                          setState(() {
                            _isPromotional = value;
                            if (!value) {
                              _promotionalPrice = null;
                              _promotionalStartDate = null;
                              _promotionalEndDate = null;
                            }
                          });
                        },
                      ),
                      if (_isPromotional) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _promotionalPrice?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Prix promotionnel',
                            border: OutlineInputBorder(),
                            suffixText: 'FCFA',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un prix promotionnel';
                            }
                            final price = double.tryParse(value);
                            if (price == null) {
                              return 'Veuillez entrer un prix valide';
                            }
                            if (_selectedEventSpace != null &&
                                price >= _selectedEventSpace!.price) {
                              return 'Le prix promotionnel doit être inférieur au prix original';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _promotionalPrice = double.tryParse(value);
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date de début',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _promotionalStartDate != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(_promotionalStartDate!)
                                        : 'Sélectionner',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date de fin',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _promotionalEndDate != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(_promotionalEndDate!)
                                        : 'Sélectionner',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (_tags.contains(BlogTag.offreLimitee))
                  _buildEditCard(
                    'Période de validité',
                    InkWell(
                      onTap: () => _selectDate(context, isValidUntil: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin de validité',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _validUntil != null
                              ? DateFormat('dd/MM/yyyy').format(_validUntil!)
                              : 'Sélectionner',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedEventSpace != null ? _savePost : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.post == null
                          ? 'Créer l\'article'
                          : 'Mettre à jour l\'article',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
