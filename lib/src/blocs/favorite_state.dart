import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/station.dart';

class FavoriteState extends Equatable {
  final FavGroup? group;
  final List<FavGroup> groups;
  final bool isGroupsLoading;
  final List<Station> stations;
  final bool isLoading;

  final bool isLogin;

  const FavoriteState({
    this.group,
    this.groups = const [],
    this.isGroupsLoading = false,
    this.stations = const [],
    this.isLoading = false,
    this.isLogin = false,
  });

  FavoriteState copyWith({
    FavGroup? group,
    List<FavGroup>? groups,
    bool? isGroupsLoading,
    List<Station>? stations,
    bool? isLoading,
    bool? isLogin,
  }) {
    return FavoriteState(
      group: group ?? this.group,
      groups: groups ?? this.groups,
      isGroupsLoading: isGroupsLoading ?? this.isGroupsLoading,
      stations: stations ?? this.stations,
      isLoading: isLoading ?? this.isLoading,
      isLogin: isLogin ?? this.isLogin,
    );
  }

  @override
  List<Object?> get props =>
      [group, groups, isGroupsLoading, stations, isLoading, isLogin];
}
