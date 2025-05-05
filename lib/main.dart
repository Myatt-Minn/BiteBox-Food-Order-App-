import 'package:flutter/material.dart';
import 'package:foodorderapplication/screens/navigationscreen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetStorage.init();

  await Supabase.initialize(
    url: "https://dfwtzqllreogsmwmmwzy.supabase.co",
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmd3R6cWxscmVvZ3Ntd21td3p5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2NTI0ODAsImV4cCI6MjA1ODIyODQ4MH0.5-pVrOmyKxZqD02BgWYB6vEuU-TK2jJG4NRG-KjQ-H4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const NavigationScreen());
  }
}
