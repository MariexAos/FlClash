import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

final _memoryStateNotifier = ValueNotifier<num>(0);

class MemoryInfo extends StatefulWidget {
  const MemoryInfo({super.key});

  @override
  State<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends State<MemoryInfo> {
  @override
  void initState() {
    super.initState();
    globalState.addTask(_updateMemory);
    _updateMemory();
  }

  @override
  void dispose() {
    globalState.removeTask(_updateMemory);
    super.dispose();
  }

  Future<void> _updateMemory() async {
    if (!mounted) return;
    final rss = ProcessInfo.currentRss;
    if (coreController.isCompleted) {
      _memoryStateNotifier.value = await coreController.getMemory() + rss;
    } else {
      _memoryStateNotifier.value = rss;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        info: Info(iconData: Icons.memory, label: appLocalizations.memoryInfo),
        onPressed: () {
          coreController.requestGc();
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: globalState.measure.bodyMediumHeight + 2,
                child: ValueListenableBuilder(
                  valueListenable: _memoryStateNotifier,
                  builder: (_, memory, _) {
                    final traffic = memory.traffic;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          traffic.value,
                          style: context.textTheme.bodyMedium?.toLight
                              .adjustSize(1),
                        ),
                        SizedBox(width: 8),
                        Text(
                          traffic.unit,
                          style: context.textTheme.bodyMedium?.toLight
                              .adjustSize(1),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
