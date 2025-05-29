// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:eight_logbook/main.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SoftSkillsLogbookApp());

    // Verify that our app shows the correct title.
    expect(find.text('EightFaces: Soft Skills Engine'), findsOneWidget);

    // Verify that the empty state is shown initially
    expect(find.text('Пока нет записей'), findsOneWidget);
    expect(find.text('Нажмите + чтобы создать первую запись'), findsOneWidget);
  });
}
