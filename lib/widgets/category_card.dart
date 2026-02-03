import 'package:flutter/material.dart';
import '../models/category_model.dart';
import 'glass_morphism_container.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final bool showSyncStatus;

  const CategoryCard({
    Key? key,
    required this.category,
    this.onTap,
    this.showSyncStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassMorphismContainer(
      margin: const EdgeInsets.all(8),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category image or icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: category.image != null
                      ? DecorationImage(
                          image: NetworkImage(category.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: category.image == null
                    ? const Icon(
                        Icons.category,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),
              
              const SizedBox(height: 12),
              
              // Category name
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 6),
              
              // Sync status indicator
              if (showSyncStatus)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: category.isSynced ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.isSynced ? 'Synced' : 'Pending',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}