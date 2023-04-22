part of 'config_form_bloc.dart';

abstract class ConfigFormEvent extends Equatable {
  const ConfigFormEvent();

  @override
  List<Object> get props => [];
}

abstract class ConfigFormLoadingEvent extends ConfigFormEvent {
  final bool loading;
  const ConfigFormLoadingEvent({required this.loading});

  @override
  List<Object> get props => [loading];
}
class LogPathLoading extends ConfigFormLoadingEvent {
  const LogPathLoading({required super.loading});
}
class LogPathChanged extends ConfigFormEvent {
  final String logPath;
  const LogPathChanged({required this.logPath});

  @override
  List<Object> get props => [logPath];
}

class LogLevelChanged extends ConfigFormEvent {
  final String logLevel;
  const LogLevelChanged({required this.logLevel});

  @override
  List<Object> get props => [logLevel];
}

class DataSourceChanged extends ConfigFormEvent {
  final String dataSource;
  const DataSourceChanged({required this.dataSource});

  @override
  List<Object> get props => [dataSource];
}

class DataUriLoading extends ConfigFormLoadingEvent {
  const DataUriLoading({required super.loading});
}
class DataUriChanged extends ConfigFormEvent {
  final String dataUri;
  const DataUriChanged({required this.dataUri});

  @override
  List<Object> get props => [dataUri];
}

class LoadPyStrategyChanged extends ConfigFormEvent {
  final bool loadPyStrategy;
  const LoadPyStrategyChanged({required this.loadPyStrategy});

  @override
  List<Object> get props => [loadPyStrategy];
}

class StrategyPathLoading extends ConfigFormEvent {
  final bool loading;
  final int index;
  const StrategyPathLoading({required this.index, required this.loading});

  @override
  List<Object> get props => [index, loading];
}

class StrategyPathChanged extends ConfigFormEvent {
  final String path;
  final int index;
  const StrategyPathChanged({required this.path, required this.index});

  @override
  List<Object> get props => [path, index];
}

class StrategyPathAdded extends ConfigFormEvent {}
class StrategyPathRemoved extends ConfigFormEvent {}

class ConfigFormSubmitting extends ConfigFormEvent {}
class ConfigFormSubmitted extends ConfigFormEvent {}
