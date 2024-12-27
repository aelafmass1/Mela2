import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/notification_model.dart';
import 'package:transaction_mobile_app/data/repository/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  NotificationBloc({required this.notificationRepository})
      : super(NotificatonInitial()) {
    on<SaveFCMToken>(_onSaveFCMToken);
    on<DeleteFCMToken>(_onDeleteFCMToken);
    on<FetchNotifications>(_onFetchNotifications);
  }

  _onFetchNotifications(FetchNotifications event, Emitter emit) async {
    try {
      if (state is! FetchNotificationsLoading) {
        emit(FetchNotificationsLoading());
        final accessToken = await getToken();
        final res = await notificationRepository.fetchNotifications(
          accessToken: accessToken ?? '',
        );
        if (res.containsKey('error')) {
          return emit(FetchNotificationsFailure(reason: res['error']));
        }
        final notifications = (res['successResponse'] as List)
            .map((e) => NotificationModel.fromMap(e))
            .toList();
        emit(
          FetchNotificationsSuccess(
            notifications: notifications,
          ),
        );
      }
    } catch (e) {
      emit(FetchNotificationsFailure(reason: e.toString()));
    }
  }

  _onDeleteFCMToken(DeleteFCMToken event, Emitter emit) async {
    try {
      if (state is! DeleteFcmTokenLoading) {
        emit(DeleteFcmTokenLoading());
        final accessToken = await getToken();
        final res = await notificationRepository.deleteFcmToken(
          accessToken: accessToken ?? '',
          fcmToken: event.fcmToken,
        );
        if (res.containsKey('error')) {
          return emit(DeleteFcmTokenFailure(reason: res['error']));
        }
        emit(DeleteFcmTokenSuccess());
      }
    } catch (e) {
      emit(DeleteFcmTokenFailure(reason: e.toString()));
    }
  }

  _onSaveFCMToken(SaveFCMToken event, Emitter emit) async {
    try {
      if (state is! SaveFcmTokenLoading) {
        emit(SaveFcmTokenLoading());
        final accessToken = await getToken();
        final res = await notificationRepository.saveFcmToken(
          accessToken: accessToken ?? '',
          fcmToken: event.fcmToken,
        );
        if (res.containsKey('error')) {
          return emit(SaveFcmTokenFailure(reason: res['error']));
        }
        emit(SaveFcmTokenSuccess());
      }
    } catch (e) {
      emit(SaveFcmTokenFailure(reason: e.toString()));
    }
  }
}
