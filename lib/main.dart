import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

const String kRecipesBox = 'recipes_box';
const String kShoppingBox = 'shopping_box';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Hive init ────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox<String>(kRecipesBox);
  await Hive.openBox<String>(kShoppingBox);

  runApp(const ProviderScope(child: MatreceptApp()));
}
