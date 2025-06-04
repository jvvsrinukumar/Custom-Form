import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'base_list_state.dart';

class BaseListCubit extends Cubit<BaseListState> {
  BaseListCubit() : super(BaseListInitial());
}
