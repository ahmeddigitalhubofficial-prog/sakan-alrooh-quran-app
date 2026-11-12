import '../helpers/cache_helper.dart';

class StartupHelper {
  static Future<void> initialize() async {
    await CacheHelper.init();
  }
}
