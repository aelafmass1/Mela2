import 'package:flutter_bloc/flutter_bloc.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  PinBloc() : super(PinInitial()) {
    on<ValidatePin>(_onValidatePin);
  }
  _onValidatePin(ValidatePin event, Emitter emit) async {
    //
  }
}
