import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamora_test/app_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

typedef XFileCallback = void Function(Uint8List bytes);

class CameraCrop extends StatefulWidget {
  const CameraCrop(
    this.camera, {
    Key? key,
    this.loadingWidget,
    this.cameraIcon,
  }) : super(key: key);
  final CameraDescription camera;
  final Widget? loadingWidget;
  final Widget? cameraIcon;

  @override
  State<CameraCrop> createState() => _FlutterCameraCropState();
}

class _FlutterCameraCropState extends State<CameraCrop> {
  late CameraController controller;
  BoxConstraints? cameraPreviewBox;

  // crop frame size
  final frameWidth = 300.0;
  final frameHeight = 300.0;

  @override
  void initState() {
    super.initState();
    // initialize for camera
    controller = CameraController(widget.camera, ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      log(e.toString());
      if (e.toString().contains("permission was denied.")) {
        // Open app setting to change permission
        showPermissionDialog(context);
      }
    });
    controller.setFlashMode(FlashMode.off);
  }

  void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please grant the necessary permission in app settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings(); // Open app settings
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    if (appProvider.takingPhoto && cameraPreviewBox != null) {
      final box = cameraPreviewBox!;
      takePhoto(box).then((value) async {
        await context.read<AppProvider>().cropImage(
              value,
              x: (box.maxWidth - frameWidth) ~/ 2,
              y: (box.maxHeight - frameHeight) ~/ 2,
              width: frameWidth,
              maxW: box.maxWidth,
              height: frameHeight,
              maxH: box.maxHeight,
            );
        appProvider.setTakePhoto(false);
      });
    }

    if (!controller.value.isInitialized) {
      return widget.loadingWidget ??
          Container(
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: const Align(
              alignment: Alignment.center,
              child: Text('loading camera'),
            ),
          );
    }

    return LayoutBuilder(
      builder: (context, boxConstraints) {
        cameraPreviewBox = boxConstraints;

        return Stack(
          alignment: Alignment.center,
          children: [
            CameraPreview(controller),
            // red-bordered square of size 300x300
            Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List> takePhoto(BoxConstraints boxConstraints) async {
    XFile file = await controller.takePicture();
    return file.readAsBytes();
  }
}
