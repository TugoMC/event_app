import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _AppBarStyles {
  static const double appBarTotalHeight = 52.0 + kToolbarHeight + 44.0;
  static const double buttonRowHeight = 52.0;
  static const double bannerHeight = 44.0;
  static const double circularButtonSize = 46.0;
  static const double circularButtonMargin = 5.0;
  static const double horizontalPadding = 24.0;
  static const double titleContainerHeight = 46.0;
  static const EdgeInsets titlePadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const double spaceBetweenButtonAndTitle = 8.0;
  static const double borderRadius = 20.0;
}

class EventSpaceDetailScreen extends StatefulWidget {
  final EventSpace eventSpace;

  const EventSpaceDetailScreen({super.key, required this.eventSpace});

  @override
  State<EventSpaceDetailScreen> createState() => _EventSpaceDetailScreenState();
}

class _EventSpaceDetailScreenState extends State<EventSpaceDetailScreen> {
  int _currentPage = 0;

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5, top: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF8773F8)
            : const Color(0xFFC3B9FB),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: _AppBarStyles.circularButtonSize,
      height: _AppBarStyles.circularButtonSize,
      margin:
          EdgeInsets.symmetric(horizontal: _AppBarStyles.circularButtonMargin),
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

  PreferredSizeWidget _buildAppBar(BuildContext context,
      {required bool showBanner}) {
    final appBarHeight = showBanner
        ? _AppBarStyles.appBarTotalHeight
        : _AppBarStyles.appBarTotalHeight - _AppBarStyles.bannerHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: appBarHeight,
        automaticallyImplyLeading: false,
        flexibleSpace: Column(
          children: [
            if (showBanner)
              Container(
                width: double.infinity,
                height: _AppBarStyles.bannerHeight,
              ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: _AppBarStyles.buttonRowHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: _AppBarStyles.horizontalPadding),
                      child: Row(
                        children: [
                          _buildCircularButton(
                            icon: const Icon(
                              CupertinoIcons.back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          _buildCircularButton(
                            icon: const Icon(
                              CupertinoIcons.bubble_right,
                              color: Colors.black,
                            ),
                            onPressed: () => _showReviewModal(context),
                          ),
                          _buildCircularButton(
                            icon: const Icon(
                              CupertinoIcons.heart,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              // Action favori
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: _AppBarStyles.spaceBetweenButtonAndTitle),
                  Container(
                    width: double.infinity,
                    height: _AppBarStyles.titleContainerHeight,
                    margin: EdgeInsets.symmetric(
                        horizontal: _AppBarStyles.horizontalPadding),
                    padding: _AppBarStyles.titlePadding,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(_AppBarStyles.borderRadius),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      widget.eventSpace.name,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, showBanner: true),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Add fixed padding after AppBar
              const SliverPadding(
                padding: EdgeInsets.only(top: 20),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: Center(
                        child: CarouselSlider(
                          // Replace the empty Stack here
                          options: CarouselOptions(
                            height: 250,
                            viewportFraction: 1.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                          ),
                          items: widget.eventSpace.photoUrls.map((url) {
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Add dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          widget.eventSpace.photoUrls.length,
                          (index) => _buildDot(index)),
                    ),

                    // Rest of the content with padding
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        top: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating, Hours and Price row
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star,
                                color: Color(0xFF8773F8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.eventSpace
                                    .getAverageRating()
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                CupertinoIcons.clock,
                                size: 16,
                                color: Color(0xFF8773F8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.eventSpace.hours,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8773F8).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.eventSpace.price.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8773F8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            widget.eventSpace.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              height: 1.4,
                            ),
                          ),

                          // Phone section
                          const SizedBox(height: 24),
                          const Text(
                            'Téléphone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.phone, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                widget.eventSpace.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Activities section
                          const SizedBox(height: 24),
                          const Text(
                            'Activités',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                widget.eventSpace.activities.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF8773F8)
                                          .withOpacity(0.2),
                                      child: Icon(activity.icon,
                                          color: const Color(0xFF8773F8)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      activity.type,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Les Avis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Ajoutez ce code après le texte "Les Avis"
                          widget.eventSpace.reviews.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'Aucun avis pour le moment',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : // Remplacez le bloc existant par :
                              StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('reviews')
                                      .where('eventSpaceId',
                                          isEqualTo: widget.eventSpace.id)
                                      .orderBy('createdAt', descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF8773F8),
                                          ),
                                        ),
                                      );
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'Aucun avis pour le moment',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        final reviewData =
                                            snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.star_fill,
                                                      color: const Color(
                                                          0xFF8773F8),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      (reviewData['rating'] ??
                                                              0)
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      _formatDate(reviewData[
                                                          'createdAt']),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  reviewData['comment'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                if (reviewData['isVerified'] ??
                                                    false)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .checkmark_seal_fill,
                                                          color:
                                                              Colors.green[600],
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'Avis vérifié',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .green[600],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fixed bottom buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 245,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8773F8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'APPELER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8773F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: // Update the location IconButton
                          IconButton(
                        onPressed: () async {
                          final Uri locationUri =
                              Uri.parse(widget.eventSpace.location);
                          if (await canLaunchUrl(locationUri)) {
                            await launchUrl(locationUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Impossible d\'ouvrir la localisation')),
                            );
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.location_solid,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewModal(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    int selectedRating = 3; // Default to 3 stars

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Donnez votre avis',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < selectedRating
                                ? CupertinoIcons.star_fill
                                : CupertinoIcons.star,
                            color: const Color(0xFF8773F8),
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Commentaire',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Partagez votre expérience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logique de soumission de l'avis
                          _submitReview(context, selectedRating,
                              commentController.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8773F8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Soumettre mon avis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submitReview(BuildContext context, int rating, String comment) async {
    // Validation de base
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un commentaire')),
      );
      return;
    }

    try {
      // Récupérer l'utilisateur actuellement connecté
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vous devez être connecté pour laisser un avis')),
        );
        return;
      }

      // Vérifier si l'utilisateur a déjà laissé un avis pour cet espace
      final existingReviewQuery = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: currentUser.uid)
          .where('eventSpaceId', isEqualTo: widget.eventSpace.id)
          .get();

      if (existingReviewQuery.docs.isNotEmpty) {
        // L'utilisateur a déjà laissé un avis, proposer une mise à jour
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Avis existant'),
            content:
                const Text('Voulez-vous mettre à jour votre avis précédent ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateExistingReview(
                      existingReviewQuery.docs.first.id, rating, comment);
                },
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
        );
        return;
      }

      // Créer la nouvelle review
      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': currentUser.uid,
        'eventSpaceId': widget.eventSpace.id,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      });

      // Fermer le modal
      if (context.mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre avis a été soumis')),
        );
      }
    } catch (e) {
      // Gérer les erreurs potentielles
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la soumission : ${e.toString()}')),
        );
      }
    }
  }

// Nouvelle méthode pour mettre à jour un avis existant
  void _updateExistingReview(
      String reviewId, int rating, String comment) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre avis a été mis à jour')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour : ${e.toString()}')),
      );
    }
  }
}
