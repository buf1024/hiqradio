import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/pair.dart';

class RecentlyState extends Equatable {
  final bool isLoading;
  final List<Pair<Station, Recently>> recentlys;

  final int totalSize;
  final int pageSize;
  final int totalPage;
  final int page;

  // 多余
  final bool isLogin;

  const RecentlyState({
    this.isLoading = true,
    this.recentlys = const [],
    this.totalSize = 0,
    this.pageSize = kDefPageSize,
    this.totalPage = 0,
    this.page = 0,
    this.isLogin = false
  });

  RecentlyState copyWith({
    bool? isLoading,
    List<Pair<Station, Recently>>? recentlys,
    int? totalSize,
    int? pageSize,
    int? totalPage,
    int? page,
    bool? isLogin,
  }) {
    return RecentlyState(
      isLoading: isLoading ?? this.isLoading,
      recentlys: recentlys ?? this.recentlys,
      totalSize: totalSize ?? this.totalSize,
      pageSize: pageSize ?? this.pageSize,
      totalPage: totalPage ?? this.totalPage,
      page: page ?? this.page,
      isLogin: isLogin ?? this.isLogin,
    );
  }

  get pagedRecently {
    if (recentlys.isNotEmpty) {
      int start = (page - 1) * pageSize;
      int end = start + pageSize;
      if (end > recentlys.length) {
        end = recentlys.length;
      }
      if (start <= end) {
        return recentlys.getRange(start, end).toList();
      }
    }
    return const <Pair<Station, Recently>>[];
  }

  @override
  List<Object?> get props => [
        isLoading,
        recentlys,
        totalSize,
        pageSize,
        totalPage,
        page,
        isLogin,
      ];
}
