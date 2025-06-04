import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化存储服务
  await StorageService.init();
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  runApp(const JusuanCloudApp());
}

class JusuanCloudApp extends StatelessWidget {
  const JusuanCloudApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '聚算云',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'TechFont',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}