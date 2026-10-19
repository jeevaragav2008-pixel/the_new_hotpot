import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_new_hotpot/customer_ui.dart';

void main() {
  Widget buildSheetApp({
    Size screenSize = const Size(390, 800),
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: screenSize,
          textScaler: textScaler,
          padding: const EdgeInsets.only(bottom: 34),
        ),
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isDismissible: false,
                    enableDrag: false,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const OrderConfirmedSheet(
                      orderId: 'HOTPOT-8842',
                      phone: '9876543210',
                      total: 480,
                    ),
                  );
                },
                child: const Text('Show Order Sheet'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Order confirmation sheet renders without overflow on standard mobile (390x800)',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSheetApp(screenSize: const Size(390, 800)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Order Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Order’s in. 🔥'), findsOneWidget);
      expect(find.text('ORDER TICKET ID'), findsOneWidget);
      expect(find.text('HOTPOT-8842'), findsOneWidget);
      expect(find.text('TOTAL PAID'), findsOneWidget);
      expect(find.text('₹480'), findsOneWidget);
      expect(find.text('Track my order  →'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // Ensure zero render flex overflow exceptions
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Order confirmation sheet renders without overflow on small screen (360x500)',
    (tester) async {
      tester.view.physicalSize = const Size(360, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSheetApp(screenSize: const Size(360, 500)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Order Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Order’s in. 🔥'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // Verify zero render flex overflow exceptions on small screens
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Order confirmation sheet renders without overflow in landscape (640x360)',
    (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSheetApp(screenSize: const Size(640, 360)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Order Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Order’s in. 🔥'), findsOneWidget);

      // Can scroll down cleanly to see the buttons
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back to Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Order confirmation sheet renders without overflow with large 1.5x accessibility text scale',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildSheetApp(
          screenSize: const Size(390, 800),
          textScaler: const TextScaler.linear(1.5),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Order Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Order’s in. 🔥'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // No overflow should happen with large text
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Order confirmation sheet Back to Home button pops sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSheetApp(screenSize: const Size(390, 800)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Order Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Back to Home'), findsOneWidget);
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Sheet should be dismissed
    expect(find.text('Order’s in. 🔥'), findsNothing);
    expect(find.text('Show Order Sheet'), findsOneWidget);
  });
}
