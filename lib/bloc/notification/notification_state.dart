part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

final class NotificatonInitial extends NotificationState {}

final class SaveFcmTokenLoading extends NotificationState {}

final class SaveFcmTokenSuccess extends NotificationState {}

final class SaveFcmTokenFailure extends NotificationState {
  final String reason;

  const SaveFcmTokenFailure({required this.reason});
}

final class DeleteFcmTokenLoading extends NotificationState {}

final class DeleteFcmTokenSuccess extends NotificationState {}

final class DeleteFcmTokenFailure extends NotificationState {
  final String reason;

  const DeleteFcmTokenFailure({required this.reason});
}

final class FetchNotificationsLoading extends NotificationState {}

final class FetchNotificationsSuccess extends NotificationState {
  final List<NotificationModel> notifications;

  const FetchNotificationsSuccess({required this.notifications});
}

final class FetchNotificationsFailure extends NotificationState {
  final String reason;

  const FetchNotificationsFailure({required this.reason});
}
