import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/edit_event_space_screen.dart';
import 'package:flutter/material.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/add_event_space_screen.dart';

class ListEventSpacesScreen extends StatefulWidget {
  const ListEventSpacesScreen({Key? key}) : super(key: key);

  @override
  _ListEventSpacesScreenState createState() => _ListEventSpacesScreenState();
}

class _ListEventSpacesScreenState extends State<ListEventSpacesScreen> {
  City? selectedCity;
  Commune? selectedCommune;
  List<Activity> selectedActivities = [];
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  final int _itemsPerPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  List<EventSpace> _eventSpaces = [];

  final ScrollController _scrollController = ScrollController();
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchInitialData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _eventSpaces.clear();
      _lastDocument = null;
      _hasMoreData = true;
    });
    await _fetchData();
  }

  Future<void> _fetchMoreData() async {
    if (!_hasMoreData) return;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (!_hasMoreData) return;

    Query query = FirebaseFirestore.instance
        .collection('event_spaces')
        .orderBy('name')
        .limit(_itemsPerPage);

    // Apply filters
    if (selectedCity != null) {
      query = query.where('city.id', isEqualTo: selectedCity!.id);
    }

    if (selectedCommune != null) {
      query = query.where('commune.id', isEqualTo: selectedCommune!.id);
    }

    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      query = query.where('searchKeywords', arrayContains: searchTerm);
    }

    // If we have a last document, start after it
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      final querySnapshot = await query.get();

      if (querySnapshot.docs.length < _itemsPerPage) {
        setState(() {
          _hasMoreData = false;
        });
      }

      final newEventSpaces = querySnapshot.docs
          .map((doc) => EventSpace.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _eventSpaces.addAll(newEventSpaces);
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
      });
    } catch (e) {
      print('Error fetching event spaces: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  Widget _buildFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isFilterVisible ? null : 0,
      child: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher des espaces événementiels',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => _fetchInitialData(),
              ),
              const SizedBox(height: 16),
              // City Dropdown
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('cities').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cities = snapshot.data!.docs
                      .map((doc) =>
                          City.fromJson(doc.data() as Map<String, dynamic>))
                      .toList();

                  return DropdownButtonFormField<City?>(
                    value: selectedCity,
                    decoration: InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<City?>(
                        value: null,
                        child: Text('Toutes les villes'),
                      ),
                      ...cities.map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city.name),
                          )),
                    ],
                    onChanged: (City? value) {
                      setState(() {
                        selectedCity = value;
                        selectedCommune =
                            null; // Reset commune when city changes
                      });
                      _fetchInitialData();
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Commune Dropdown (conditional on selected city)
              if (selectedCity != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('communes')
                      .where('cityId', isEqualTo: selectedCity!.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final communes = snapshot.data!.docs
                        .map((doc) => Commune.fromJson(
                            doc.data() as Map<String, dynamic>))
                        .toList();

                    return DropdownButtonFormField<Commune?>(
                      value: selectedCommune,
                      decoration: InputDecoration(
                        labelText: 'Commune',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<Commune?>(
                          value: null,
                          child: Text('Toutes les communes'),
                        ),
                        ...communes.map((commune) => DropdownMenuItem(
                              value: commune,
                              child: Text(commune.name),
                            )),
                      ],
                      onChanged: (Commune? value) {
                        setState(() => selectedCommune = value);
                        _fetchInitialData();
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              // Activities Filters
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final activities = snapshot.data!.docs
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
                          _fetchInitialData();
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSpacesList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _eventSpaces.length + 1, // +1 for loading indicator
      itemBuilder: (context, index) {
        if (index == _eventSpaces.length) {
          return _hasMoreData
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

        final eventSpace = _eventSpaces[index];
        return _buildEventSpaceCard(eventSpace);
      },
    );
  }

  Widget _buildEventSpaceCard(EventSpace eventSpace) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditEventSpaceScreen(eventSpace: eventSpace),
            ),
          ).then((_) => _fetchInitialData());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eventSpace.photoUrls.isNotEmpty)
              EventSpaceImageCarousel(
                photoUrls: eventSpace.photoUrls,
                height: 200,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          eventSpace.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditEventSpaceScreen(eventSpace: eventSpace),
                            ),
                          ).then((_) => _fetchInitialData());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${eventSpace.city.name} - ${eventSpace.commune.name}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventSpace.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: eventSpace.activities.map((activity) {
                      return Chip(
                        label: Text(activity.type),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${eventSpace.price.toStringAsFixed(2)} FCFA',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          Text(
                            ' ${eventSpace.getAverageRating().toStringAsFixed(1)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Espaces Événementiels',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _toggleFilterVisibility,
            tooltip: 'Filtres',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEventSpaceScreen(),
                ),
              ).then((_) => _fetchInitialData());
            },
            tooltip: 'Ajouter un espace',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _eventSpaces.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun espace événementiel trouvé',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildEventSpacesList(),
            ),
          ],
        ),
      ),
    );
  }
}

class EventSpaceImageCarousel extends StatefulWidget {
  final List<String> photoUrls;
  final double height;

  const EventSpaceImageCarousel({
    Key? key,
    required this.photoUrls,
    this.height = 200,
  }) : super(key: key);

  @override
  State<EventSpaceImageCarousel> createState() =>
      _EventSpaceImageCarouselState();
}

class _EventSpaceImageCarouselState extends State<EventSpaceImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.photoUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.photoUrls[index],
                height: widget.height,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: widget.height,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              );
            },
          ),
        ),
        if (widget.photoUrls.length > 1) ...[
          // Navigation buttons
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  onPressed: _currentPage < widget.photoUrls.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
          // Indicators
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.photoUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
