import 'dart:async';

import 'package:fordev/presentation/protocols/protocols.dart';

class LoginState {
  String? email;
  String? password;
  String? emailError;
  String? passwordError;
  bool get isFormValid =>
      emailError == null &&
      passwordError == null &&
      email != null &&
      password != null;
}

class StreamLoginPresenter {
  final Validation validation;
  //criado apenas um controlador para todas as streams em produção porque o StreamController utiliza muita memória
  //Utilizado broadcast porque vai ter mais de um listener ouvindo no mesmo controlador
  final _controller = StreamController<LoginState>.broadcast();

  final _state = LoginState();

//Pega apenas o emailError/passwordError/isFormValid para cada vez que ele alterar fazer uma ação
//.distinct() não deixa emitir dois valores seguidos iguais
  Stream<String?> get emailErrorStream =>
      _controller.stream.map((state) => state.emailError).distinct();
  Stream<String?> get passwordErrorStream =>
      _controller.stream.map((state) => state.passwordError).distinct();
  Stream<bool> get isFormValidStream =>
      _controller.stream.map((state) => state.isFormValid).distinct();

  StreamLoginPresenter({required this.validation});

  void _update() => _controller.add(_state);

  void validateEmail(String email) {
    _state.email = email;
    _state.emailError = validation.validate(field: 'email', value: email);
    _update();
  }

  void validatePassword(String password) {
    _state.password = password;
    _state.passwordError =
        validation.validate(field: 'password', value: password);
    _update();
  }
}
