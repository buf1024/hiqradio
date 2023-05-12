import 'package:equatable/equatable.dart';

class Cache extends Equatable {
  final int? id;
  final String tab;
  final int checkTime;

  const Cache({this.id, required this.tab, required this.checkTime});

  factory Cache.fromJson(dynamic map) {
    return Cache(id: map['id'], tab: map['tab'], checkTime: map['check_time']);
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {'id': id, 'tab': tab, 'check_time': checkTime};
    return map;
  }

  Cache copyWith({int? id, String? tab, int? checkTime}) {
    return Cache(
        id: id ?? this.id,
        tab: tab ?? this.tab,
        checkTime: checkTime ?? this.checkTime);
  }

  @override
  List<Object?> get props => [id, tab, checkTime];
}
