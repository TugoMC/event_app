import 'package:event_app/presentation/screens/profile/event_space_add/user_add_event_space_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EventSpaceManagementStyles {
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

class EventSpaceManagementScreen extends StatefulWidget {
  const EventSpaceManagementScreen({super.key});

  @override
  State<EventSpaceManagementScreen> createState() =>
      _EventSpaceManagementScreenState();
}

class _EventSpaceManagementScreenState
    extends State<EventSpaceManagementScreen> {
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
    if (_scrollController.offset > EventSpaceManagementStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <=
            EventSpaceManagementStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: EventSpaceManagementStyles.circularButtonSize,
      height: EventSpaceManagementStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(
          horizontal: EventSpaceManagementStyles.circularButtonMargin),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(EventSpaceManagementStyles.appBarTotalHeight),
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
          toolbarHeight: EventSpaceManagementStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: EventSpaceManagementStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: EventSpaceManagementStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                EventSpaceManagementStyles.horizontalPadding),
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
                        height: EventSpaceManagementStyles
                            .spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: EventSpaceManagementStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              EventSpaceManagementStyles.horizontalPadding),
                      padding: EventSpaceManagementStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            EventSpaceManagementStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Gestion des Espaces',
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

  Widget _buildMenuItem({
    required Icon icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
    Color? textColor,
    bool useGradient = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: useGradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFC3B9FB), Color(0xFF9747FF)],
              )
            : null,
        color: useGradient ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: useGradient ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                useGradient ? Colors.white.withOpacity(0.2) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon.icon,
            color: useGradient ? Colors.white : icon.color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: useGradient ? Colors.white : (textColor ?? Colors.black),
          ),
        ),
        trailing: showArrow
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: useGradient ? Colors.white : Colors.black,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            top: EventSpaceManagementStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildMenuItem(
                icon: const Icon(Icons.add_business_rounded,
                    color: Color(0xFF9747FF)),
                title: 'Créer un nouvel espace',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEventSpaceScreen(),
                    ),
                  );
                },
                useGradient: true,
              ),
              _buildMenuItem(
                icon: Icon(CupertinoIcons.doc_text, color: Colors.blue[400]),
                title: 'Mes demandes en cours',
                onTap: () {
                  // TODO: Navigate to pending requests screen
                },
              ),
              _buildMenuItem(
                icon: Icon(CupertinoIcons.time, color: Colors.orange[400]),
                title: 'Historique des demandes',
                onTap: () {
                  // TODO: Navigate to requests history screen
                },
              ),
              _buildMenuItem(
                icon: Icon(Icons.business, color: Colors.green[400]),
                title: 'Mes espaces approuvés',
                onTap: () {
                  // TODO: Navigate to approved spaces screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
