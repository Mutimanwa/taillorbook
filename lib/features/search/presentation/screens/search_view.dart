import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _suggestions = [
    'Robes de soirée',
    'Collection Hiver',
    'Costumes Homme',
    'Accessoires Gold',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildSuggestions()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greySubtle),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher une collection, pièce...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        Text(
          'SUGGESTIONS',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _suggestions.map((s) => _buildSuggestionChip(s)).toList(),
        ),
        const SizedBox(height: 40),
        Text(
          'RÉCENT',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 16),
        _recentItem('Collection Été 2024'),
        _recentItem('Veste en lin premium'),
      ],
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.greySubtle),
      onPressed: () {
        _searchController.text = label;
        setState(() {});
      },
    );
  }

  Widget _recentItem(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history, size: 20),
      title: Text(title, style: AppTypography.bodyMedium),
      trailing: const Icon(Icons.north_west, size: 16),
      onTap: () {
        _searchController.text = title;
        setState(() {});
      },
    );
  }

  Widget _buildResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.7,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildResultCard(index);
      },
    );
  }

  Widget _buildResultCard(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.greySubtle,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.pexels.com/photos/6347548/pexels-photo-6347548.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Pièce Unique #${100 + index}', style: AppTypography.labelLarge),
        Text(
          'Chris Couture',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
