import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/app/app.dart';
import 'package:yarn_craft_nepal/core/services/hive/hive_service.dart';
import 'package:yarn_craft_nepal/core/services/storage/token_service.dart';
import 'package:yarn_craft_nepal/core/services/storage/user_session.dart';
import 'package:yarn_craft_nepal/features/product/presentation/viewmodel/review_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await TokenService.init();
  await UserSessionService.init();
  await ReviewsNotifier.init();

  runApp(const ProviderScope(child: YarnCraftApp()));
}
