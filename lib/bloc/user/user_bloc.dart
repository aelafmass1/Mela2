import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/repository/auth_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthRepository authRepository;
  UserBloc({required this.authRepository}) : super(UserInitial()) {
    on<FetchMe>(_onFetchMe);
  }

  _onFetchMe(FetchMe event, Emitter<UserState> emit) async {
    try {
      if (state is! UserLoading) {
        emit(UserLoading());
        final token = await getToken();
        final res = await authRepository.fetchMe(
          accessToken: token ?? '',
        );
        if (res.containsKey('error')) {
          return emit(UserFail(reason: res['error']));
        }
        emit(UserSuccess(userId: res['id']));
      }
    } catch (e) {
      emit(UserFail(reason: e.toString()));
    }
  }
}
