import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'config_form_event.dart';
part 'config_form_state.dart';

class ConfigFormBloc extends Bloc<ConfigFormEvent, ConfigFormState> {
  ConfigFormBloc() : super(const ConfigFormState()) {
    on<LogPathLoading>(_onLogPathLoading);
    on<LogPathChanged>(_onLogPathChanged);
    on<LogLevelChanged>(_onLogLevelChanged);
    on<DataSourceChanged>(_onDataSourceChanged);
    on<DataUriLoading>(_onDataUriLoading);
    on<DataUriChanged>(_onDataUriChanged);
    on<LoadPyStrategyChanged>(_onLoadPyStrategyChanged);
    on<StrategyPathLoading>(_onStrategyPathLoading);
    on<StrategyPathChanged>(_onStrategyPathChanged);
    on<StrategyPathRemoved>(_onStrategyPathRemoved);
    on<StrategyPathAdded>(_onStrategyPathAdded);
  }
  void _onLogPathLoading(LogPathLoading event, Emitter<ConfigFormState> emit) {
    emit(state.copyWith(
        logPath: state.logPath.copyWith(loading: event.loading)));
  }

  void _onLogPathChanged(LogPathChanged event, Emitter<ConfigFormState> emit) {
    final error = Directory(event.logPath).existsSync()
        ? null
        : '路径: "${event.logPath}" 不存在';

    emit(state.copyWith(
        isModified: true,
        logPath: TextError(text: event.logPath, error: error)));
  }

  void _onLogLevelChanged(
      LogLevelChanged event, Emitter<ConfigFormState> emit) {
    emit(state.copyWith(isModified: true, logLevel: event.logLevel));
  }

  void _onDataSourceChanged(
      DataSourceChanged event, Emitter<ConfigFormState> emit) {
    emit(state.copyWith(isModified: true, dataSource: event.dataSource));
  }

  void _onDataUriLoading(DataUriLoading event, Emitter<ConfigFormState> emit) {
    emit(state.copyWith(
        dataUri: state.dataUri.copyWith(loading: event.loading)));
    // todo
  }

  void _onDataUriChanged(DataUriChanged event, Emitter<ConfigFormState> emit) {
    emit(state.copyWith(
        isModified: true,
        dataUri: TextError(text: event.dataUri, error: null)));
  }

  void _onLoadPyStrategyChanged(
      LoadPyStrategyChanged event, Emitter<ConfigFormState> emit) {
    emit(
        state.copyWith(isModified: true, loadPyStrategy: event.loadPyStrategy));
  }

  void _onStrategyPathLoading(
      StrategyPathLoading event, Emitter<ConfigFormState> emit) {
    final strategyPath = state.strategyPath.asMap().entries.map((e) {
      if (e.key == event.index) {
        return e.value.copyWith(loading: event.loading);
      }
      return e.value.copyWith();
    }).toList();
    emit(state.copyWith(strategyPath: strategyPath));
  }

  void _onStrategyPathChanged(
      StrategyPathChanged event, Emitter<ConfigFormState> emit) {
    final strategyPath = state.strategyPath.asMap().entries.map((e) {
      if (e.key == event.index) {
        final error = Directory(event.path).existsSync()
            ? null
            : '路径: "${event.path}" 不存在';
        return e.value.copyWith(text: event.path, error: error);
      }
      return e.value.copyWith();
    }).toList();

    emit(state.copyWith(strategyPath: strategyPath));
  }

  void _onStrategyPathRemoved(
      StrategyPathRemoved event, Emitter<ConfigFormState> emit) {
    if (state.strategyPath.length > 1) {
      final strategyPath =
          List.generate(state.strategyPath.length - 1, (index) {
        return state.strategyPath[index].copyWith();
      });
      emit(state.copyWith(strategyPath: strategyPath));
    }
  }

  void _onStrategyPathAdded(
      StrategyPathAdded event, Emitter<ConfigFormState> emit) {
    var strategyPath = List.generate(state.strategyPath.length, (index) {
      return state.strategyPath[index].copyWith();
    });
    strategyPath.add(const TextError(text: ''));
    emit(state.copyWith(strategyPath: strategyPath));
  }
}
