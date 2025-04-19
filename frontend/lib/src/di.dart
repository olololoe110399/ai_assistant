import 'package:get_it/get_it.dart';
import 'config.dart';
import 'application/gemini_handler.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<GeminiConfig>(const GeminiConfig());
  locator.registerLazySingleton<GeminiHandler>(
    () => GeminiHandler(config: locator<GeminiConfig>()),
  );
}
