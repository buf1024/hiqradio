import 'package:bloc/bloc.dart';
import 'package:hiqradio/src/models/app_config.dart';


class AppConfigCubit extends Cubit<AppConfig> {
  AppConfigCubit({required String title}) : super(const AppConfig());
}
