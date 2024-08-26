import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final TabController tabController;
  NavigationBloc({
    required this.tabController,
  }) : super(NavigationState(
          tabController: tabController,
          index: 0,
        )) {
    on<NavigateTo>(_onNavigateTo);
  }
  _onNavigateTo(NavigateTo event, Emitter emit) {
    tabController.animateTo(event.index);
    emit(state.copyWith(
      index: event.index,
      bankName: event.bankName,
      bankRate: event.bankRate,
      moneyAmount: event.moneyAmount,
    ));
    log(state.moneyAmount.toString());
  }
}
