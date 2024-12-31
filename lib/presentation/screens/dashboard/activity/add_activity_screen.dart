import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/event_icons.dart';

class ActivityStyles {
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
}

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _typeController = TextEditingController();
  IconData _selectedIcon = EventIcons.eventIcons[0]['icon'] as IconData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(ActivityStyles.appBarTotalHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: ActivityStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: ActivityStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: ActivityStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ActivityStyles.horizontalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            _buildCircularButton(
                              icon: const Icon(Icons.save, color: Colors.black),
                              onPressed: _saveActivity,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ActivityStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: ActivityStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: ActivityStyles.horizontalPadding),
                      padding: ActivityStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(ActivityStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Nouvelle activité',
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
      width: ActivityStyles.circularButtonSize,
      height: ActivityStyles.circularButtonSize,
      margin:
          EdgeInsets.symmetric(horizontal: ActivityStyles.circularButtonMargin),
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

  Widget _buildDetailCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  void _saveActivity() async {
    if (_typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le type d\'activité'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final docRef = _firestore.collection('activities').doc();
      final activity = Activity(
        id: docRef.id,
        type: _typeController.text.trim(),
        icon: _selectedIcon,
      );

      await docRef.set(activity.toJson());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activité ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: ActivityStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard(
                'Type d\'activité',
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez le type d\'activité',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              _buildDetailCard(
                'Icône de l\'activité',
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: EventIcons.eventIcons.length,
                  itemBuilder: (context, index) {
                    final iconData = EventIcons.eventIcons[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconData['icon'] as IconData;
                          if (_typeController.text.isEmpty) {
                            _typeController.text = iconData['name'] as String;
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == iconData['icon']
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: _selectedIcon == iconData['icon']
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                            width: _selectedIcon == iconData['icon'] ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconData['icon'] as IconData,
                              color: _selectedIcon == iconData['icon']
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              iconData['name'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: _selectedIcon == iconData['icon']
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
