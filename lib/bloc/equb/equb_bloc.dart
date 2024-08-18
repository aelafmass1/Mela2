import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';

part 'equb_event.dart';
part 'equb_state.dart';

class EqubBloc extends Bloc<EqubEvent, EqubState> {
  EqubBloc()
      : super(EqubState(
          equbList: [],
        )) {
    on<AddEqub>(_onAddEqub);
  }

  _onAddEqub(AddEqub event, Emitter emit) {
    List<EqubModel> equbs = state.equbList;
    equbs.add(event.equbModel);
    emit(state.copyWith(
      equbList: equbs,
    ));
  }
}
