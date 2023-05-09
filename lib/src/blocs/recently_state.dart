import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/pair.dart';

class RecentlyState extends Equatable {
  final bool isLoading;
  final List<Pair<Station, Recently>> recentlys;

  const RecentlyState({
    this.isLoading = true,
    this.recentlys = const [],
  });

  RecentlyState copyWith({
    bool? isLoading,
    List<Pair<Station, Recently>>? recentlys,
  }) {
    return RecentlyState(
      isLoading: isLoading ?? this.isLoading,
      recentlys: recentlys ?? this.recentlys,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        recentlys,
      ];
}
