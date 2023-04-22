part of 'config_form_bloc.dart';

class ConfigFormState extends Equatable {
  final bool isModified;

  final TextError logPath;
  final String logLevel;
  final String dataSource;
  final TextError dataUri;

  final bool loadPyStrategy;
  final List<TextError> strategyPath;

  const ConfigFormState(
      {this.isModified = false,
      this.logPath = const TextError(text: './logs'),
      this.logLevel = 'info',
      this.dataSource = 'mongodb',
      this.dataUri = const TextError(text: 'mongodb://localhost:27017'),
      this.loadPyStrategy = true,
      this.strategyPath = const [TextError(text: './strategy'), TextError(text: './strategy')]});

  ConfigFormState copyWith(
      {bool? isModified,
      TextError? logPath,
      String? logLevel,
      String? dataSource,
      TextError? dataUri,
      bool? loadPyStrategy,
      List<TextError>? strategyPath}) {
    return ConfigFormState(
        isModified: isModified ?? this.isModified,
        logPath: logPath ?? this.logPath,
        logLevel: logLevel ?? this.logLevel,
        dataSource: dataSource ?? this.dataSource,
        dataUri: dataUri ?? this.dataUri,
        loadPyStrategy: loadPyStrategy ?? this.loadPyStrategy,
        strategyPath: strategyPath ?? this.strategyPath);
  }

  @override
  List<Object> get props =>
      [logPath, logLevel, dataSource, dataUri, loadPyStrategy, strategyPath];
}

class TextError extends Equatable {
  final String text;
  final String? error;
  final bool loading;
  const TextError({required this.text, this.error, this.loading = false});

  TextError copyWith({String? text, String? error, bool? loading}) {
    return TextError(
        text: text ?? this.text,
        error: error,
        loading: loading ?? this.loading);
  }

  @override
  List<Object?> get props => [text, error, loading];
}
