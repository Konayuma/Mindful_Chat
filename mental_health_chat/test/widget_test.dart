import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_health_chat/screens/chat_screen.dart';

void main() {
  testWidgets('ChatScreen has a title and message input', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChatScreen()));

    expect(find.text('Chat'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('ChatScreen displays messages', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChatScreen()));

    // Simulate sending a message
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
  });
}