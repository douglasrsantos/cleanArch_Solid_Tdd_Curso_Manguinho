import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'stream_login_presenter_test.mocks.dart';

abstract class Validation {
  String? validate({required String field, required String value});
}

class StreamLoginPresenter {
  final Validation validation;

  StreamLoginPresenter({required this.validation});

  void validateEmail(String email) {
    validation.validate(field: 'email', value: email);
  }
}

@GenerateNiceMocks([MockSpec<Validation>()])
void main() {
  test('Should call validation with correct email', () {
    final validation = MockValidation();
    final sut = StreamLoginPresenter(validation: validation);
    final email = faker.internet.email();

    sut.validateEmail(email);

    verify(validation.validate(field: 'email', value: email)).called(1);
  });
}
