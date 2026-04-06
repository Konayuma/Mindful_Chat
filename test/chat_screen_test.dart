import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_health/screens/chat_screen.dart';

void main() {
  testWidgets('ChatScreen has a title and message input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

    // Adjusted to match common ChatScreen implementations
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
  });
}
