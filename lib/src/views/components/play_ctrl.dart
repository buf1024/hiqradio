import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';

class PlayCtrl extends StatefulWidget {
  const PlayCtrl({super.key});

  @override
  State<PlayCtrl> createState() => _PlayCtrlState();
}

class _PlayCtrlState extends State<PlayCtrl> {
  int tick = 0;

  Station? recordStation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    bool isFavStation =
        context.select<AppCubit, bool>((value) => value.state.isFavStation);

    return Container(
      width: 280.0,
      height: 54.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //   child: InkClick(
          //     child: Icon(IconFont.timer,
          //         size: 20.0, color: Colors.white.withOpacity(0.8)),
          //     onTap: () {},
          //   ),
          // ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Icon(
                isFavStation ? IconFont.favoriteFill : IconFont.favorite,
                size: 20.0,
                color: isFavStation
                    ? const Color(0XFFEA3E3C)
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              onTap: () {
                if (playingStation != null) {
                  if (!isFavStation) {
                    context
                        .read<FavoriteCubit>()
                        .addFavorite(null, playingStation);
                  } else {
                    context.read<FavoriteCubit>().delFavorite(playingStation);
                  }
                  context.read<AppCubit>().switchFavPlayingStation();
                }
              },
            ),
          ),
          // const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkClick(
              child: const Icon(
                IconFont.previous,
                size: 20.0,
                color: Color(0XFFEA3E3C),
              ),
              onTap: () async {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  if (playingStation != null) {
                    context
                        .read<RecentlyCubit>()
                        .updateRecently(playingStation);
                  }
                }
                Station? station =
                    await context.read<AppCubit>().getPrevStation();
                if (station != null) {
                  context.read<AppCubit>().play(station);
                  context.read<RecentlyCubit>().addRecently(station);
                }
              },
            ),
          ),
          InkClick(
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: const Color(0XFFEA3E3C),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      children: [
                        // 不能完全居中
                        SizedBox(
                          width: !isPlaying ? 18.0 : 15.0,
                        ),
                        Icon(
                          !isPlaying ? IconFont.play : IconFont.stop,
                          size: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  if (isBuffering)
                    Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                ],
              ),
            ),
            onTap: () async {
              if (isPlaying) {
                context.read<AppCubit>().stop();
                if (playingStation != null) {
                  context.read<RecentlyCubit>().updateRecently(playingStation);
                }
              } else {
                Station? station = playingStation;
                station ??= await context.read<AppCubit>().getRandomStation();
                if (station != null) {
                  context.read<AppCubit>().play(station);
                  context.read<RecentlyCubit>().addRecently(station);
                }
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkClick(
              child: const Icon(
                IconFont.next,
                size: 20.0,
                color: Color(0XFFEA3E3C),
              ),
              onTap: () async {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  if (playingStation != null) {
                    context
                        .read<RecentlyCubit>()
                        .updateRecently(playingStation);
                  }
                }
                Station? station =
                    await context.read<AppCubit>().getNextStation();
                if (station != null) {
                  context.read<AppCubit>().play(station);
                  context.read<RecentlyCubit>().addRecently(station);
                }
              },
            ),
          ),
          // const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Icon(
                IconFont.record,
                size: 20.0,
                color: tick.isEven
                    ? const Color(0XFFEA3E3C)
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              onTap: () async {},
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
