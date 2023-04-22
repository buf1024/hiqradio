import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  final String logLevel;
  final String logPath;
  final String dataSource;
  final String dataUri;

  final bool loadPyStrategy;
  final List<String> strategyPath;

  const AppConfig(
      {this.logLevel = 'info',
      this.logPath = './logs',
      this.dataSource = 'mongodb',
      this.dataUri = 'mongodb://localhost:27017',
      this.loadPyStrategy = true,
      this.strategyPath = const ['./strategy']});

  AppConfig copyWith(
      {String? logLevel,
      String? logPath,
      String? dataSource,
      String? dataUri,
      bool? loadPyStrategy,
      List<String>? strategyPath}) {
    return AppConfig(
        logLevel: logLevel ?? this.logLevel,
        logPath: logPath ?? this.logPath,
        dataSource: dataSource ?? this.dataSource,
        dataUri: dataUri ?? this.dataUri,
        loadPyStrategy: loadPyStrategy ?? this.loadPyStrategy,
        strategyPath: strategyPath ?? this.strategyPath);
  }

  @override
  List<Object?> get props =>
      [logLevel, logPath, dataSource, dataUri, loadPyStrategy, strategyPath];
}
