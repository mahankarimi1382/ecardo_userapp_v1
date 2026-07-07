import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FrontCameraCapture extends StatefulWidget {
  final String fieldName;

  const FrontCameraCapture({super.key, required this.fieldName});

  @override
  State<FrontCameraCapture> createState() => _FrontCameraCaptureState();
}

class _FrontCameraCaptureState extends State<FrontCameraCapture> {
  bool isCapturing = false;

  void onCapture(String filePath) {
    File file = File(filePath);
    Navigator.pop(Get.context!, file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photo(),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.front),
          zoom: 0.0,
        ),
        availableFilters: [],
        topActionsBuilder: (state) => AwesomeTopActions(
          state: state,
          padding: const EdgeInsets.all(8.0),
          children: [],
        ),
        bottomActionsBuilder: (state) => AwesomeBottomActions(
          state: state,
          left: Container(),
          right: Container(),
        ),
        onMediaCaptureEvent: (event) {
          switch (event.status) {
            case MediaCaptureStatus.capturing:
              setState(() => isCapturing = true);
              break;
            case MediaCaptureStatus.success:
              setState(() => isCapturing = false);
              event.captureRequest.when(
                single: (single) {
                  if (single.file != null) {
                    onCapture(single.file!.path);
                  }
                },
                multiple: (multiple) => null,
              );
              break;
            case MediaCaptureStatus.failure:
              setState(() => isCapturing = false);
              break;
          }
        },
      ),
    );
  }
}
