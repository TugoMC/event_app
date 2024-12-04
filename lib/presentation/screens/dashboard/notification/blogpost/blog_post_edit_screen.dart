import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  BlogPromotionalPrice? _promotionalPrice;

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
      _promotionalPrice = widget.post!.promotionalPrice;
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
      Query query = _firestore.collection('eventSpaces');

      // Apply city filter
      if (_selectedCity != null) {
        query = query.where('city.id', isEqualTo: _selectedCity!.id);
      }

      // Apply commune filter
      if (_selectedCommune != null) {
        query = query.where('commune.id', isEqualTo: _selectedCommune!.id);
      }

      // Start after the last document and limit
      query = query.startAfterDocument(_lastDocument!).limit(_pageSize);

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
        _hasMoreData = querySnapshot.docs.length == _pageSize;

        // Update the last document for next pagination
        if (querySnapshot.docs.isNotEmpty) {
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
    if (_formKey.currentState!.validate() && _selectedEventSpace != null) {
      _formKey.currentState!.save();

      try {
        final blogPost = BlogPost(
          id: widget.post?.id, // Use existing ID if editing
          title: _title,
          description: _description,
          eventSpaceId: _selectedEventSpace!.id,
          eventSpacePrice: _selectedEventSpace!.price,
          createdAt: widget.post?.createdAt ?? DateTime.now(),
          tags: _tags,
          promotionalPrice: _promotionalPrice,
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
            const SizedBox(height: 20),

            // Save Button
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
