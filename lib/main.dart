import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/app_ja_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/my_station_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/views/my_app.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const OKToast(
      child: BlocWrap(
        child: MyApp(),
      ),
    ),
  );
}

class BlocWrap extends StatelessWidget {
  final Widget child;
  const BlocWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<AppCubit>(create: (_) => AppJACubit()),
      BlocProvider<MyStationCubit>(
        create: (_) => MyStationCubit(),
      ),
      BlocProvider<FavoriteCubit>(
        create: (_) => FavoriteCubit(),
      ),
      BlocProvider<RecentlyCubit>(
        create: (_) => RecentlyCubit(),
      ),
      BlocProvider<SearchCubit>(
        create: (_) => SearchCubit(),
      ),
      BlocProvider<RecordCubit>(
        create: (_) => RecordCubit(),
      ),
    ], child: child);
  }
}
