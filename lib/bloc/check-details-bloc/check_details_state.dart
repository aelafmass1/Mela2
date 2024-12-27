part of 'check_details_bloc.dart';

sealed class CheckDetailsState extends Equatable {
  const CheckDetailsState();

  @override
  List<Object> get props => [];
}

final class CheckDetailsInitial extends CheckDetailsState {}

final class CheckDetailsLoading extends CheckDetailsState {}

final class CheckDetailsError extends CheckDetailsState {
  final String message;

  const CheckDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

final class CheckDetailsLoaded extends CheckDetailsState {
  final List<TransferFeesModel> fees;

  const CheckDetailsLoaded({required this.fees});

  @override
  List<Object> get props => [fees];
}
