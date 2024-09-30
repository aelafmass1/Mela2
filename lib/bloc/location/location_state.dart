// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'location_bloc.dart';

class LocationState {
  final String? countryCode;

  LocationState({this.countryCode});

  LocationState copyWith({
    String? countryCode,
  }) {
    return LocationState(
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
