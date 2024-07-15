import 'package:flutter/material.dart';

import '../../components/components.dart';
import 'login_presenter.dart';

class LoginPage extends StatelessWidget {
  final LoginPresenter? presenter;

  const LoginPage({
    super.key,
    required this.presenter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginHeader(),
            const Headline1(text: 'LOGIN'),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                  child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      icon: Icon(
                        Icons.email,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: presenter?.validateEmail,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        icon: Icon(
                          Icons.lock,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      obscureText: true,
                      onChanged: presenter?.validatePassword,
                    ),
                  ),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text('ENTRAR'),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person),
                    label: const Text('Criar Conta'),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
