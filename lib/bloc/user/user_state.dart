part of 'user_bloc.dart';

sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserFail extends UserState {
  final String reason;

  UserFail({required this.reason});
}

final class UserSuccess extends UserState {
  final int userId;

  UserSuccess({required this.userId});
}
