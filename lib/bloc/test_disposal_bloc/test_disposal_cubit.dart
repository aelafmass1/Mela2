import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'test_disposal_state.dart';

class TestDisposalCubit extends Cubit<TestDisposalState> {
  TestDisposalCubit() : super(TestDisposalInitial());
}
