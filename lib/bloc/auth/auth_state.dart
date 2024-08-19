part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthFail extends AuthState {
  final String reason;

  AuthFail({required this.reason});
}

final class AuthSucces extends AuthState {}
