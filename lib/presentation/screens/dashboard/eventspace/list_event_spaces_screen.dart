import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/add_event_space_screen.dart';

class ListEventSpacesScreen extends StatefulWidget {
  const ListEventSpacesScreen({Key? key}) : super(key: key);

  @override
  _ListEventSpacesScreenState createState() => _ListEventSpacesScreenState();
}

class _ListEventSpacesScreenState extends State<ListEventSpacesScreen> {
  City? selectedCity;
  List<Activity> selectedActivities = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyActive = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getEventSpacesStream() {
    Query query = FirebaseFirestore.instance.collection('event_spaces');

    if (_showOnlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (selectedCity != null) {
      query = query.where('city.id', isEqualTo: selectedCity!.id);
    }

    return query.snapshots();
  }

  List<EventSpace> _filterEventSpaces(List<EventSpace> eventSpaces) {
    return eventSpaces.where((eventSpace) {
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch =
          eventSpace.name.toLowerCase().contains(searchTerm) ||
              eventSpace.description.toLowerCase().contains(searchTerm);

      final matchesActivities = selectedActivities.isEmpty ||
          selectedActivities.every((activity) =>
              eventSpace.activities.any((a) => a.id == activity.id));

      return matchesSearch && matchesActivities;
    }).toList();
  }

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField<City?>(
                    value: selectedCity,
                    decoration: InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
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
                      setState(() => selectedCity = value);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
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
                      },
                    );
                  }).toList(),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Afficher uniquement les espaces actifs'),
              value: _showOnlyActive,
              onChanged: (bool value) {
                setState(() => _showOnlyActive = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSpacesList(List<EventSpace> eventSpaces) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildEventSpaceCard(eventSpaces[index]),
        childCount: eventSpaces.length,
      ),
    );
  }

  Widget _buildEventSpaceCard(EventSpace eventSpace) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dans _buildEventSpaceCard, remplacer la condition existante pour les images par :
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
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!eventSpace.isActive)
                      const Chip(
                        label: Text('Inactif'),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${eventSpace.city.name} - ${eventSpace.commune.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  eventSpace.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Icon(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _getEventSpacesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventSpaces = snapshot.data!.docs
              .map((doc) =>
                  EventSpace.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          final filteredEventSpaces = _filterEventSpaces(eventSpaces);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Espaces Événementiels'),
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEventSpaceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              _buildFilters(),
              if (filteredEventSpaces.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Aucun espace événementiel trouvé'),
                  ),
                )
              else
                _buildEventSpacesList(filteredEventSpaces),
            ],
          );
        },
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
