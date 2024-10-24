import 'dart:async';

import 'package:fordev/ui/pages/pages.dart';

import 'package:fordev/domain/helpers/helpers.dart';
import 'package:fordev/domain/usecases/usecases.dart';

import 'package:fordev/presentation/protocols/protocols.dart';

class LoginState {
  String? email;
  String? password;
  String? emailError;
  String? passwordError;
  String? mainError;
  bool isLoading = false;
  bool get isFormValid =>
      emailError == null &&
      passwordError == null &&
      email != null &&
      password != null;
}

class StreamLoginPresenter implements LoginPresenter {
  final Validation validation;
  final Authentication authentication;
  //criado apenas um controlador para todas as streams em produção porque o StreamController utiliza muita memória
  //Utilizado broadcast porque vai ter mais de um listener ouvindo no mesmo controlador
  StreamController<LoginState>? _controller =
      StreamController<LoginState>.broadcast();

  final _state = LoginState();

//Pega apenas o emailError/passwordError/isFormValid para cada vez que ele alterar fazer uma ação
//.distinct() não deixa emitir dois valores seguidos iguais
  @override
  Stream<String?>? get emailErrorStream =>
      _controller?.stream.map((state) => state.emailError).distinct();
  @override
  Stream<String?>? get passwordErrorStream =>
      _controller?.stream.map((state) => state.passwordError).distinct();
  @override
  Stream<String?>? get mainErrorStream =>
      _controller?.stream.map((state) => state.mainError).distinct();
  @override
  Stream<bool>? get isFormValidStream =>
      _controller?.stream.map((state) => state.isFormValid).distinct();
  @override
  Stream<bool>? get isLoadingStream =>
      _controller?.stream.map((state) => state.isLoading).distinct();

  StreamLoginPresenter(
      {required this.validation, required this.authentication});

  void _update() => _controller?.add(_state);

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

  Future<void> auth() async {
    _state.isLoading = true;
    _update();
    try {
      await authentication.auth(
          AuthenticationParams(email: _state.email!, secret: _state.password!));
    } on DomainError catch (error) {
      _state.mainError = error.description;
    }
    _state.isLoading = false;
    _update();
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }
}
