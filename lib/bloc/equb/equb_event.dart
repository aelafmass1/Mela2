part of 'equb_bloc.dart';

sealed class EqubEvent {}

final class AddEqub extends EqubEvent {
  final EqubModel equbModel;

  AddEqub({required this.equbModel});
}

final class FetchEqubs extends EqubEvent {}
