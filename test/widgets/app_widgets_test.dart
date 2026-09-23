import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taillorbook/core/utils/validators.dart';
import 'package:taillorbook/core/widgets/app_button.dart';
import 'package:taillorbook/core/widgets/app_empty.dart';
import 'package:taillorbook/core/widgets/app_text_field.dart';

void main() {
  testWidgets('AppButton déclenche onPressed au tap', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Commander',
              expanded: false,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Commander'));
    expect(pressed, isTrue);
  });

  testWidgets('AppButton en chargement est désactivé', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Commander',
              expanded: false,
              loading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(pressed, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppTextField affiche le message du validateur', (WidgetTester tester) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: const AppTextField(hintText: 'Email', validator: Validators.email),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text(Validators.kInvalidEmail), findsOneWidget);
  });

  testWidgets('AppTextField masque le mot de passe', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppTextField(hintText: 'Mot de passe', obscureText: true)),
      ),
    );

    final EditableText editable = tester.widget(find.byType(EditableText));
    expect(editable.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    final EditableText revealed = tester.widget(find.byType(EditableText));
    expect(revealed.obscureText, isFalse);
  });

  testWidgets('AppEmpty affiche titre, message et action', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmpty(
            title: 'Panier vide',
            message: 'Aucun article.',
            actionLabel: 'Catalogue',
            onAction: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Panier vide'), findsOneWidget);
    expect(find.text('Aucun article.'), findsOneWidget);

    await tester.tap(find.text('Catalogue'));
    expect(pressed, isTrue);
  });
}
