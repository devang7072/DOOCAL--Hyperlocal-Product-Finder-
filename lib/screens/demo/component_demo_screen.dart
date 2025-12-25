import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class ComponentDemoScreen extends StatefulWidget {
  const ComponentDemoScreen({super.key});

  @override
  State<ComponentDemoScreen> createState() => _ComponentDemoScreenState();
}

class _ComponentDemoScreenState extends State<ComponentDemoScreen> {
  bool _isLoading = false;
  String _selectedCategory = 'Food';

  void _showSuccess() {
    SuccessAnimation.show(context, message: 'Process Completed Successfully!');
  }

  void _showBottomSheet() {
    CustomBottomSheet.show(
      context: context,
      title: 'Quick Actions',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Choose an action to proceed with your request.'),
            const SizedBox(height: 24),
            CustomButton(text: 'Primary Action', onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Secondary Action', 
              variant: ButtonVariant.secondary,
              onPressed: () => Navigator.pop(context)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Processing...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Component Library Demo')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Buttons'),
              _buildPadding(
                Column(
                  children: [
                    CustomButton(text: 'Primary Button', onPressed: () {}),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Secondary Button', 
                      variant: ButtonVariant.secondary, 
                      onPressed: () {}
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Outline Button', 
                      variant: ButtonVariant.outline, 
                      onPressed: () {}
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Danger Button', 
                      variant: ButtonVariant.danger, 
                      onPressed: () {},
                      icon: Icons.delete_outline,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Loading Demo', 
                      isLoading: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('Stat Cards'),
              _buildPadding(
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Orders',
                        value: '128',
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Revenue',
                        value: '\$4.2k',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('Search & Chips'),
              _buildPadding(
                Column(
                  children: [
                    SearchBarWidget(onChanged: (v) {}),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Food', 'Tech', 'Service', 'Home'].map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: cat,
                              icon: Icons.category,
                              isSelected: _selectedCategory == cat,
                              onTap: () => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('States & Feedback'),
              _buildPadding(
                Column(
                  children: [
                    CustomButton(
                      text: 'Show Success Animation', 
                      onPressed: _showSuccess,
                      variant: ButtonVariant.success,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Show Bottom Sheet', 
                      onPressed: _showBottomSheet,
                      variant: ButtonVariant.secondary,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                       text: 'Toggle Full Screen Loading',
                       onPressed: () {
                         setState(() => _isLoading = true);
                         Future.delayed(const Duration(seconds: 2), () {
                           if (mounted) setState(() => _isLoading = false);
                         });
                       },
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('Shimmers (Loading)'),
              const ShimmerListCard(),
              const SizedBox(height: 8),
              const ShimmerListCard(),

              _buildSectionTitle('Empty State'),
              EmptyState(
                icon: Icons.search_off,
                title: 'No Results Found',
                message: 'Try adjusting your filters or search terms.',
                actionText: 'Clear Filters',
                onAction: () {},
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}
