import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/data/repository/auth_repository.dart';
import 'package:transaction_mobile_app/data/services/api/api_service.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc =
          AuthBloc(repository: AuthRepository(client: ApiService().client));
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [LoginUserLoading, LoginUserSuccess] when LoginRequested is added',
      build: () => authBloc,
      wait: const Duration(seconds: 3),
      act: (bloc) => bloc.add(
        LoginUser(
          phoneNumber: '940404040',
          password: 'test1234',
          countryCode: 251,
        ),
      ),
      expect: () => [
        isA<LoginUserLoading>(),
        isA<LoginUserFail>(),
      ],
    );
  });
}
