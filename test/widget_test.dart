import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:thyroid_tracker/main.dart';
import 'package:thyroid_tracker/src/app/app_state.dart';
import 'package:thyroid_tracker/src/data/local/app_database.dart';

void main() {
  testWidgets('app opens onboarding first', (tester) async {
    final state = AppState(database: AppDatabase(NativeDatabase.memory()));
    addTearDown(state.dispose);

    await tester.pumpWidget(ThyroidTrackerApp(appState: state));
    await tester.pumpAndSettle();

    expect(find.text('Давайте познакомимся'), findsOneWidget);
    expect(find.text('Далее'), findsOneWidget);
  });

  testWidgets('app opens overview after onboarding', (tester) async {
    final state = AppState(database: AppDatabase(NativeDatabase.memory()));
    addTearDown(state.dispose);
    await state.completeOnboarding(
      name: 'Анна',
      birthDate: DateTime(1994, 1, 1),
      weightKg: 68,
      heightCm: 170,
      sex: 'female',
      diagnosis: 'Гипотиреоз',
      medicationName: 'Эутирокс',
      dosage: '75 мкг',
      intakeTime: DateTime(2026, 1, 1, 8),
      labControlDays: 90,
      doctorControlDays: 180,
    );

    await tester.pumpWidget(ThyroidTrackerApp(appState: state));
    await tester.pumpAndSettle();

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Эутирокс'), findsOneWidget);
  });
}
