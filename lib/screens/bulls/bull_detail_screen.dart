import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/bull.dart';

class BullDetailScreen extends StatelessWidget {
  final Bull bull;

  const BullDetailScreen({super.key, required this.bull});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bull Details'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bull Image
            if (bull.imageUrl != null)
              Hero(
                tag: 'bull_${bull.id}',
                child: CachedNetworkImage(
                  imageUrl: bull.imageUrl!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: AppTheme.backgroundLight,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: AppTheme.backgroundLight,
                    child: const Center(
                      child: Icon(
                        Icons.pets,
                        size: 64,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                color: AppTheme.backgroundLight,
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    size: 64,
                    color: AppTheme.textLight,
                  ),
                ),
              ),

            // Details
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bull Name
                  Text(
                    bull.name,
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Info Grid
                  if (bull.breed != null)
                    _buildInfoRow('Breed', bull.breed!),
                  if (bull.age != null)
                    _buildInfoRow('Age', '${bull.age} years'),
                  if (bull.color != null)
                    _buildInfoRow('Color', bull.color!),

                  const Divider(height: 32),

                  // Owner Info
                  const Text(
                    'Owner Information',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  if (bull.ownerName != null)
                    _buildInfoRow('Owner', bull.ownerName!),
                  if (bull.ownerVillage != null)
                    _buildInfoRow('Village', bull.ownerVillage!),

                  // Description
                  if (bull.description != null &&
                      bull.description!.isNotEmpty) ...[
                    const Divider(height: 32),
                    const Text(
                      'Description',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      bull.description!,
                      style: AppTheme.bodyMedium,
                    ),
                  ],

                  // Status
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: AppTheme.bodyMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bull.isActive
                              ? AppTheme.successGreen
                              : AppTheme.textLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bull.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
