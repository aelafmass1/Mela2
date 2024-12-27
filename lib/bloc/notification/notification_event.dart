part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

final class SaveFCMToken extends NotificationEvent {
  final String fcmToken;

  const SaveFCMToken({required this.fcmToken});
}

final class DeleteFCMToken extends NotificationEvent {
  final String fcmToken;

  const DeleteFCMToken({required this.fcmToken});
}

final class FetchNotifications extends NotificationEvent {}
