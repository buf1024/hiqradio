import 'package:equatable/equatable.dart';

class Cache extends Equatable {
  final int id;
  final String table;
  final int checkTime;

  const Cache({required this.id, required this.table, required this.checkTime});

  Cache copyWith({int? id, String? table, int? checkTime}) {
    return Cache(
        id: id ?? this.id,
        table: table ?? this.table,
        checkTime: checkTime ?? this.checkTime);
  }

  @override
  List<Object?> get props => [id, table, checkTime];
}
