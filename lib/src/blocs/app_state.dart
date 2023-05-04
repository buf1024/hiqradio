import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/language.dart';

class AppState extends Equatable {
  final bool isInit;

  const AppState({this.isInit = false});

  AppState copyWith({bool? isInit}) {
    return AppState(isInit: isInit ?? this.isInit);
  }

  @override
  List<Object?> get props => [isInit];
}
