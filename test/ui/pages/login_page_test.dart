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
  MockLoginPresenter? presenter;
  StreamController<String?>? emailErrorController;
  StreamController<String?>? passwordErrorController;
  StreamController<String?>? mainErrorController;
  StreamController<bool>? isFormValidController;
  StreamController<bool>? isLoadingController;

  void initStreams() {
    emailErrorController = StreamController<String?>();
    passwordErrorController = StreamController<String?>();
    mainErrorController = StreamController<String?>();
    isFormValidController = StreamController<bool>();
    isLoadingController = StreamController<bool>();
  }

  void mockStreams() {
    when(presenter?.emailErrorStream)
        .thenAnswer((_) => emailErrorController?.stream);
    when(presenter?.passwordErrorStream)
        .thenAnswer((_) => passwordErrorController?.stream);
    when(presenter?.mainErrorStream)
        .thenAnswer((_) => mainErrorController?.stream);
    when(presenter?.isFormValidStream)
        .thenAnswer((_) => isFormValidController?.stream);
    when(presenter?.isLoadingStream)
        .thenAnswer((_) => isLoadingController?.stream);
  }

  void closeStreams() {
    emailErrorController?.close();
    passwordErrorController?.close();
    mainErrorController?.close();
    isFormValidController?.close();
    isLoadingController?.close();
  }

  Future<void> loadPage(WidgetTester tester) async {
    presenter = MockLoginPresenter();
    initStreams();
    mockStreams();

    final loginPage = MaterialApp(home: LoginPage(presenter: presenter));
    await tester.pumpWidget(loginPage);
  }

  tearDown(() {
    closeStreams();
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
    expect(find.byType(CircularProgressIndicator), findsNothing);
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

    emailErrorController?.add(null);
    await tester.pump();

    //Espera encontrar apenas um elemento de texto dentro do campo Email
    expect(
      find.descendant(
          of: find.bySemanticsLabel('Email'), matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('Should present no error if email is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController?.add('');
    await tester.pump();

    //Espera encontrar apenas um elemento de texto dentro do campo Email
    expect(
      find.descendant(
          of: find.bySemanticsLabel('Email'), matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('Should present error if password is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController?.add('any error');
    await tester.pump();

    expect(find.text('any error'), findsOneWidget);
  });

  testWidgets('Should present no error if password is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController?.add(null);
    await tester.pump();

    expect(
      find.descendant(
          of: find.bySemanticsLabel('Senha'), matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('Should present no error if password is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController?.add('');
    await tester.pump();

    expect(
      find.descendant(
          of: find.bySemanticsLabel('Senha'), matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('Should enable button if form is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController?.add(true);
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Should disable button if form is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController?.add(false);
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, null);
  });

  testWidgets('Should call authentication on form submit',
      (WidgetTester tester) async {
    await loadPage(tester);

    //emite true para o botão para habilitá-lo
    isFormValidController?.add(true);
    await tester.pump();
    //clico no botão
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    //verifica se ao clicar no botão a função de autenticação é chamada apenas 1 vez
    verify(presenter?.auth()).called(1);
  });

  testWidgets('Should present loading', (WidgetTester tester) async {
    await loadPage(tester);

    //emite true para habilitar o loading
    isLoadingController?.add(true);
    await tester.pump();

    //espera encontrar um widget CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should hide loading', (WidgetTester tester) async {
    await loadPage(tester);

    //emite true e false para habilitar e desabilitar o loading
    isLoadingController?.add(true);
    await tester.pump();
    isLoadingController?.add(false);
    await tester.pump();

    //espera encontrar um widget CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Should present error messageif authentication fails',
      (WidgetTester tester) async {
    await loadPage(tester);

    //emite erro para quando a autenticação falha
    mainErrorController?.add('main error');
    await tester.pump();

    //espera encontrar um widget que contenha a mesma mensagem de erro emitida na stream
    expect(find.text('main error'), findsOneWidget);
  });

  testWidgets('Should close streams on dispose', (WidgetTester tester) async {
    await loadPage(tester);

    //garante que o código seja executado antes da view ser destruída
    addTearDown(() {
      verify(presenter?.dispose()).called(1);
    });
  });
}
