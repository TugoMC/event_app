// CustomAppBar avec paramètre d'élévation
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String communeName;
  final VoidCallback onBackPressed;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.communeName,
    required this.onBackPressed,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(52 + kToolbarHeight + 44); // +44 pour la bannière

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(CupertinoIcons.search),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 46,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 5),
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: elevation,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      flexibleSpace: Column(
        children: [
          // La bannière d'avertissement en haut
          Container(
            width: double.infinity,
            height: 44,
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildCircularButton(
                          icon: const Icon(
                            CupertinoIcons.back,
                            color: Colors.black,
                          ),
                          onPressed: onBackPressed,
                        ),
                        const Spacer(),
                        const SizedBox(width: 10),
                        _buildCircularButton(
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedPreferenceHorizontal,
                            color: Colors.black,
                            size: 24.0,
                          ),
                          onPressed: () {
                            // Add filter functionality here
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 46,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    communeName,
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
    );
  }
}
