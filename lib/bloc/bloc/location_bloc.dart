import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/get_country_code.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc()
      : super(LocationState(
          countryCode: null,
        )) {
    on<GetLocation>(_onGetLocation);
  }
  _onGetLocation(GetLocation event, Emitter emit) async {
    final countryCode = await getUserCountryCode();
    emit(state.copyWith(countryCode: countryCode));
  }
}
