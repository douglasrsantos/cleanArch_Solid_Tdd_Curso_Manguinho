import 'package:faker/faker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'remote_authentication_test.mocks.dart';

import 'package:fordev/domain/helpers/helpers.dart';
import 'package:fordev/domain/usecases/usecases.dart';

import 'package:fordev/data/usecases/usecases.dart';
import 'package:fordev/data/http/http.dart';

@GenerateNiceMocks([MockSpec<HttpClient>()])
void main() {
  late MockHttpClient httpClient;
  late RemoteAuthentication sut;
  late String url;
  late AuthenticationParams params;

  setUp(() {
    httpClient = MockHttpClient();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(
      httpClient: httpClient,
      url: url,
    );
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
  });

  group('Group of tests of http requests', () {
    test(
      'Should call HttpClient with correct URL',
      () async {
        await sut.auth(params);

        verify(httpClient.request(
          url: url,
          method: 'post',
          body: {
            'email': params.email,
            'password': params.secret,
          },
        ));
      },
    );

    test(
      'Should throw UnexpectedError if HttpClient returns 400',
      () async {
        when(httpClient.request(
                url: anyNamed('url'),
                method: anyNamed('method'),
                body: anyNamed('body')))
            .thenThrow(HttpError.badRequest);

        final future = sut.auth(params);

        expect(future, throwsA(DomainError.unexpected));
      },
    );

    test(
      'Should throw UnexpectedError if HttpClient returns 404',
      () async {
        when(httpClient.request(
                url: anyNamed('url'),
                method: anyNamed('method'),
                body: anyNamed('body')))
            .thenThrow(HttpError.notFound);

        final future = sut.auth(params);

        expect(future, throwsA(DomainError.unexpected));
      },
    );

    test(
      'Should throw UnexpectedError if HttpClient returns 500',
      () async {
        when(httpClient.request(
                url: anyNamed('url'),
                method: anyNamed('method'),
                body: anyNamed('body')))
            .thenThrow(HttpError.serverError);

        final future = sut.auth(params);

        expect(future, throwsA(DomainError.unexpected));
      },
    );

    test(
      'Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
        when(httpClient.request(
                url: anyNamed('url'),
                method: anyNamed('method'),
                body: anyNamed('body')))
            .thenThrow(HttpError.unauthorized);

        final future = sut.auth(params);

        expect(future, throwsA(DomainError.invalidCredentials));
      },
    );
  });
}
