import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'flutter_camera_crop.dart';

class CaptureImageView extends StatefulWidget {
  const CaptureImageView({
    Key? key,
  }) : super(key: key);

  @override
  State<CaptureImageView> createState() => _CaptureImageViewState();
}

class _CaptureImageViewState extends State<CaptureImageView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>?>(
      future: availableCameras(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Align(
              alignment: Alignment.center,
              child: Text(
                'Không thể truy cập camera',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }
          return CameraCrop(
            snapshot.data!.first,
            loadingWidget: Container(
              color: Colors.black,
              child: const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              ),
            ),
          );
        } else {
          return const Align(
            alignment: Alignment.center,
            child: Text(
              'Đang lấy camera',
              style: TextStyle(color: Colors.black),
            ),
          );
        }
      },
    );
  }
}
