import 'package:flutter/material.dart';
import '../customer_ui.dart';
import '../models/food.dart';
import '../services/api_service.dart';

/// Admin Menu Management Tab for THE NEW HOTPOT.
/// Allows the restaurant owner to view, search, filter, add, edit, delete,
/// and toggle availability of all dishes.
class AdminMenuTab extends StatefulWidget {
  final String token;
  final bool isDemoMode;

  const AdminMenuTab({super.key, required this.token, this.isDemoMode = false});

  @override
  State<AdminMenuTab> createState() => AdminMenuTabState();
}

class AdminMenuTabState extends State<AdminMenuTab> {
  List<Food> _foods = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static final List<Food> _sampleFoods = [
    const Food(
      id: 1,
      name: 'Chicken Biryani',
      category: 'Biryani',
      price: 160,
      imageUrl:
          'https://www.ruchiskitchen.com/wp-content/uploads/2020/09/Chicken-Biryani-Recipe-01-1.jpg',
      description:
          'Fragrant aged basmati, slow-cooked marinated chicken & secret whole spices.',
      available: true,
      isFeatured: true,
    ),
    const Food(
      id: 2,
      name: 'Mutton Biryani',
      category: 'Biryani',
      price: 190,
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20240328/pngtree-mutton-biryani-meal-in-a-plate-on-table-image_15645442.jpg',
      description:
          'Tender dum-cooked mutton simmered in deeply caramelized onions and saffron.',
      available: true,
    ),
    const Food(
      id: 3,
      name: 'Chicken Fried rice',
      category: 'Fried rice',
      price: 140,
      imageUrl:
          'https://thumbs.dreamstime.com/b/delicious-spicy-chicken-fried-rice-homemade-cast-iron-wok-94297571.jpg',
      description:
          'High-heat wok-tossed grains with tender chicken morsels and charred scallions.',
      available: true,
    ),
    const Food(
      id: 4,
      name: 'Chicken 65',
      category: 'Starters',
      price: 130,
      imageUrl:
          'https://thumbs.dreamstime.com/b/chicken-chinese-cuisine-s-deep-fried-course-crazy-saltiness-crunchiness-to-punchy-flavours-curry-leaves-ginger-195902298.jpg',
      description:
          'Crisp fried boneless chicken tossed with fiery bird’s eye chili & curry leaves.',
      available: true,
    ),
    const Food(
      id: 5,
      name: 'Gulab Jamun',
      category: 'Desserts',
      price: 40,
      imageUrl:
          'https://thumbs.dreamstime.com/b/indian-sweets-gulab-jamun-125773271.jpg',
      description:
          'Soft khoya dumplings steeped in warm green cardamom and rosewater syrup.',
      available: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        if (_foods.isEmpty) {
          _foods = List<Food>.from(_sampleFoods);
        }
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    try {
      final foods = await ApiService.getAdminFoods(token: widget.token);
      if (!mounted) return;
      setState(() {
        _foods = foods;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<String> get _categories {
    final set = <String>{'All'};
    for (final f in _foods) {
      if (f.category.trim().isNotEmpty) {
        set.add(f.category.trim());
      }
    }
    // Also add current standard categories if not present
    set.addAll(['Biryani', 'Fried rice', 'Starters', 'Desserts', 'Soup']);
    return set.toList();
  }

  List<Food> get _filteredFoods {
    return _foods.where((food) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          food.category.toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          food.name.toLowerCase().contains(q) ||
          food.category.toLowerCase().contains(q) ||
          food.description.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _toggleAvailability(Food food) async {
    final nextAvailable = !food.available;
    final originalFoods = List<Food>.from(_foods);

    // Optimistic UI update
    setState(() {
      final idx = _foods.indexWhere((f) => f.id == food.id);
      if (idx != -1) {
        _foods[idx] = food.copyWith(available: nextAvailable);
      }
    });

    if (widget.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Demo: ${food.name} is now ${nextAvailable ? "AVAILABLE" : "SOLD OUT"}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await ApiService.updateFood(
        token: widget.token,
        foodId: food.id,
        data: {'available': nextAvailable},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: HotpotColors.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            '${food.name} marked as ${nextAvailable ? "AVAILABLE" : "SOLD OUT"}',
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: HotpotColors.paper,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Revert optimistic update
      setState(() => _foods = originalFoods);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          content: Text('Failed to update availability: $e'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteFood(Food food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: HotpotColors.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete ${food.name}?',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w800,
              color: HotpotColors.espresso,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this dish from the menu?\n\n'
            'Historical customer orders containing this dish will NOT be affected and will remain readable.',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: HotpotColors.muted,
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: HotpotColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (widget.isDemoMode) {
      setState(() {
        _foods.removeWhere((f) => f.id == food.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Demo: ${food.name} deleted')));
      }
      return;
    }

    try {
      await ApiService.deleteFood(token: widget.token, foodId: food.id);
      if (!mounted) return;
      setState(() {
        _foods.removeWhere((f) => f.id == food.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: HotpotColors.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            '${food.name} deleted successfully',
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: HotpotColors.paper,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          content: Text('Failed to delete dish: $e'),
        ),
      );
    }
  }

  void _openFoodForm({Food? initialFood}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return _FoodFormSheet(
          token: widget.token,
          isDemoMode: widget.isDemoMode,
          initialFood: initialFood,
          existingCategories: _categories.where((c) => c != 'All').toList(),
          onSaved: (savedFood) {
            setState(() {
              final idx = _foods.indexWhere((f) => f.id == savedFood.id);
              if (idx != -1) {
                _foods[idx] = savedFood;
              } else {
                _foods.insert(0, savedFood);
              }
            });
            fetchMenu();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _filteredFoods;

    return RefreshIndicator(
      onRefresh: fetchMenu,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildCategoryChips(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Menu Dishes (${displayed.length})',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: HotpotColors.espresso,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openFoodForm(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Add Dish',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HotpotColors.terracotta,
                  foregroundColor: HotpotColors.paper,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading && _foods.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null && _foods.isEmpty)
            _buildErrorView()
          else if (displayed.isEmpty)
            _buildEmptyView()
          else
            _buildDishesList(displayed),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final total = _foods.length;
    final available = _foods.where((f) => f.available).length;
    final soldOut = total - available;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Dishes',
            count: total,
            color: HotpotColors.espresso,
            icon: Icons.restaurant_menu_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Available',
            count: available,
            color: Colors.green.shade700,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Sold Out',
            count: soldOut,
            color: Colors.red.shade700,
            icon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search dishes by name or category...',
        prefixIcon: const Icon(Icons.search_rounded, color: HotpotColors.muted),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: HotpotColors.terracotta,
              backgroundColor: HotpotColors.cardTone,
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? HotpotColors.paper : HotpotColors.espresso,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDishesList(List<Food> dishes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: dishes.map((dish) {
              return SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: _buildDishAdminCard(dish),
              );
            }).toList(),
          );
        }

        return Column(children: dishes.map(_buildDishAdminCard).toList());
      },
    );
  }

  Widget _buildDishAdminCard(Food dish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: HotpotColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: dish.available ? HotpotColors.softBorder : Colors.red.shade200,
          width: dish.available ? 1 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: HotpotNetworkImage(
                  imageUrl: dish.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: HotpotColors.espresso,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: HotpotColors.cardTone,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dish.category,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: HotpotColors.terracotta,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish.description.isNotEmpty
                        ? dish.description
                        : 'No description provided.',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: HotpotColors.muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${dish.price}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: HotpotColors.espresso,
                        ),
                      ),
                      // Availability switch
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dish.available ? 'AVAILABLE' : 'SOLD OUT',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: dish.available
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: dish.available,
                              activeThumbColor: Colors.green.shade600,
                              onChanged: (_) => _toggleAvailability(dish),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: HotpotColors.softBorder),
                  // Edit & Delete actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openFoodForm(initialFood: dish),
                        icon: const Icon(Icons.edit_rounded, size: 14),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HotpotColors.espresso,
                          side: const BorderSide(
                            color: HotpotColors.softBorder,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDeleteFood(dish),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                        ),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade200),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load menu items.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchMenu,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HotpotColors.terracotta,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: HotpotColors.cardTone,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: HotpotColors.terracotta,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No menu items found',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: HotpotColors.espresso,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? "No dishes matching '$_searchQuery'."
                  : "No dishes in this category yet. Add your first dish!",
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: HotpotColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => _openFoodForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Dish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HotpotColors.terracotta,
                foregroundColor: HotpotColors.paper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: HotpotColors.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Polished Add / Edit Food Modal Bottom Sheet.
class _FoodFormSheet extends StatefulWidget {
  final String token;
  final bool isDemoMode;
  final Food? initialFood;
  final List<String> existingCategories;
  final ValueChanged<Food> onSaved;

  const _FoodFormSheet({
    required this.token,
    required this.isDemoMode,
    this.initialFood,
    required this.existingCategories,
    required this.onSaved,
  });

  @override
  State<_FoodFormSheet> createState() => _FoodFormSheetState();
}

class _FoodFormSheetState extends State<_FoodFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late bool _available;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFood;
    _nameController = TextEditingController(text: f?.name ?? '');
    _categoryController = TextEditingController(text: f?.category ?? 'Biryani');
    _priceController = TextEditingController(
      text: f != null ? '${f.price}' : '',
    );
    _descriptionController = TextEditingController(text: f?.description ?? '');
    _imageUrlController = TextEditingController(text: f?.imageUrl ?? '');
    _available = f?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (widget.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final saved = Food(
        id: widget.initialFood?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: name,
        category: category,
        price: price,
        description: description,
        imageUrl: imageUrl,
        available: _available,
      );
      if (!mounted) return;
      widget.onSaved(saved);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Demo: ${widget.initialFood == null ? "Added" : "Updated"} $name',
          ),
        ),
      );
      return;
    }

    try {
      final payload = {
        'name': name,
        'category': category,
        'price': price.toDouble(),
        'description': description,
        'image_url': imageUrl,
        'available': _available,
      };

      final Food result;
      if (widget.initialFood == null) {
        result = await ApiService.createFood(
          token: widget.token,
          data: payload,
        );
      } else {
        result = await ApiService.updateFood(
          token: widget.token,
          foodId: widget.initialFood!.id,
          data: payload,
        );
      }

      if (!mounted) return;
      widget.onSaved(result);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: HotpotColors.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            widget.initialFood == null
                ? '$name added to menu successfully!'
                : '$name updated successfully!',
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: HotpotColors.paper,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialFood != null;

    return Container(
      decoration: const BoxDecoration(
        color: HotpotColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HotpotColors.softBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Dish' : 'Add New Dish',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: HotpotColors.espresso,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Colors.red.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Dish Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dish Name *',
                  hintText: 'e.g., Mutton Chukka',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Dish name cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Category
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        hintText: 'Biryani, Starters, Desserts...',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Category cannot be empty.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'Choose existing category',
                    icon: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: HotpotColors.cardTone,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: HotpotColors.espresso,
                      ),
                    ),
                    onSelected: (cat) {
                      setState(() => _categoryController.text = cat);
                    },
                    itemBuilder: (ctx) {
                      return widget.existingCategories.map((c) {
                        return PopupMenuItem(value: c, child: Text(c));
                      }).toList();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (₹) *',
                  hintText: 'e.g., 180',
                  prefixText: '₹ ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Price cannot be empty.';
                  }
                  final p = int.tryParse(val.trim());
                  if (p == null || p <= 0) {
                    return 'Please enter a valid price greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description / Chef Notes',
                  hintText: 'Ingredients, flavour profile, cooking style...',
                ),
              ),
              const SizedBox(height: 12),
              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 12),
              // Available toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Available for Ordering',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  _available
                      ? 'Customers can see and add this dish to cart.'
                      : 'Marked as SOLD OUT. Customers cannot order.',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: HotpotColors.muted,
                  ),
                ),
                value: _available,
                activeThumbColor: Colors.green.shade600,
                onChanged: (val) => setState(() => _available = val),
              ),
              const SizedBox(height: 20),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HotpotColors.terracotta,
                    foregroundColor: HotpotColors.paper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Add Dish to Menu',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
