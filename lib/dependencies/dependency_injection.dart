import 'package:get/get.dart';
import '../config/api_client.dart';
import '../config/isar_config.dart';
import '../repos/category_repo.dart';
import '../repos/product_repo.dart';
import '../repos/user_repo.dart';
import '../repos/restaurant_repo.dart';
import '../repos/order_repo.dart';
import '../repos/local_category_repo.dart';
import '../repos/local_product_repo.dart';
import '../repos/local_user_repo.dart';
import '../repos/local_restaurant_repo.dart';
import '../repos/local_order_repo.dart';
import '../services/sync_service.dart';
import '../controllers/desktop_category_controller.dart';
import '../controllers/desktop_product_controller.dart';
import '../controllers/desktop_order_controller.dart';
import '../controllers/desktop_user_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize Isar database
    await IsarConfig.initializeIsar();

    // API Client
    Get.lazyPut(() => ApiClient('https://your-laravel-api.com'));

    // Remote Repositories
    Get.lazyPut(() => CategoryRepo(apiClient: Get.find()));
    Get.lazyPut(() => ProductRepo(apiClient: Get.find()));
    Get.lazyPut(() => UserRepo(apiClient: Get.find()));
    Get.lazyPut(() => RestaurantRepo(apiClient: Get.find()));
    Get.lazyPut(() => OrderRepo(apiClient: Get.find()));

    // Local Repositories
    Get.lazyPut(() => LocalCategoryRepo());
    Get.lazyPut(() => LocalProductRepo());
    Get.lazyPut(() => LocalUserRepo());
    Get.lazyPut(() => LocalRestaurantRepo());
    Get.lazyPut(() => LocalOrderRepo());

    // Initialize local repositories with Isar instance
    Get.find<LocalCategoryRepo>().init(IsarConfig.db);
    Get.find<LocalProductRepo>().init(IsarConfig.db);
    Get.find<LocalUserRepo>().init(IsarConfig.db);
    Get.find<LocalRestaurantRepo>().init(IsarConfig.db);
    Get.find<LocalOrderRepo>().init(IsarConfig.db);

    // Services
    Get.lazyPut(() => SyncService());

    // Controllers
    Get.lazyPut(() => DesktopCategoryController());
    Get.lazyPut(() => DesktopProductController());
    Get.lazyPut(() => DesktopOrderController());
    Get.lazyPut(() => DesktopUserController());
  }
}