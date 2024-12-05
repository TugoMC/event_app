import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BlogPostEditScreen extends StatefulWidget {
  final BlogPost? post;

  const BlogPostEditScreen({Key? key, this.post}) : super(key: key);

  @override
  _BlogPostEditScreenState createState() => _BlogPostEditScreenState();
}

class _BlogPostEditScreenState extends State<BlogPostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pagination variables
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;

  // Filtering variables
  City? _selectedCity;
  Commune? _selectedCommune;
  List<City> _availableCities = [];
  List<Commune> _availableCommunes = [];

  late String _title;
  late String _description;
  String? _selectedEventSpaceId;
  EventSpace? _selectedEventSpace;
  late List<BlogTag> _tags;

  // New fields for promotional pricing and validity
  bool _isPromotional = false;
  double? _promotionalPrice;
  DateTime? _promotionalStartDate;
  DateTime? _promotionalEndDate;
  DateTime? _validUntil;

  List<EventSpace> _eventSpaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // Initialize with existing post data if editing
    if (widget.post != null) {
      _title = widget.post!.title;
      _description = widget.post!.description;
      _selectedEventSpaceId = widget.post!.eventSpaceId;
      _tags = List.from(widget.post!.tags);

      // Populate promotional price fields
      if (widget.post!.promotionalPrice != null) {
        _isPromotional = true;
        _promotionalPrice = widget.post!.promotionalPrice!.promotionalPrice;
        _promotionalStartDate = widget.post!.promotionalPrice!.startDate;
        _promotionalEndDate = widget.post!.promotionalPrice!.endDate;
      }

      // Populate validity date
      _validUntil = widget.post!.validUntil;
    } else {
      // Initialize with default values for new post
      _title = '';
      _description = '';
      _tags = [];
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load available cities
      final citiesSnapshot = await _firestore.collection('cities').get();
      setState(() {
        _availableCities = citiesSnapshot.docs
            .map((doc) => City.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });

      // Load initial event spaces
      await _loadEventSpaces();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading initial data: $e')),
      );
    }
  }

  Future<void> _loadEventSpaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Query query = _firestore.collection('event_spaces');

      // Apply city filter
      if (_selectedCity != null) {
        query = query.where('city.id', isEqualTo: _selectedCity!.id);
      }

      // Apply commune filter
      if (_selectedCommune != null) {
        query = query.where('commune.id', isEqualTo: _selectedCommune!.id);
      }

      // Paginate
      query = query.limit(_pageSize);

      final querySnapshot = await query.get();

      setState(() {
        _eventSpaces = querySnapshot.docs
            .map((doc) => EventSpace.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();

        // Check if there are more documents
        _hasMoreData = querySnapshot.docs.length == _pageSize;

        // Store the last document for pagination
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }

        // If editing and event space exists, find and set it
        if (_selectedEventSpaceId != null) {
          _selectedEventSpace = _eventSpaces.firstWhere(
            (space) => space.id == _selectedEventSpaceId,
            orElse: () => throw Exception(
                'No event space found with ID $_selectedEventSpaceId'),
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event spaces: $e')),
      );
    }
  }

  Future<void> _loadMoreEventSpaces() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = _firestore.collection('event_spaces');

      // Apply city filter
      if (_selectedCity != null) {
        query = query.where('city.id', isEqualTo: _selectedCity!.id);
      }

      // Apply commune filter
      if (_selectedCommune != null) {
        query = query.where('commune.id', isEqualTo: _selectedCommune!.id);
      }

      // Start after the last document only if it exists
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // Limit the number of documents
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

        // Check if there are more documents
        _hasMoreData = newEventSpaces.length == _pageSize;

        // Update the last document for next pagination
        if (newEventSpaces.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }

        _isLoading = false;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more event spaces: $e')),
      );
    }
  }

  void _onCityChanged(City? newCity) {
    setState(() {
      _selectedCity = newCity;
      _selectedCommune = null; // Reset commune when city changes

      // Load communes for the selected city
      if (newCity != null) {
        _loadCommunes(newCity);
      } else {
        _availableCommunes = [];
      }

      // Reload event spaces with new filter
      _currentPage = 0;
      _lastDocument = null;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading communes: $e')),
      );
    }
  }

  void _onCommuneChanged(Commune? newCommune) {
    setState(() {
      _selectedCommune = newCommune;

      // Reload event spaces with new filter
      _currentPage = 0;
      _lastDocument = null;
      _loadEventSpaces();
    });
  }

  Future<void> _savePost() async {
    // Validate promotional price details
    if (_isPromotional) {
      if (_promotionalPrice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a promotional price')),
        );
        return;
      }
      if (_promotionalStartDate == null || _promotionalEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter promotional start and end dates')),
        );
        return;
      }
    }

    // Validate limited offer tag
    if (_tags.contains(BlogTag.offreLimitee) && _validUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A limited offer must have a validity period')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedEventSpace != null) {
      _formKey.currentState!.save();

      try {
        // Prepare promotional price object
        BlogPromotionalPrice? promotionalPriceObj;
        if (_isPromotional &&
            _promotionalPrice != null &&
            _promotionalStartDate != null &&
            _promotionalEndDate != null) {
          // Validate promotional price is lower than original price
          if (_promotionalPrice! >= _selectedEventSpace!.price) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Promotional price must be lower than original price')),
            );
            return;
          }

          promotionalPriceObj = BlogPromotionalPrice(
            promotionalPrice: _promotionalPrice!,
            startDate: _promotionalStartDate!,
            endDate: _promotionalEndDate!,
          );
        }

        final blogPost = BlogPost(
          id: widget.post?.id, // Use existing ID if editing
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
          // Create new post
          await _firestore.collection('blogPosts').add(blogPost.toJson());
        } else {
          // Update existing post
          await _firestore
              .collection('blogPosts')
              .doc(widget.post!.id)
              .update(blogPost.toJson());
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.post == null
                ? 'Blog post created successfully'
                : 'Blog post updated successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving post: $e')),
        );
      }
    }
  }

  // Date picker for promotional dates and validity
  Future<void> _selectDate(BuildContext context,
      {bool isValidUntil = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isValidUntil) {
          _validUntil = picked;
        } else if (_promotionalStartDate == null) {
          _promotionalStartDate = picked;
        } else {
          // Validate that end date is after start date
          if (picked.isAfter(_promotionalStartDate!)) {
            _promotionalEndDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('End date must be after start date')),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.post == null ? 'Create Blog Post' : 'Edit Blog Post'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title and Description Fields
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
            const SizedBox(height: 10),

            // City Dropdown
            DropdownButtonFormField<City>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Select City',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              hint: const Text('Choose a City'),
              items: _availableCities.map((city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(city.name),
                );
              }).toList(),
              onChanged: _onCityChanged,
            ),
            const SizedBox(height: 10),

            // Commune Dropdown (only show if a city is selected)
            if (_selectedCity != null)
              DropdownButtonFormField<Commune>(
                value: _selectedCommune,
                decoration: const InputDecoration(
                  labelText: 'Select Commune',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                hint: const Text('Choose a Commune'),
                items: _availableCommunes.map((commune) {
                  return DropdownMenuItem<Commune>(
                    value: commune,
                    child: Text(commune.name),
                  );
                }).toList(),
                onChanged: _onCommuneChanged,
              ),
            const SizedBox(height: 10),

            // Event Space Selection with Pagination
            const Text(
              'Select Event Space',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Event Space List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _eventSpaces.length + 1,
                        itemBuilder: (context, index) {
                          // If we've reached the end and there's more data
                          if (index == _eventSpaces.length) {
                            return _hasMoreData
                                ? TextButton(
                                    onPressed: _loadMoreEventSpaces,
                                    child: const Text('Load More'),
                                  )
                                : const SizedBox.shrink();
                          }

                          final eventSpace = _eventSpaces[index];
                          return RadioListTile<EventSpace>(
                            title: Text(
                              '${eventSpace.name} - ${eventSpace.commune.name}, ${eventSpace.city.name}',
                            ),
                            subtitle: Text('Price: ${eventSpace.price}'),
                            value: eventSpace,
                            groupValue: _selectedEventSpace,
                            onChanged: (EventSpace? newValue) {
                              setState(() {
                                _selectedEventSpace = newValue;
                                _selectedEventSpaceId = newValue?.id;
                              });
                            },
                          );
                        },
                      ),
                      // No event spaces message
                      if (_eventSpaces.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No event spaces found. Try changing your filters.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),

            // Tag Selection
            const SizedBox(height: 10),
            const Text(
              'Select Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              spacing: 8.0,
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
            // Promotional Price Section
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Promotional Pricing'),
              value: _isPromotional,
              onChanged: (bool value) {
                setState(() {
                  _isPromotional = value;
                  if (!value) {
                    // Reset promotional price fields
                    _promotionalPrice = null;
                    _promotionalStartDate = null;
                    _promotionalEndDate = null;
                  }
                });
              },
            ),

            if (_isPromotional) ...[
              // Promotional Price Input
              TextFormField(
                initialValue: _promotionalPrice?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Promotional Price',
                  hintText: 'Enter promotional price',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_isPromotional) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a promotional price';
                    }
                    // Vérifiez que le prix est un nombre valide
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Please enter a valid price';
                    }
                    // Vérifiez que le prix promotionnel est inférieur au prix original
                    if (_selectedEventSpace != null &&
                        price >= _selectedEventSpace!.price) {
                      return 'Promotional price must be lower than original price';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  // Mise à jour immédiate du prix promotionnel lors de la saisie
                  setState(() {
                    _promotionalPrice = double.tryParse(value);
                  });
                },
              ),

              // Promotional Date Pickers
              ListTile(
                title: Text(
                    'Promotional Start Date: ${_promotionalStartDate != null ? DateFormat('dd/MM/yyyy').format(_promotionalStartDate!) : 'Select start date'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              ListTile(
                title: Text(
                    'Promotional End Date: ${_promotionalEndDate != null ? DateFormat('dd/MM/yyyy').format(_promotionalEndDate!) : 'Select end date'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ],

            // Validity Date for Limited Offers
            if (_tags.contains(BlogTag.offreLimitee)) ...[
              ListTile(
                title: Text(
                    'Validity Date: ${_validUntil != null ? DateFormat('dd/MM/yyyy').format(_validUntil!) : 'Select validity date'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, isValidUntil: true),
                ),
              ),
            ],

            // Save Button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedEventSpace != null ? _savePost : null,
              child: Text(
                widget.post == null ? 'Create Post' : 'Update Post',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
