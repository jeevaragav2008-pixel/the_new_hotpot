import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_new_hotpot/customer_ui.dart';
import 'package:the_new_hotpot/models/food.dart';

void main() {
  group('Food model unit tests', () {
    test('Food.fromJson parses valid payload properly', () {
      final json = {
        'id': 1,
        'name': 'Chicken Biryani',
        'category': 'Biryani',
        'price': 160.0,
        'image_url': 'https://images.unsplash.com/biryani.jpg',
        'description': 'Fragrant basmati rice cooked with spiced chicken',
        'available': true,
        'created_at': '2026-10-19T10:00:00Z',
        'updated_at': '2026-10-19T10:30:00Z',
      };

      final food = Food.fromJson(json);
      expect(food.id, 1);
      expect(food.name, 'Chicken Biryani');
      expect(food.category, 'Biryani');
      expect(food.price, 160);
      expect(food.imageUrl, 'https://images.unsplash.com/biryani.jpg');
      expect(
        food.description,
        'Fragrant basmati rice cooked with spiced chicken',
      );
      expect(food.available, true);
    });

    test('Food.toJson serializes correctly', () {
      final food = const Food(
        id: 2,
        name: 'Mutton Biryani',
        category: 'Biryani',
        price: 190,
        imageUrl: '',
        description: 'Tender mutton pieces',
        available: false,
      );

      final json = food.toJson();
      expect(json['id'], 2);
      expect(json['name'], 'Mutton Biryani');
      expect(json['price'], 190);
      expect(json['available'], false);
    });

    test('Dish.fromFood and toFood preserve values accurately', () {
      final food = const Food(
        id: 3,
        name: 'Gulab Jamun',
        category: 'Desserts',
        price: 40,
        imageUrl: 'https://example.com/jamun.jpg',
        description: 'Warm melt-in-the-mouth dumplings',
        available: true,
      );

      final dish = Dish.fromFood(food);
      expect(dish.id, 3);
      expect(dish.name, 'Gulab Jamun');
      expect(dish.category, 'Desserts');
      expect(dish.price, 40);
      expect(dish.available, true);
      expect(dish.note, 'Warm melt-in-the-mouth dumplings');

      final backToFood = dish.toFood();
      expect(backToFood.id, 3);
      expect(backToFood.name, 'Gulab Jamun');
      expect(backToFood.price, 40);
    });
  });

  group('CartPage sold-out handling widget tests', () {
    final availableBiryani = const Dish(
      id: 1,
      name: 'Chicken Biryani',
      category: 'Biryani',
      price: 160,
      imageUrl: '',
      note: 'Hot fragrant biryani',
      available: true,
    );

    final soldOutJamun = const Dish(
      id: 2,
      name: 'Gulab Jamun',
      category: 'Desserts',
      price: 40,
      imageUrl: '',
      note: 'Sweet treat',
      available: false,
    );

    testWidgets(
      'CartPage displays items and enables checkout when all available',
      (tester) async {
        final cartNotifier = ValueNotifier<Map<String, int>>({
          'Chicken Biryani': 2,
        });

        await tester.pumpWidget(
          MaterialApp(
            home: CartPage(
              cartNotifier: cartNotifier,
              dishes: [availableBiryani],
            ),
          ),
        );

        expect(find.text('Chicken Biryani'), findsOneWidget);
        expect(find.text('₹320'), findsWidgets);
        // Checkout button should display "Checkout Details"
        final checkoutBtn = find.text('Checkout Details');
        expect(checkoutBtn, findsOneWidget);
      },
    );

    testWidgets(
      'CartPage blocks checkout and displays SOLD OUT warning when item becomes unavailable',
      (tester) async {
        final cartNotifier = ValueNotifier<Map<String, int>>({
          'Chicken Biryani': 1,
          'Gulab Jamun': 2,
        });

        await tester.pumpWidget(
          MaterialApp(
            home: CartPage(
              cartNotifier: cartNotifier,
              dishes: [availableBiryani, soldOutJamun],
            ),
          ),
        );

        // Verify SOLD OUT tag is visible for Gulab Jamun
        expect(find.text('SOLD OUT'), findsWidgets);

        // Verify the warning banner is displayed
        expect(
          find.text(
            'Some dishes on your table are currently sold out. Remove them to proceed to checkout.',
          ),
          findsOneWidget,
        );

        // Verify clear sold out button is visible
        expect(find.text('Clear sold out'), findsOneWidget);

        // Verify checkout button says "Item Sold Out"
        expect(find.text('Item Sold Out'), findsOneWidget);
      },
    );
  });
}
