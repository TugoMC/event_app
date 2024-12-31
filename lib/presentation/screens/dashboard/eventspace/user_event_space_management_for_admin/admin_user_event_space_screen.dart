import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdminEventSpaceManagementStyles {
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

class AdminEventSpaceManagementScreen extends StatefulWidget {
  const AdminEventSpaceManagementScreen({super.key});

  @override
  State<AdminEventSpaceManagementScreen> createState() =>
      _AdminEventSpaceManagementScreenState();
}

class _AdminEventSpaceManagementScreenState
    extends State<AdminEventSpaceManagementScreen> {
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
    if (_scrollController.offset >
            AdminEventSpaceManagementStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <=
            AdminEventSpaceManagementStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: AdminEventSpaceManagementStyles.circularButtonSize,
      height: AdminEventSpaceManagementStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(
          horizontal: AdminEventSpaceManagementStyles.circularButtonMargin),
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
          Size.fromHeight(AdminEventSpaceManagementStyles.appBarTotalHeight),
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
          toolbarHeight: AdminEventSpaceManagementStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: AdminEventSpaceManagementStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: AdminEventSpaceManagementStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AdminEventSpaceManagementStyles
                                .horizontalPadding),
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
                        height: AdminEventSpaceManagementStyles
                            .spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height:
                          AdminEventSpaceManagementStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: AdminEventSpaceManagementStyles
                              .horizontalPadding),
                      padding: AdminEventSpaceManagementStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                            AdminEventSpaceManagementStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Gestion des demandes',
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
    String? subtitle,
    Widget? trailing,
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
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: useGradient ? Colors.white70 : Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ??
            (showArrow
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: useGradient ? Colors.white : Colors.black,
                  )
                : null),
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
            top: AdminEventSpaceManagementStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildMenuItem(
                icon: const Icon(CupertinoIcons.clock_fill,
                    color: Color(0xFF9747FF)),
                title: 'Demandes en attente',
                subtitle: '3 nouvelles demandes',
                onTap: () {
                  // TODO: Navigate to pending requests management screen
                },
                useGradient: true,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildMenuItem(
                icon: Icon(Icons.verified_rounded, color: Colors.green[400]),
                title: 'Espaces approuvés',
                subtitle: 'Gérer les espaces actifs',
                onTap: () {
                  // TODO: Navigate to approved spaces management screen
                },
              ),
              _buildMenuItem(
                icon: Icon(Icons.block_rounded, color: Colors.red[400]),
                title: 'Espaces refusés',
                subtitle: 'Historique des refus',
                onTap: () {
                  // TODO: Navigate to rejected spaces screen
                },
              ),
              _buildMenuItem(
                icon: Icon(Icons.analytics_rounded, color: Colors.blue[400]),
                title: 'Statistiques',
                subtitle: 'Analyses et rapports',
                onTap: () {
                  // TODO: Navigate to statistics screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
