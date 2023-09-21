import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamora_test/app_provider.dart';
import 'package:kamora_test/capture_image_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    final provider = context.read<AppProvider>();
    getCounter(provider);
    super.initState();
  }

  getCounter(AppProvider provider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    provider.setPhotoCount(prefs.getInt('cropped_image_count') ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(context.watch<AppProvider>().photoCount.toString()),
      ),
      body: const Center(child: CaptureImageView()),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<AppProvider>().setTakePhoto(true);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.camera,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
