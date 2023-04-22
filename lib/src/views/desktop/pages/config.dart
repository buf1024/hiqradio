import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/config_form/config_form_bloc.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  late TextEditingController _logPathController;
  late TextEditingController _dataUriController;
  late List<TextEditingController> _strategyControllerList;

  @override
  void initState() {
    super.initState();
    final state = context.read<ConfigFormBloc>().state;
    _logPathController = TextEditingController(text: state.logPath.text);
    _dataUriController = TextEditingController(text: state.dataUri.text);
    _strategyControllerList = state.strategyPath
        .map((e) => TextEditingController(text: e.text))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
    _logPathController.dispose();
    _dataUriController.dispose();
    for (var controller in _strategyControllerList) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ConfigFormBloc>();
    return SingleChildScrollView(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paddingWidget(_buildCommon()),
          _paddingWidget(_buildStrategy()),
          _paddingWidget(_buildSubmit()),
        ],
      ),
    ));
  }

  Widget _paddingWidget(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      child: child,
    );
  }

  Widget _buildCommon() {
    final bloc = context.read<ConfigFormBloc>();
    final state = bloc.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader('通用'),
        const SizedBox(
          height: 10.0,
        ),
        _buildTextInputField(
            labelText: '日志路径：',
            hitText: '日志路径',
            controller: _logPathController,
            onChanged: (value) {
              bloc.add(LogPathChanged(logPath: value));
            },
            onPressed: () async {
              if (!state.logPath.loading) {
                bloc.add(const LogPathLoading(loading: true));
                // String? path = await FilePicker.platform.getDirectoryPath();

                // if (path != null) {
                //   _logPathController.text = path;
                //   bloc.add(LogPathChanged(logPath: path));
                // }
                bloc.add(const LogPathLoading(loading: false));
              }
            },
            buttonText: state.logPath.loading ? null : '选择',
            errorText: state.logPath.error),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('日志级别：'),
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<String>(
                    items: const [
                      DropdownMenuItem<String>(
                          value: 'off', child: Text('off')),
                      DropdownMenuItem<String>(
                          value: 'error', child: Text('error')),
                      DropdownMenuItem<String>(
                          value: 'warn', child: Text('warn')),
                      DropdownMenuItem<String>(
                          value: 'info', child: Text('info')),
                      DropdownMenuItem<String>(
                          value: 'debug', child: Text('debug')),
                      DropdownMenuItem<String>(
                          value: 'trace', child: Text('trace')),
                    ],
                    value: state.logLevel,
                    onChanged: (value) {
                      bloc.add(LogLevelChanged(logLevel: value!));
                    }))
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('数据源：'),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<String>(
                        items: const [
                          DropdownMenuItem<String>(
                              value: 'file', child: Text('file')),
                          DropdownMenuItem<String>(
                              value: 'mongodb', child: Text('mongodb')),
                          DropdownMenuItem<String>(
                              value: 'mysql', child: Text('mysql')),
                          DropdownMenuItem<String>(
                              value: 'clickhouse', child: Text('clickhouse')),
                        ],
                        value: state.dataSource,
                        onChanged: (value) {
                          bloc.add(DataSourceChanged(dataSource: value!));
                        })),
              ],
            ),
            _buildTextInputField(
                controller: _dataUriController,
                hitText: '连接串/路径',
                onChanged: (value) {
                  bloc.add(DataUriChanged(dataUri: value));
                },
                onPressed: () async {
                  if (!state.dataUri.loading) {
                    bloc.add(const DataUriLoading(loading: true));
                    // TODO
                    await Future.delayed(const Duration(seconds: 5));

                    bloc.add(const DataUriLoading(loading: false));
                  }
                },
                buttonText: state.dataUri.loading ? null : '测试',
                errorText: state.dataUri.error),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategy() {
    final bloc = context.read<ConfigFormBloc>();
    final state = bloc.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader('策略'),
        const SizedBox(
          height: 10.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('加载py策略：'),
                  ),
                ),
                Checkbox(
                    splashRadius: 0,
                    value: state.loadPyStrategy,
                    onChanged: (value) {
                      bloc.add(LoadPyStrategyChanged(loadPyStrategy: value!));
                    })
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            ...state.strategyPath.asMap().entries.map(
              (e) {
                final index = e.key;
                final elem = e.value;
                return Column(
                  children: [
                    _buildTextInputField(
                        controller: _strategyControllerList[index],
                        labelText: index != 0 ? null : '策略路径：',
                        hitText: '策略路径',
                        onChanged: (value) {
                          bloc.add(
                              StrategyPathChanged(path: value, index: index));
                        },
                        onPressed: () async {
                          // showAboutDialog(context: context);
                          
                          if (!elem.loading) {
                            bloc.add(StrategyPathLoading(
                                index: index, loading: true));

                            // String? path =
                            //     await FilePicker.platform.getDirectoryPath();

                            // if (path != null) {
                            //   _strategyControllerList[index].text = path;
                            //   bloc.add(StrategyPathChanged(
                            //       path: path, index: index));
                            // }
                            bloc.add(StrategyPathLoading(
                                index: index, loading: false));
                          }
                        },
                        buttonText: elem.loading ? null : '选择',
                        errorText: elem.error),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                );
              },
            ).toList(),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                ),
                ElevatedButton(
                    onPressed: () {
                      final ctrl = TextEditingController();
                      _strategyControllerList.add(ctrl);
                      bloc.add(StrategyPathAdded());
                    },
                    child: const Icon(Icons.add)),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (state.strategyPath.length > 1) {
                        final ctrl = _strategyControllerList
                            .removeAt(state.strategyPath.length - 1);
                        ctrl.dispose();
                        bloc.add(StrategyPathRemoved());
                      }
                    },
                    child: const Icon(Icons.remove)),
              ],
            )
          ],
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildUi() {
    return Container();
  }

  Widget _buildSubmit() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(
        height: 2,
        thickness: 2,
      ),
      Padding(
        padding: const EdgeInsets.only(right: 40.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('取消'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('重置'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {},
                child: Text('提交'),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  Widget _buildTextInputField(
      {String? labelText,
      required String hitText,
      TextEditingController? controller,
      void Function(String)? onChanged,
      void Function()? onPressed,
      String? buttonText,
      String? errorText}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 100,
              child: labelText != null
                  ? const Align(
                      alignment: Alignment.centerRight,
                      child: Text('策略路径：'),
                    )
                  : Container(),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hitText,
                ),
              ),
            )),
            ElevatedButton(
                onPressed: () {
                  onPressed?.call();
                },
                child: buttonText == null
                    ? const SizedBox(
                        height: 15.0,
                        width: 15.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.white,
                        ),
                      )
                    : Text(buttonText))
          ],
        ),
        errorText != null
            ? Row(
                children: [
                  const SizedBox(
                    width: 100,
                  ),
                  Expanded(
                      child: Wrap(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 10, left: 10),
                          child: Text(
                            errorText,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.red),
                          ))
                    ],
                  ))
                ],
              )
            : Container()
      ],
    );
  }

  Widget _buildGroupHeader(String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
        ),
        const Divider(
          height: 2,
          thickness: 2,
        ),
      ],
    );
  }
}
