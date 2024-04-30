import 'package:equatable/equatable.dart';

class FavGroup extends Equatable {
  final int? id;
  final int createTime;
  final String name;
  final String? desc;
  final int isDef;
  final int? isLogin;

  const FavGroup({
    this.id,
    required this.createTime,
    required this.name,
    required this.isDef,
    this.desc,
    this.isLogin,
  });

  factory FavGroup.fromJson(dynamic map) {
    return FavGroup(
      id: map['id'],
      createTime: map['create_time'],
      name: map['name'],
      desc: map['desc'],
      isLogin: map['is_login'],
      isDef: map['is_def'],
    );
  }

  FavGroup copyWith({
    int? id,
    int? createTime,
    String? name,
    String? desc,
    int? isDef,
    int? isLogin,
  }) {
    return FavGroup(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      isDef: isDef ?? this.isDef,
      isLogin: isLogin ?? this.isLogin,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'create_time': createTime,
      'name': name,
      'desc': desc,
      'is_def': isDef,
      'is_login': isLogin,
    };
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        createTime,
        name,
        desc,
        isDef,
      ];
}
