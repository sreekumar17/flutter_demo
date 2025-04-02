import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:demo_app/main.dart';

// Create a mock Hive box
class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockBox = MockBox();
    when(mockBox.containsKey('data')).thenReturn(false); // No data initially
  });

  testWidgets('MyApp widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DataProvider(), // Provide the DataProvider
        child: MaterialApp(home: MyApp()),
      ),
    );

    expect(find.text('My Flutter App'), findsOneWidget);
  });
}