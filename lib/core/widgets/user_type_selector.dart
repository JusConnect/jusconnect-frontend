import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

enum UserType { client, lawyer }

class UserTypeSelector extends StatefulWidget {
  final UserType selectedType;
  final ValueChanged<UserType> onChanged;

  const UserTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  State<UserTypeSelector> createState() => _UserTypeSelectorState();
}

class _UserTypeSelectorState extends State<UserTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildTypeOption(
              type: UserType.client,
              icon: Icons.person,
              label: 'Cliente',
            ),
            const SizedBox(width: 16),
            _buildTypeOption(
              type: UserType.lawyer,
              icon: Icons.gavel,
              label: 'Advogado',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required UserType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? Colors.white : AppColors.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
