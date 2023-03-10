// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_machine_test/data/photo_item.dart';
import 'package:flutter_machine_test/injection/injection.dart';
import 'package:flutter_machine_test/networking/network_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_machine_test/main.dart';
import 'package:mockito/annotations.dart';

import 'flutter_test.dart';
import 'flutter_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Dio>()])
void main() {
  final dio = MockDio();
  setUpAll(() async {
    configureDependencies();

    getIt.allowReassignment = true;
    getIt.registerSingleton<Dio>(dio);
    mockApiData(dio);
  });

  group('- Home Screen test', () {
    testWidgets('- Load data test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Photos'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
    });
    testWidgets('- List scroll test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byKey(const Key('item-1')), findsOneWidget);

      await tester.dragUntilVisible(
          find.byKey(const Key('item-100')), // what you want to find
          find.byType(ListView),
          const Offset(0, -200), // delta to move
          duration: const Duration(seconds: 2));
      expect(find.byKey(const Key('item-1')), findsNothing);
    });

    testWidgets('- Show detail screen test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      await tester.dragUntilVisible(
          find.byKey(const Key('item-100')), // what you want to find
          find.byType(ListView),
          const Offset(0, -200), // delta to move
          duration: const Duration(seconds: 2));
      NetworkRepository repository = getIt<NetworkRepository>();
      final List<PhotoItem> items = await repository.getPhotos();
      final item = items.firstWhere((e) => e.id == 100);
      final selectedItem = find.byKey(const Key('item-100'));
      await tester.tap(selectedItem);
      await tester.pump();
      expect(find.text('Id: ${item.id}', skipOffstage: false), findsOneWidget);
      expect(find.text(item.title), findsOneWidget);
      expect(find.text('album #: ${item.albumId}', skipOffstage: false),
          findsOneWidget);
    });
  });
}
