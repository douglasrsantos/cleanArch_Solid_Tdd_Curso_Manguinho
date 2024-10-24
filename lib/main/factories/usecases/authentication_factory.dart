import 'package:fordev/data/usecases/remote_authentication.dart';
import 'package:fordev/domain/usecases/authentication.dart';

Authentication makeRemoteAuthentication() {
  return RemoteAuthentication(
    httpClient: httpAdapter,
    url: url,
  );
}
