// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Provide a minimal test app here so the test doesn't depend on the real
// MyApp class from the application. This keeps the test file self-contained
// and avoids the "The name 'MyApp' isn't a class" error.

import 'package:flutter/material.dart' as _m;

class TestApp extends _m.StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends _m.State<TestApp> {
  int _counter = 0;

  @override
  _m.Widget build(_m.BuildContext context) {
    return _m.MaterialApp(
      home: _m.Scaffold(
        body: Center(child: _m.Text('$_counter')),
        floatingActionButton: _m.FloatingActionButton(
          onPressed: () => setState(() => _counter++),
          child: const _m.Icon(_m.Icons.add),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our test app and trigger a frame.
    await tester.pumpWidget(TestApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
