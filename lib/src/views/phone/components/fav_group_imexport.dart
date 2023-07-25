import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

class FavGroupImexport extends StatefulWidget {
  const FavGroupImexport({super.key});

  @override
  State<FavGroupImexport> createState() => _FavGroupImexportState();
}

class _FavGroupImexportState extends State<FavGroupImexport> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkClick(
                child: const SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: Icon(
                    Icons.close_rounded,
                    size: 25,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              InkClick(
                child: const SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: Icon(
                    Icons.done_outlined,
                    size: 25,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MaterialButton(
                color: Theme.of(context).cardColor.withOpacity(0.8),
                onPressed: () async {
                  String? selectedDirectory =
                      await FilePicker.platform.getDirectoryPath();

                  if (selectedDirectory != null) {
                    String fileName =
                        'Export-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}.json';
                    String outFileName =
                        '$selectedDirectory${Platform.pathSeparator}$fileName';

                    String jsStr =
                        await context.read<FavoriteCubit>().exportFavJson();
                    if (await Permission.manageExternalStorage
                        .request()
                        .isGranted) {
                      File output = File(outFileName);
                      if (!await output.exists()) {
                        await output.create(recursive: true);
                      }

                      await output.writeAsString(jsStr);

                      showToast(
                          '${AppLocalizations.of(context).mine_export_msg}  $outFileName',
                          position: const ToastPosition(
                            align: Alignment.bottomCenter,
                          ),
                          duration: const Duration(seconds: 5));
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  AppLocalizations.of(context).cmm_export,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              MaterialButton(
                color: Colors.red.withOpacity(0.8),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    String jsStr = await file.readAsString();
                    List<dynamic> jsObj = jsonDecode(jsStr);
                    await context.read<FavoriteCubit>().importFavJson(jsObj);

                    showToast(AppLocalizations.of(context).mine_import_msg,
                        position: const ToastPosition(
                          align: Alignment.bottomCenter,
                        ),
                        duration: const Duration(seconds: 5));
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context).cmm_import,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SizedBox(
                width: 15.0,
              )
            ],
          ),
        ],
      ),
    );
  }
}
