import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'package:fordev/presentation/presenters/presenters.dart';
import 'package:fordev/presentation/protocols/protocols.dart';

import 'stream_login_presenter_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Validation>()])
void main() {
  late StreamLoginPresenter sut;
  late MockValidation validation;
  String? email;

  PostExpectation mockValidationCall(String? field) => when(validation.validate(
      field: field ?? anyNamed('field'), value: anyNamed('value')));

  void mockValidation({String? field, String? value}) {
    mockValidationCall(field).thenReturn(value);
  }

  setUp(() {
    validation = MockValidation();
    sut = StreamLoginPresenter(validation: validation);
    email = faker.internet.email();
    mockValidation();
  });

  test('Should call validation with correct email', () {
    sut.validateEmail(email!);

    verify(validation.validate(field: 'email', value: email)).called(1);
  });

  test('Should emit email error if validation fails', () {
    //TESTANDO STREAM
    //mocka o erro que será exibido na função
    mockValidation(value: 'error');

    //Se colocar o expect ou verify depois da função a stream jávai ter sido executada, não possibilitando assim o teste.
    //Por isso se coloca esse expect aqui antes
    expectLater(sut.emailErrorStream, emits('error'));

    //executa a função
    sut.validateEmail(email!);
  });
}
