import 'package:event_app/presentation/screens/dashboard/commune/add_commune_screen.dart';
import 'package:event_app/presentation/screens/dashboard/commune/commune_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DistrictsStyles {
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
}

class DistrictsManagementScreen extends StatefulWidget {
  const DistrictsManagementScreen({super.key});

  @override
  State<DistrictsManagementScreen> createState() =>
      _DistrictsManagementScreenState();
}

class _DistrictsManagementScreenState extends State<DistrictsManagementScreen> {
  final ScrollController _scrollController = ScrollController();
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
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > DistrictsStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= DistrictsStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: DistrictsStyles.circularButtonSize,
      height: DistrictsStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(
          horizontal: DistrictsStyles.circularButtonMargin),
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

  Widget _buildMenuItem({
    required Icon icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black,
          ),
        ),
        trailing:
            showArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(DistrictsStyles.appBarTotalHeight),
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
          toolbarHeight: DistrictsStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: DistrictsStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: DistrictsStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: DistrictsStyles.horizontalPadding),
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
                        height: DistrictsStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: DistrictsStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: DistrictsStyles.horizontalPadding),
                      padding: DistrictsStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(DistrictsStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Gestion des Communes',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            top: DistrictsStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Gestion des Communes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuItem(
                icon: Icon(CupertinoIcons.plus_circle_fill,
                    color: Colors.green[400]),
                title: 'Ajouter une commune',
                onTap: () {
                  // Navigation vers la page d'ajout de commune
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddCommuneScreen(), // Remplacez AddCommuneScreen par le nom correct de votre page d'ajout
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icon(CupertinoIcons.list_bullet, color: Colors.blue[400]),
                title: 'Toutes les communes',
                onTap: () {
                  // Navigation vers la page de liste des communes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CommuneListScreen(), // Remplacez AllCommunesScreen par votre page de liste des communes
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
