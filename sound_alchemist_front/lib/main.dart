import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'src/vc_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(800, 580),
    // maximumSize: Size(1200, 700),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setHasShadow(true);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundAlchemist RVC Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MainWindow(),
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text('Are you sure you want to close?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  windowManager.destroy();
                },
                child: const Text('Confirm'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DragToMoveArea(
        child: Column(
          children: [
            WindowTitleBar(),
            Expanded(child: VcPanel()),
          ],
        ),
      ),
    );
  }
}

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[200],
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              alignment: Alignment.center,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.minimize, color: Colors.white),
                onPressed: () => windowManager.minimize(),
              ),
              // Remove or comment out the maximize/restore button
              // IconButton(
              //   icon: const Icon(Icons.crop_square, color: Colors.white),
              //   onPressed: () async {
              //     bool isMaximized = await windowManager.isMaximized();
              //     if (isMaximized) {
              //       windowManager.restore();
              //     } else {
              //       windowManager.maximize();
              //     }
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => windowManager.close(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
