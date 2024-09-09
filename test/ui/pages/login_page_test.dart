import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'login_page_test.mocks.dart';

import 'package:fordev/ui/pages/pages.dart';

@GenerateNiceMocks([MockSpec<LoginPresenter>()])
void main() {
  LoginPresenter? presenter;
  StreamController<String>? emailErrorController;

  Future<void> loadPage(WidgetTester tester) async {
    presenter = MockLoginPresenter();
    emailErrorController = StreamController<String>();
    when(presenter?.emailErrorStream)
        .thenAnswer((_) => emailErrorController?.stream);
    final loginPage = MaterialApp(home: LoginPage(presenter: presenter!));
    await tester.pumpWidget(loginPage);
  }

  tearDown(() {
    emailErrorController?.close();
  });

  testWidgets('Should load with correct initial state',
      (WidgetTester tester) async {
    await loadPage(tester);

    final emailTextChildren = find.descendant(
        of: find.bySemanticsLabel('Email'), matching: find.byType(Text));
    expect(
      emailTextChildren,
      findsOneWidget,
      reason:
          'when a TextFormField has only one text child, means it has no errors, since one of the childs is always the label text',
    );

    final passwordTextChildren = find.descendant(
        of: find.bySemanticsLabel('Senha'), matching: find.byType(Text));
    expect(
      passwordTextChildren,
      findsOneWidget,
      reason:
          'when a TextFormField has only one text child, means it has no errors, since one of the childs is always the label text',
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, null);
  });

  testWidgets('Should call validate with correct values',
      (WidgetTester tester) async {
    // Carrega a tela que será testada
    await loadPage(tester);

    //Simula o e-mail que será inserido
    final email = faker.internet.email();
    //Mostra qual campo eu vou testar pelo {find.bySemantics} e insere o valor nele {email}
    await tester.enterText(find.bySemanticsLabel('Email'), email);
    //Verifica se sempre que chamar o presenter o email simulado vai ser o mesmo que aparece nele
    verify(presenter?.validateEmail(email));

    //Simula o password que será inserido
    final password = faker.internet.password();
    //Mostra qual campo eu vou testar pelo {find.bySemantics} e insere o valor nele {Senha}
    await tester.enterText(find.bySemanticsLabel('Senha'), password);
    //Verifica se sempre que chamar o presenter a senha simulada vai ser a mesma que aparece nele
    verify(presenter?.validatePassword(password));
  });

  testWidgets('Should present error if email is invalid',
      (WidgetTester tester) async {
        //Carrega a tela que será testada
    await loadPage(tester);

    //Como a tela será atualizada através de uma Stream, então adiciona o texto digitado recebido no presenter a Stream
    emailErrorController?.add('any error');
    //Faz a tela atualizaro estado
    await tester.pump();

    //Espera que encontre o texto mockado em apenas um widget
    expect(find.text('any error'), findsOneWidget);
  });

  testWidgets('Should present no error if email is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add(null);
    await tester.pump();

    expect(
      find.descendant(
          of: find.bySemanticsLabel('Email'), matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('Should present no error if email is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    await tester.pump();

    expect(
      find.descendant(
        of: find.bySemanticsLabel('Email'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });
}
