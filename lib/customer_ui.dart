import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'models/food.dart';
import 'services/api_service.dart';

/// Color palette strictly adhering to the warm restaurant design system.
class HotpotColors {
  static const espresso = Color(0xFF1A1310);
  static const cream = Color(0xFFF7F1E8);
  static const paper = Color(0xFFFFFAF3);
  static const terracotta = Color(0xFFB7472A);
  static const amber = Color(0xFFE8A83C);
  static const muted = Color(0xFF6B5A50);
  static const cardTone = Color(0xFFF1E6DA);
  static const featuredTone = Color(0xFFEBD8C4);
  static const softBorder = Color(0xFFE4D5C6);
  static const successGreen = Color(0xFF2E7D32);
}

/// Dish data model for THE NEW HOTPOT.
class Dish {
  final int id;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final String note;
  final bool isFeatured;
  final bool available;

  const Dish({
    this.id = 0,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.note,
    this.isFeatured = false,
    this.available = true,
  });

  factory Dish.fromFood(Food food) {
    return Dish(
      id: food.id,
      name: food.name,
      category: food.category,
      price: food.price,
      imageUrl: food.imageUrl,
      note: food.description,
      isFeatured: food.isFeatured,
      available: food.available,
    );
  }

  Food toFood() {
    return Food(
      id: id,
      name: name,
      category: category,
      price: price,
      imageUrl: imageUrl,
      description: note,
      isFeatured: isFeatured,
      available: available,
    );
  }
}

/// The official curated menu items for THE NEW HOTPOT.
const List<Dish> kDishes = [
  Dish(
    name: 'Chicken Biryani',
    category: 'Biryani',
    price: 160,
    imageUrl:
        'https://www.ruchiskitchen.com/wp-content/uploads/2020/09/Chicken-Biryani-Recipe-01-1.jpg',
    note:
        'Fragrant aged basmati, slow-cooked marinated chicken & secret whole spices.',
    isFeatured: true,
  ),
  Dish(
    name: 'Mutton Biryani',
    category: 'Biryani',
    price: 190,
    imageUrl:
        'https://png.pngtree.com/thumb_back/fh260/background/20240328/pngtree-mutton-biryani-meal-in-a-plate-on-table-image_15645442.jpg',
    note:
        'Tender dum-cooked mutton simmered in deeply caramelized onions and saffron.',
  ),
  Dish(
    name: 'Chicken Fried Rice',
    category: 'Fried rice',
    price: 140,
    imageUrl:
        'https://thumbs.dreamstime.com/b/delicious-spicy-chicken-fried-rice-homemade-cast-iron-wok-94297571.jpg',
    note:
        'High-heat wok-tossed grains with tender chicken morsels and charred scallions.',
  ),
  Dish(
    name: 'Chicken 65',
    category: 'Starters',
    price: 130,
    imageUrl:
        'https://thumbs.dreamstime.com/b/chicken-chinese-cuisine-s-deep-fried-course-crazy-saltiness-crunchiness-to-punchy-flavours-curry-leaves-ginger-195902298.jpg',
    note:
        'Crisp fried boneless chicken tossed with fiery bird’s eye chili & curry leaves.',
  ),
  Dish(
    name: 'Gulab Jamun',
    category: 'Desserts',
    price: 40,
    imageUrl:
        'https://thumbs.dreamstime.com/b/indian-sweets-gulab-jamun-125773271.jpg',
    note:
        'Soft khoya dumplings steeped in warm green cardamom and rosewater syrup.',
  ),
];

const List<String> kCategories = [
  'All',
  'Biryani',
  'Fried rice',
  'Starters',
  'Desserts',
];

/// Tactile button wrapper providing subtle scale-down feedback on press.
class TactilePress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const TactilePress({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<TactilePress> createState() => _TactilePressState();
}

class _TactilePressState extends State<TactilePress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _pressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _pressed = false)
          : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Elegant skeleton shimmer placeholder avoiding generic circular spinners.
class HotpotShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const HotpotShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 16,
  });

  @override
  State<HotpotShimmer> createState() => _HotpotShimmerState();
}

class _HotpotShimmerState extends State<HotpotShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFE9DCcf),
              const Color(0xFFF7EEE5),
              _controller.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Custom non-spinner loader for food ordering & backend requests.
class HotpotPulseLoader extends StatefulWidget {
  final String label;

  const HotpotPulseLoader({super.key, required this.label});

  @override
  State<HotpotPulseLoader> createState() => _HotpotPulseLoaderState();
}

class _HotpotPulseLoaderState extends State<HotpotPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final scale = 0.92 + (_anim.value * 0.16);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HotpotColors.espresso,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: HotpotColors.terracotta.withValues(
                            alpha: 0.25 * _anim.value,
                          ),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: HotpotColors.amber,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: HotpotColors.espresso,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Network image loader with shimmer skeleton and attractive fallback placeholder.
class HotpotNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const HotpotNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return HotpotShimmer(
            width: width,
            height: height,
            borderRadius: borderRadius,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: HotpotColors.cardTone,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_rounded,
                    color: HotpotColors.terracotta,
                    size: 32,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The New Hotpot',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: HotpotColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Main Application Entry Point with curated restaurant design system.
class HotpotApp extends StatelessWidget {
  final WidgetBuilder? adminBuilder;

  const HotpotApp({super.key, this.adminBuilder});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'THE NEW HOTPOT',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Outfit',
        fontFamilyFallback: const [
          'Plus Jakarta Sans',
          'Manrope',
          'sans-serif',
        ],
        scaffoldBackgroundColor: HotpotColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: HotpotColors.terracotta,
          primary: HotpotColors.terracotta,
          secondary: HotpotColors.amber,
          surface: HotpotColors.paper,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: HotpotColors.cream,
          foregroundColor: HotpotColors.espresso,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Outfit',
            color: HotpotColors.espresso,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HotpotColors.paper,
          labelStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: HotpotColors.muted,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: HotpotColors.muted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: HotpotColors.terracotta,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
      home: const CustomerHomePage(),
      routes: {
        '/track': (_) => const TrackOrderPage(),
        '/feedback': (_) => const FeedbackPage(),
        ...?((adminBuilder != null) ? {'/admin': adminBuilder!} : null),
      },
    );
  }
}

/// The Customer Home Screen with Asymmetric Hero, Bento visual balance,
/// real-time search, category filtering, and live cart indicator.
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final ValueNotifier<Map<String, int>> _cartNotifier = ValueNotifier({});
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Dish> _dishes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final foods = await ApiService.getFoods();
      if (!mounted) return;
      setState(() {
        _dishes = foods.map((f) => Dish.fromFood(f)).toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_dishes.isEmpty) {
          _dishes = kDishes;
        }
        _isLoading = false;
        _errorMessage = "Couldn't reach the kitchen.\nLet's try again.";
      });
    }
  }

  List<String> get dynamicCategories {
    final list = _dishes.isNotEmpty ? _dishes : kDishes;
    final set = <String>{'All'};
    for (final d in list) {
      if (d.category.trim().isNotEmpty) {
        set.add(d.category.trim());
      }
    }
    return set.toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartNotifier.dispose();
    super.dispose();
  }

  void _addToCart(Dish dish) {
    if (!dish.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: HotpotColors.espresso,
          content: Text(
            '${dish.name} is currently sold out and cannot be ordered.',
          ),
        ),
      );
      return;
    }

    final next = Map<String, int>.from(_cartNotifier.value);
    next[dish.name] = (next[dish.name] ?? 0) + 1;
    _cartNotifier.value = next;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: HotpotColors.espresso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: HotpotColors.amber,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${dish.name} added to your table',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  color: HotpotColors.paper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View Table',
          textColor: HotpotColors.amber,
          onPressed: () {
            final currentDishes = _dishes.isNotEmpty ? _dishes : kDishes;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartPage(
                  cartNotifier: _cartNotifier,
                  dishes: currentDishes,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceDishes = _dishes.isNotEmpty
        ? _dishes
        : (_isLoading ? <Dish>[] : kDishes);
    final filteredDishes = sourceDishes.where((dish) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          dish.category.toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          dish.name.toLowerCase().contains(q) ||
          dish.category.toLowerCase().contains(q) ||
          dish.note.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: RefreshIndicator(
              onRefresh: _fetchMenu,
              color: HotpotColors.terracotta,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 22),
                  _buildBentoHero(context),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildCategorySelector(),
                  const SizedBox(height: 28),
                  _buildMenuSection(filteredDishes),
                  const SizedBox(height: 36),
                  _buildBottomNavPrompt(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE NEW',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: HotpotColors.terracotta,
                letterSpacing: 3.5,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'HOTPOT',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: HotpotColors.espresso,
                letterSpacing: -1.2,
                height: 1.0,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TactilePress(
              onTap: () {
                Navigator.pushNamed(context, '/admin');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<Map<String, int>>(
              valueListenable: _cartNotifier,
              builder: (context, cart, _) {
                final totalCount = cart.values.fold<int>(0, (a, b) => a + b);
                return TactilePress(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(cartNotifier: _cartNotifier),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: HotpotColors.espresso,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F1A1310),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: HotpotColors.paper,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Table',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: HotpotColors.paper,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        if (totalCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: HotpotColors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$totalCount',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: HotpotColors.espresso,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoHero(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 780;
        final mainHero = Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: HotpotColors.espresso,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F1A1310),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HotpotColors.terracotta.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SLOW DUM • CAST-IRON WOK',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.amber,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Big flavour.\nZero small talk.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFBF4ED),
                  letterSpacing: -1.6,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A generous plate, a good pause, and the kind of comforting heat you remember.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFFD6C4B4),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  TactilePress(
                    onTap: () {
                      _searchController.text = 'Biryani';
                      setState(() {
                        _selectedCategory = 'Biryani';
                        _searchQuery = 'Biryani';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: HotpotColors.amber,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_rounded,
                            color: HotpotColors.espresso,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Explore Biryani',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: HotpotColors.espresso,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TactilePress(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrackOrderPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: HotpotColors.paper.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: HotpotColors.paper,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Track order',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: HotpotColors.paper,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final sideHero = Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HotpotColors.cardTone,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: HotpotColors.paper,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: HotpotColors.terracotta,
                      size: 24,
                    ),
                  ),
                  const Text(
                    'HOUSE RULE',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: HotpotColors.terracotta,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Make room for the dum.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: HotpotColors.espresso,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Freshly prepared in small batches each day. When it’s gone, it’s gone.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: HotpotColors.muted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );

        if (!isDesktop) {
          return Column(
            children: [mainHero, const SizedBox(height: 14), sideHero],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: mainHero),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: sideHero),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: HotpotColors.paper,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1310),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: HotpotColors.espresso,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search biryani, fried rice, starters, sweets…',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: HotpotColors.terracotta,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: HotpotColors.muted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: dynamicCategories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TactilePress(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HotpotColors.terracotta
                      : HotpotColors.cardTone,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HotpotColors.terracotta.withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? HotpotColors.paper
                        : HotpotColors.espresso,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuSection(List<Dish> dishes) {
    if (_isLoading && _dishes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HotpotShimmer(width: 180, height: 20, borderRadius: 6),
          const SizedBox(height: 16),
          const HotpotShimmer(
            width: double.infinity,
            height: 190,
            borderRadius: 22,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: HotpotShimmer(height: 130, borderRadius: 18)),
              SizedBox(width: 12),
              Expanded(child: HotpotShimmer(height: 130, borderRadius: 18)),
            ],
          ),
        ],
      );
    }

    if (_errorMessage != null && _dishes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: HotpotColors.cardTone,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: HotpotColors.terracotta,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Couldn't reach the kitchen.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: HotpotColors.espresso,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Let's try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: HotpotColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              TactilePress(
                onTap: _fetchMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: HotpotColors.espresso,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: HotpotColors.paper,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (dishes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: HotpotColors.cardTone,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    color: HotpotColors.terracotta,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No luck this time.\nTry another craving.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'The kitchen is always listening.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: HotpotColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                TactilePress(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = 'All';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: HotpotColors.espresso,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Reset search',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: HotpotColors.paper,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (_selectedCategory != 'All') {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "That craving isn't on the menu yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Try another category or check back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: HotpotColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                TactilePress(
                  onTap: () => setState(() => _selectedCategory = 'All'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: HotpotColors.espresso,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View all dishes',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: HotpotColors.paper,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: HotpotColors.cardTone,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.soup_kitchen_rounded,
                    color: HotpotColors.terracotta,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The kitchen is taking a breather.\nCheck back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 18),
                TactilePress(
                  onTap: _fetchMenu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: HotpotColors.espresso,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Refresh menu',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: HotpotColors.paper,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE CROWD FAVOURITES',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.terracotta,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedCategory == 'All'
                      ? 'From the kitchen line'
                      : '$_selectedCategory selection',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
            Text(
              '${dishes.length} dishes',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: HotpotColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            // First item gets featured asymmetric emphasis if displayed!
            final hasFeatured = dishes.isNotEmpty && dishes.first.isFeatured;
            final featuredDish = hasFeatured ? dishes.first : null;
            final otherDishes = hasFeatured ? dishes.sublist(1) : dishes;

            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 580
                ? 2
                : 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (featuredDish != null) ...[
                  _buildFeaturedDishCard(featuredDish),
                  if (otherDishes.isNotEmpty) const SizedBox(height: 16),
                ],
                if (otherDishes.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: otherDishes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: columns == 1 ? 2.5 : 0.78,
                    ),
                    itemBuilder: (context, index) {
                      return _buildStandardDishCard(otherDishes[index]);
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedDishCard(Dish dish) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final cardContent = Container(
          decoration: BoxDecoration(
            color: HotpotColors.featuredTone,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x121A1310),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(22),
                        ),
                        child: HotpotNetworkImage(
                          imageUrl: dish.imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _buildDishDetails(dish, isFeatured: true),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: HotpotNetworkImage(
                          imageUrl: dish.imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildDishDetails(dish, isFeatured: true),
                    ),
                  ],
                ),
        );

        return isWide ? SizedBox(height: 230, child: cardContent) : cardContent;
      },
    );
  }

  Widget _buildStandardDishCard(Dish dish) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal =
            constraints.maxHeight <= 160 && constraints.maxWidth >= 300;
        if (isHorizontal) {
          return Container(
            decoration: BoxDecoration(
              color: HotpotColors.paper,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C1A1310),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                  child: HotpotNetworkImage(
                    imageUrl: dish.imageUrl,
                    width: 120,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: _buildDishDetails(dish, isFeatured: false),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: HotpotColors.paper,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C1A1310),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: HotpotNetworkImage(
                    imageUrl: dish.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _buildDishDetails(dish, isFeatured: false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDishDetails(Dish dish, {required bool isFeatured}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isFeatured
                        ? HotpotColors.terracotta
                        : HotpotColors.terracotta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isFeatured
                        ? 'CHEF’S SIGNATURE'
                        : dish.category.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isFeatured
                          ? HotpotColors.paper
                          : HotpotColors.terracotta,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                if (!dish.available) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SOLD OUT',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dish.name,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: isFeatured ? 21 : 16,
                fontWeight: FontWeight.w800,
                color: HotpotColors.espresso,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              dish.note,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isFeatured ? 13 : 12,
                color: HotpotColors.muted,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₹${dish.price}',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: isFeatured ? 22 : 18,
                fontWeight: FontWeight.w900,
                color: HotpotColors.espresso,
                letterSpacing: -0.5,
              ),
            ),
            if (dish.available)
              TactilePress(
                onTap: () => _addToCart(dish),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: HotpotColors.espresso,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: HotpotColors.paper,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: HotpotColors.paper,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: HotpotColors.muted.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SOLD OUT',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: HotpotColors.muted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavPrompt(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          TactilePress(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: HotpotColors.cardTone,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: HotpotColors.muted,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tell the kitchen how we did',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: HotpotColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TactilePress(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackOrderPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: HotpotColors.cardTone,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: HotpotColors.muted,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Track live status',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: HotpotColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cart Screen with food thumbnails, accurate totals, live quantity manipulation,
/// and conversational empty state.
class CartPage extends StatelessWidget {
  final ValueNotifier<Map<String, int>> cartNotifier;
  final List<Dish>? dishes;

  const CartPage({super.key, required this.cartNotifier, this.dishes});

  Dish _findDish(String name) {
    final list = (dishes != null && dishes!.isNotEmpty) ? dishes! : kDishes;
    return list.firstWhere(
      (d) => d.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Dish(
        name: name,
        category: 'Menu',
        price: 0,
        imageUrl: '',
        note: '',
        available: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Table'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Map<String, int>>(
          valueListenable: cartNotifier,
          builder: (context, cart, _) {
            final entries = cart.entries.toList();
            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          color: HotpotColors.cardTone,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.soup_kitchen_rounded,
                          color: HotpotColors.terracotta,
                          size: 46,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your table is looking a little empty.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: HotpotColors.espresso,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Let’s fix that — the biryani has been waiting.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          color: HotpotColors.muted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TactilePress(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: HotpotColors.terracotta,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Explore the Menu',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: HotpotColors.paper,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final total = entries.fold<int>(
              0,
              (sum, e) => sum + (_findDish(e.key).price * e.value),
            );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Text(
                            'ITEMS ORDERED',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: HotpotColors.terracotta,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...entries.map((entry) {
                            final dish = _findDish(entry.key);
                            final itemTotal = dish.price * entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: HotpotColors.paper,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A1A1310),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  HotpotNetworkImage(
                                    imageUrl: dish.imageUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    borderRadius: 12,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dish.name,
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: HotpotColors.espresso,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${dish.price} each • Total: ₹$itemTotal',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 12,
                                            color: HotpotColors.muted,
                                          ),
                                        ),
                                        if (!dish.available)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'SOLD OUT',
                                                    style: TextStyle(
                                                      fontFamily: 'Outfit',
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          Colors.red.shade900,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                InkWell(
                                                  onTap: () {
                                                    final next =
                                                        Map<String, int>.from(
                                                          cartNotifier.value,
                                                        );
                                                    next.remove(entry.key);
                                                    cartNotifier.value = next;
                                                  },
                                                  child: const Text(
                                                    'Remove',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: HotpotColors
                                                          .terracotta,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: HotpotColors.cardTone,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          iconSize: 18,
                                          onPressed: () {
                                            final next = Map<String, int>.from(
                                              cartNotifier.value,
                                            );
                                            if (entry.value <= 1) {
                                              next.remove(entry.key);
                                            } else {
                                              next[entry.key] = entry.value - 1;
                                            }
                                            cartNotifier.value = next;
                                          },
                                          icon: const Icon(
                                            Icons.remove_rounded,
                                            color: HotpotColors.espresso,
                                          ),
                                        ),
                                        Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: HotpotColors.espresso,
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          iconSize: 18,
                                          onPressed: () {
                                            final next = Map<String, int>.from(
                                              cartNotifier.value,
                                            );
                                            next[entry.key] = entry.value + 1;
                                            cartNotifier.value = next;
                                          },
                                          icon: const Icon(
                                            Icons.add_rounded,
                                            color: HotpotColors.espresso,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: HotpotColors.cardTone,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Subtotal',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: HotpotColors.muted,
                                      ),
                                    ),
                                    Text(
                                      '₹$total',
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w700,
                                        color: HotpotColors.espresso,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kitchen packaging & Delivery',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: HotpotColors.muted,
                                      ),
                                    ),
                                    Text(
                                      'On the house',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w700,
                                        color: HotpotColors.terracotta,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 24,
                                  color: HotpotColors.softBorder,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: HotpotColors.espresso,
                                      ),
                                    ),
                                    Text(
                                      '₹$total',
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: HotpotColors.espresso,
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
                    if (entries.any((e) => !_findDish(e.key).available))
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Some dishes on your table are currently sold out. Remove them to proceed to checkout.',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final next = Map<String, int>.from(
                                  cartNotifier.value,
                                );
                                next.removeWhere(
                                  (name, _) => !_findDish(name).available,
                                );
                                cartNotifier.value = next;
                              },
                              child: const Text(
                                'Clear sold out',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: HotpotColors.espresso,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TO PAY',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: HotpotColors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  '₹$total',
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    color: HotpotColors.paper,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final hasUnavailable = entries.any(
                                (e) => !_findDish(e.key).available,
                              );
                              return TactilePress(
                                onTap: hasUnavailable
                                    ? () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              'Please remove sold out dishes from your table before proceeding.',
                                            ),
                                          ),
                                        );
                                      }
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CheckoutPage(
                                              cartNotifier: cartNotifier,
                                              total: total,
                                            ),
                                          ),
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasUnavailable
                                        ? Colors.grey.shade400
                                        : HotpotColors.amber,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        hasUnavailable
                                            ? 'Item Sold Out'
                                            : 'Checkout Details',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          color: hasUnavailable
                                              ? Colors.white
                                              : HotpotColors.espresso,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: hasUnavailable
                                            ? Colors.white
                                            : HotpotColors.espresso,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Checkout screen capturing name, validated 10-digit phone, and delivery address.
/// Uses custom non-spinner loading state and triggers Order Confirmation on success.
class CheckoutPage extends StatefulWidget {
  final ValueNotifier<Map<String, int>> cartNotifier;
  final int total;

  const CheckoutPage({
    super.key,
    required this.cartNotifier,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isPlacingOrder = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      _showNotice(
        'Please enter your name so the kitchen knows who to address.',
      );
      return;
    }

    if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showNotice(
        'Please provide a valid 10-digit phone number for delivery updates.',
      );
      return;
    }

    if (address.isEmpty) {
      _showNotice('Please provide your complete delivery address.');
      return;
    }

    setState(() {
      _isPlacingOrder = true;
      _errorMessage = null;
    });

    final List<Map<String, dynamic>> orderItems = widget
        .cartNotifier
        .value
        .entries
        .map((entry) => {'food_name': entry.key, 'quantity': entry.value})
        .toList();

    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:8000/orders'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'address': address,
              'total': widget.total,
              'items': orderItems,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final orderId = data['order_id'].toString();

        // Clear cart ONLY after order succeeds!
        widget.cartNotifier.value = {};

        _showOrderConfirmedSheet(
          orderId: orderId,
          phone: phone,
          total: widget.total,
        );
      } else {
        setState(() {
          _errorMessage =
              'The kitchen could not process this order (Status: ${response.statusCode}). Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not reach the server right now. Make sure the local backend is running.';
      });
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  void _showNotice(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: HotpotColors.espresso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: HotpotColors.paper,
          ),
        ),
      ),
    );
  }

  void _showOrderConfirmedSheet({
    required String orderId,
    required String phone,
    required int total,
  }) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OrderConfirmedSheet(
          orderId: orderId,
          phone: phone,
          total: total,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const Text(
                  'ALMOST AT THE TABLE',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.terracotta,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Where should we send your feast?',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    hintText: 'e.g. Arjan Dev',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: HotpotColors.terracotta,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone number (10 digits)',
                    hintText: 'e.g. 9876543210',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: HotpotColors.terracotta,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _addressController,
                  maxLines: 3,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                    hintText: 'Flat / Door number, Street, Landmark...',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: HotpotColors.terracotta,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: HotpotColors.cardTone,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Payable',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: HotpotColors.espresso,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${widget.total}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: HotpotColors.espresso,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: HotpotColors.terracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: HotpotColors.terracotta,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_isPlacingOrder)
                  const HotpotPulseLoader(
                    label: 'Transmitting ticket to the kitchen…',
                  )
                else
                  TactilePress(
                    onTap: _submitOrder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: HotpotColors.terracotta,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: HotpotColors.terracotta.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Place Order  →',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: HotpotColors.paper,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal bottom sheet widget displayed once an order is successfully placed.
/// Responsive and scroll-safe: adapts to all screen heights and font scales
/// without vertical or horizontal RenderFlex overflow.
class OrderConfirmedSheet extends StatelessWidget {
  final String orderId;
  final String phone;
  final int total;

  const OrderConfirmedSheet({
    super.key,
    required this.orderId,
    required this.phone,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HotpotColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x331A1310),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: HotpotColors.cardTone,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: HotpotColors.terracotta,
                          size: 32,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: HotpotColors.successGreen.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CONFIRMED',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: HotpotColors.successGreen,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order’s in. 🔥',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: HotpotColors.espresso,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your kitchen ticket has been fired up. Grab a glass of water, we’ll take it from here.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: HotpotColors.muted,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HotpotColors.cardTone,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORDER TICKET ID',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: HotpotColors.muted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              SelectableText(
                                orderId,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: HotpotColors.espresso,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'TOTAL PAID',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: HotpotColors.muted,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹$total',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: HotpotColors.espresso,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: TactilePress(
                      onTap: () {
                        Navigator.pop(context); // Close sheet
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackOrderPage(
                              initialOrderId: orderId,
                              initialPhone: phone,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: HotpotColors.terracotta,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: HotpotColors.terracotta.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Track my order  →',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: HotpotColors.paper,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: HotpotColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Order Tracking screen consuming POST /orders/track.
/// Displays a tasteful vertical status timeline distinguishing past, current,
/// and future kitchen stages alongside itemized summary and refresh control.
class TrackOrderPage extends StatefulWidget {
  final String initialOrderId;
  final String initialPhone;

  const TrackOrderPage({
    super.key,
    this.initialOrderId = '',
    this.initialPhone = '',
  });

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  late final TextEditingController _orderIdController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _orderData;

  static const List<String> _stages = [
    'pending',
    'preparing',
    'ready',
    'delivered',
  ];

  static const Map<String, String> _stageTitles = {
    'pending': 'Order received',
    'preparing': 'In the kitchen',
    'ready': 'Ready to go',
    'delivered': 'Delivered',
  };

  static const Map<String, String> _stageDescriptions = {
    'pending': 'We’ve taken your ticket and queued it up for the line.',
    'preparing':
        'Dum simmering, pans sizzling, flavours melding on high flame.',
    'ready': 'Packed piping hot and sealed fresh for the ride.',
    'delivered': 'Arrived at your table. Bon appétit!',
  };

  @override
  void initState() {
    super.initState();
    _orderIdController = TextEditingController(text: widget.initialOrderId);
    _phoneController = TextEditingController(text: widget.initialPhone);

    // If initial values are provided, trigger track automatically
    if (widget.initialOrderId.isNotEmpty && widget.initialPhone.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _trackOrder());
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    final orderId = _orderIdController.text.trim();
    final phone = _phoneController.text.trim();

    if (orderId.isEmpty || phone.isEmpty) {
      setState(() {
        _errorMessage =
            'Add both your Order ID and phone number to find your table.';
        _orderData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:8000/orders/track'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'order_id': orderId, 'phone': phone}),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _orderData = jsonDecode(response.body) as Map<String, dynamic>;
          _errorMessage = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _orderData = null;
          _errorMessage =
              'We couldn’t find an order matching that ticket. Double-check your Order ID and phone number.';
        });
      } else {
        setState(() {
          _orderData = null;
          _errorMessage =
              'Could not retrieve tracking details right now. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _orderData = null;
        _errorMessage =
            'Could not connect to the kitchen server. Please ensure the backend is running.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = (_orderData?['status'] ?? '')
        .toString()
        .toLowerCase();
    final activeIndex = _stages.indexOf(currentStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const Text(
                  'LIVE FROM THE KITCHEN',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.terracotta,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Where’s the good stuff?',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: HotpotColors.paper,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C1A1310),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _orderIdController,
                        decoration: const InputDecoration(
                          labelText: 'Order ID',
                          hintText: 'e.g. 1774391823901',
                          prefixIcon: Icon(
                            Icons.tag_rounded,
                            color: HotpotColors.terracotta,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone number used for order',
                          hintText: '10 digits',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: HotpotColors.terracotta,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const HotpotPulseLoader(
                          label: 'Checking with the kitchen…',
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: TactilePress(
                            onTap: _trackOrder,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: HotpotColors.espresso,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  'Find My Ticket',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: HotpotColors.paper,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HotpotColors.terracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: HotpotColors.terracotta,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: HotpotColors.terracotta,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_orderData != null) ...[
                  const SizedBox(height: 24),
                  _buildTrackingDetailsCard(activeIndex),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingDetailsCard(int activeIndex) {
    final order = _orderData!;
    final items = List<dynamic>.from(order['items'] ?? const []);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: HotpotColors.paper,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x101A1310),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS REPORT',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: HotpotColors.terracotta,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    'Order #${order['order_id']}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: HotpotColors.espresso,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              TactilePress(
                onTap: _isLoading ? null : _trackOrder,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HotpotColors.cardTone,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: HotpotColors.espresso,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Tasteful Vertical Status Timeline
          ...List.generate(_stages.length, (i) {
            final stage = _stages[i];
            final isDone = activeIndex >= 0 && i < activeIndex;
            final isCurrent = i == activeIndex;
            final isUpcoming = activeIndex < 0 || i > activeIndex;
            final isLast = i == _stages.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? HotpotColors.successGreen
                            : isCurrent
                            ? HotpotColors.terracotta
                            : HotpotColors.cardTone,
                        border: isCurrent
                            ? Border.all(color: HotpotColors.amber, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          isDone
                              ? Icons.check_rounded
                              : isCurrent
                              ? Icons.local_fire_department_rounded
                              : Icons.circle_outlined,
                          size: 16,
                          color: isUpcoming
                              ? HotpotColors.muted
                              : HotpotColors.paper,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 38,
                        color: isDone
                            ? HotpotColors.successGreen
                            : HotpotColors.cardTone,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stageTitles[stage]!,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: isCurrent
                                ? FontWeight.w900
                                : FontWeight.w700,
                            color: isUpcoming
                                ? HotpotColors.muted
                                : HotpotColors.espresso,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _stageDescriptions[stage]!,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: isCurrent
                                ? HotpotColors.espresso
                                : HotpotColors.muted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const Divider(height: 24, color: HotpotColors.softBorder),
          const Text(
            'ITEMS IN YOUR TICKET',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: HotpotColors.terracotta,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['food_name']}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      color: HotpotColors.espresso,
                    ),
                  ),
                  Text(
                    '× ${item['quantity']}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                      color: HotpotColors.espresso,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24, color: HotpotColors.softBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: HotpotColors.espresso,
                ),
              ),
              Text(
                '₹${order['total']}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: HotpotColors.espresso,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Feedback Screen with interactive 5-star selector and conversational confirmation dialog.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int _rating = 5;
  bool _isSending = false;

  static const List<String> _ratingLabels = [
    'Needs urgent kitchen review',
    'Didn’t hit the mark',
    'Good, but room to improve',
    'Delicious meal!',
    'Pure bliss! Absolute perfection. 🔥',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final message = _feedbackController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: HotpotColors.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            'Please leave a brief thought so the kitchen knows how to grow.',
            style: TextStyle(fontFamily: 'Outfit', color: HotpotColors.paper),
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    // Optional submission to backend /feedback if supported, safely handled.
    try {
      await http
          .post(
            Uri.parse('http://127.0.0.1:8000/feedback'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'customer_name': _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              'message': 'Rating: $_rating/5 - $message',
            }),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Safe fallback UI-only as specified
    } finally {
      if (mounted) setState(() => _isSending = false);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: HotpotColors.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: HotpotColors.terracotta,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Kitchen notes received.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: HotpotColors.espresso,
                ),
              ),
            ],
          ),
          content: const Text(
            'Thank you — every good plate gets better with honest feedback. We read every single note.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: HotpotColors.muted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TactilePress(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: HotpotColors.espresso,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Back to Menu',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    color: HotpotColors.paper,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Note for the Kitchen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const Text(
                  'YOUR VOICE MATTERS',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.terracotta,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: HotpotColors.espresso,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HotpotColors.paper,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C1A1310),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return IconButton(
                            iconSize: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            icon: Icon(
                              star <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: HotpotColors.amber,
                            ),
                            onPressed: () => setState(() => _rating = star),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _ratingLabels[_rating - 1],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: HotpotColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name (optional)',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: HotpotColors.terracotta,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _feedbackController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Your thoughts',
                    hintText:
                        'A favourite bite, spice levels, a compliment or suggestion...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isSending)
                  const HotpotPulseLoader(
                    label: 'Sending your thoughts to the kitchen…',
                  )
                else
                  TactilePress(
                    onTap: _submitFeedback,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: HotpotColors.terracotta,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: HotpotColors.terracotta.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Send Feedback  →',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: HotpotColors.paper,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
