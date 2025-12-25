// lib/widgets/bottom_sheets/request_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';

class RequestBottomSheet extends StatefulWidget {
  final Function(String category, String description) onSubmit;

  const RequestBottomSheet({super.key, required this.onSubmit});

  @override
  State<RequestBottomSheet> createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends State<RequestBottomSheet> {
  String? selectedCategory;
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you need?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Broadcast your request to nearby vendors instantly.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = AppConstants.categories[index];
                final isSelected = selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (val) => setState(() => selectedCategory = val ? category : null),
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Describe your requirement',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'E.g. I need a plumber to fix a leaking tap in the kitchen. Urgent!',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (selectedCategory != null && descriptionController.text.isNotEmpty) {
                widget.onSubmit(selectedCategory!, descriptionController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Broadcast Request'),
          ),
        ],
      ),
    );
  }
}
