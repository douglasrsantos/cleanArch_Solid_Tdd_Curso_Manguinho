import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'package:fordev/domain/helpers/helpers.dart';
import 'package:fordev/domain/entities/entities.dart';
import 'package:fordev/domain/usecases/usecases.dart';

import 'package:fordev/presentation/presenters/presenters.dart';
import 'package:fordev/presentation/protocols/protocols.dart';

import 'stream_login_presenter_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Validation>()])
@GenerateNiceMocks([MockSpec<Authentication>()])
void main() {
  late StreamLoginPresenter sut;
  late MockValidation validation;
  late MockAuthentication authentication;
  String? email;
  String? password;

  PostExpectation mockValidationCall(String? field) => when(validation.validate(
      field: field ?? anyNamed('field'), value: anyNamed('value')));

  void mockValidation({String? field, String? value}) {
    mockValidationCall(field).thenReturn(value);
  }

  PostExpectation mockAuthenticationCall() => when(authentication.auth(any));

  void mockAuthentication() {
    mockAuthenticationCall()
        .thenAnswer((_) async => AccountEntity(faker.guid.guid()));
  }

  void mockAuthenticationError(DomainError error) {
    mockAuthenticationCall().thenThrow(error);
  }

  setUp(() {
    validation = MockValidation();
    authentication = MockAuthentication();
    sut = StreamLoginPresenter(
        validation: validation, authentication: authentication);
    email = faker.internet.email();
    password = faker.internet.password();
    mockValidation();
    mockAuthentication();
  });

  test('Should call validation with correct email', () {
    sut.validateEmail(email!);

    verify(validation.validate(field: 'email', value: email)).called(1);
  });

  test('Should emit email error if validation fails', () {
    //TESTANDO STREAM
    //mocka o erro que será exibido na função
    mockValidation(value: 'error');

    //Toda vez que a stream mudar captura o erro
    sut.emailErrorStream?.listen(
      //expectAsync: só vai passar se a condição for verdade e se executar apenas 1 vez
      expectAsync1((error) => expect(error, 'error')),
    );
    sut.isFormValidStream?.listen(
      //expectAsync: só vai passar se a condição for verdade e se executar apenas 1 vez
      expectAsync1((isValid) => expect(isValid, false)),
    );

    //executa a função
    sut.validateEmail(email!);
    sut.validateEmail(email!);
  });

  test('Should emit null if validation succeeds', () {
    //Toda vez que a stream mudar captura o erro
    sut.emailErrorStream?.listen(
      //expectAsync: só vai passar se a condição for verdade e se executar apenas 1 vez
      expectAsync1((error) => expect(error, null)),
    );
    sut.isFormValidStream?.listen(
      //expectAsync: só vai passar se a condição for verdade e se executar apenas 1 vez
      expectAsync1((isValid) => expect(isValid, false)),
    );

    //executa a função
    sut.validateEmail(email!);
    sut.validateEmail(email!);
  });

  test('Should call validation with correct password', () {
    sut.validatePassword(password!);

    verify(validation.validate(field: 'password', value: password)).called(1);
  });

  test('Should emit password error if validation fails', () {
    //TESTANDO STREAM
    //mocka o erro que será exibido na função
    mockValidation(value: 'error');

    //Toda vez que a stream mudar captura o erro
    sut.passwordErrorStream?.listen(
      //expectAsync: só vai passar se a condição for verdade e se executar apenas 1 vez
      expectAsync1((error) => expect(error, 'error')),
    );
    sut.isFormValidStream?.listen(
      //expectAsync: só vai passar se a condição for verdade e se executar apenas 1 vez
      expectAsync1((isValid) => expect(isValid, false)),
    );

    //executa a função
    sut.validatePassword(password!);
    sut.validatePassword(password!);
  });

  test('Should emit password error if validation fails', () {
    sut.passwordErrorStream
        ?.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        ?.listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validatePassword(password!);
    sut.validatePassword(password!);
  });

  test('Should emit password error if validation fails', () {
    mockValidation(field: 'email', value: 'error');

    sut.emailErrorStream
        ?.listen(expectAsync1((error) => expect(error, 'error')));
    sut.passwordErrorStream
        ?.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        ?.listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email!);
    sut.validatePassword(password!);
  });

  test('Should emit password error if validation fails', () async {
    sut.emailErrorStream?.listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        ?.listen(expectAsync1((error) => expect(error, null)));
    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateEmail(email!);
    await Future.delayed(Duration.zero);
    sut.validatePassword(password!);
  });

  test('Should call Authentication with correct values', () async {
    sut.validateEmail(email!);
    sut.validatePassword(password!);

    await sut.auth();

    verify(authentication
            .auth(AuthenticationParams(email: email!, secret: password!)))
        .called(1);
  });

  test('Should emit correct events on Authentication success', () async {
    sut.validateEmail(email!);
    sut.validatePassword(password!);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    await sut.auth();
  });

  test('Should emit correct events on InvalidCredentialsError', () async {
    mockAuthenticationError(DomainError.invalidCredentials);
    sut.validateEmail(email!);
    sut.validatePassword(password!);

    expectLater(sut.isLoadingStream, emits(false));
    sut.mainErrorStream?.listen(
        expectAsync1((error) => expect(error, 'Credenciais inválidas.')));

    await sut.auth();
  });

  test('Should emit correct events on UnexpectedError', () async {
    mockAuthenticationError(DomainError.unexpected);
    sut.validateEmail(email!);
    sut.validatePassword(password!);

    expectLater(sut.isLoadingStream, emits(false));
    sut.mainErrorStream?.listen(expectAsync1((error) =>
        expect(error, 'Algo errado aconteceu. Tente novamente em breve.')));

    await sut.auth();
  });

  test('Should not emit after dispose', () async {
    expectLater(sut.emailErrorStream, neverEmits(null));

    sut.dispose();
    sut.validateEmail(email!);
  });
}
