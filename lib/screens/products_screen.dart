import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/desktop_product_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/glass_morphism_container.dart';
import '../widgets/custom_button.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DesktopProductController productController = Get.find();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GlassMorphismContainer(
                  child: TextField(
                    onChanged: (value) {
                      // Handle search
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              CustomButton(
                text: 'Import',
                onPressed: () async {
                  await productController.importProductsFromBackend();
                  Get.snackbar('Import', 'Products imported successfully');
                },
                width: 100,
                icon: Icons.download,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (productController.products.isEmpty) {
                return const Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                );
              }
              
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: productController.products.length,
                itemBuilder: (context, index) {
                  final product = productController.products[index];
                  return ProductCard(
                    product: product,
                    showSyncStatus: true,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}