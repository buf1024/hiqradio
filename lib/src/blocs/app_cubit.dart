import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/repository/radioapi/radioapi.dart';
import 'package:hiqradio/src/utils/res_manager.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void initApp() async {
    await ResManager.instance.initRes();
    await Future.delayed(const Duration(milliseconds: 1));
    emit(state.copyWith(isInit: true));
  }


}
