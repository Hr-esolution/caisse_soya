import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/desktop_category_controller.dart';
import '../widgets/category_card.dart';
import '../widgets/glass_morphism_container.dart';
import '../widgets/custom_button.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DesktopCategoryController categoryController = Get.find();

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
                      hintText: 'Search categories...',
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
                  await categoryController.importCategoriesFromBackend();
                  Get.snackbar('Import', 'Categories imported successfully');
                },
                width: 100,
                icon: Icons.download,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (categoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (categoryController.categories.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                );
              }
              
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: categoryController.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryController.categories[index];
                  return CategoryCard(
                    category: category,
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