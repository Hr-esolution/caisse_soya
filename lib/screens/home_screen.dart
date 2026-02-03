import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/desktop_category_controller.dart';
import '../controllers/desktop_product_controller.dart';
import '../controllers/desktop_order_controller.dart';
import '../controllers/desktop_user_controller.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/glass_morphism_container.dart';
import '../widgets/custom_button.dart';
import '../screens/order_screen.dart';
import '../screens/products_screen.dart';
import '../screens/categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DesktopCategoryController categoryController = Get.find();
  final DesktopProductController productController = Get.find();
  final DesktopOrderController orderController = Get.find();
  final DesktopUserController userController = Get.find();
  
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ProductsScreen(),
    const CategoriesScreen(),
    const OrderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f3460),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'POS Desktop',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () async {
              // Trigger sync
              await Get.find<DesktopCategoryController>().syncToBackend();
              await Get.find<DesktopProductController>().syncToBackend();
              await Get.find<DesktopOrderController>().syncOrdersToBackend();
              Get.snackbar('Sync', 'Synchronization completed');
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                userController.lockSession();
                Get.offAllNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DesktopOrderController orderController = Get.find();
    final DesktopProductController productController = Get.find();
    final DesktopCategoryController categoryController = Get.find();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: GlassMorphismContainer(
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Orders',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            orderController.orders.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassMorphismContainer(
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Products',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            productController.products.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassMorphismContainer(
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Categories',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categoryController.categories.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassMorphismContainer(
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pending Sync',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 5)),
                            builder: (context, snapshot) {
                              int unsyncedCount = 0;
                              unsyncedCount += Get.find<DesktopProductController>().products.where((p) => !p.isSynced).length;
                              unsyncedCount += Get.find<DesktopCategoryController>().categories.where((c) => !c.isSynced).length;
                              unsyncedCount += Get.find<DesktopOrderController>().orders.where((o) => !o.isSynced).length;
                              
                              return Text(
                                unsyncedCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'New Order',
                    onPressed: () {
                      Get.to(const OrderScreen());
                    },
                    icon: Icons.add_shopping_cart,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Sync Data',
                    onPressed: () async {
                      await Get.find<DesktopCategoryController>().syncToBackend();
                      await Get.find<DesktopProductController>().syncToBackend();
                      await Get.find<DesktopOrderController>().syncOrdersToBackend();
                      Get.snackbar('Sync', 'Synchronization completed');
                    },
                    icon: Icons.sync,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Products
            const Text(
              'Recent Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Get.find<DesktopProductController>().products.take(5).length,
                itemBuilder: (context, index) {
                  final product = Get.find<DesktopProductController>().products[index];
                  return SizedBox(
                    width: 140,
                    child: ProductCard(
                      product: product,
                      showSyncStatus: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}