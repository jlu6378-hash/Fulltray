import 'package:communityplateproject2/SearchItem.dart';
import 'package:communityplateproject2/distance.dart';
import 'package:flutter/material.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;
  final List<SearchItem> results;
  final double userLat;
  final double userLng;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.results,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$query"'),
      ),
      body: results.isEmpty
          ? const Center(
              child: Text('No matching food items found nearby.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = results[index];
                final miles = (item.lat != null && item.lng != null)
                    ? calculateDistanceMiles(userLat, userLng, item.lat!, item.lng!)
                    : null;

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                item.isDonation ? 'Donation' : 'Request',
                                style: const TextStyle(fontSize: 12),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${item.type} • ${item.quantity}'),
                        const SizedBox(height: 4),
                        Text(item.address.isNotEmpty ? item.address : 'No address provided'),
                        const SizedBox(height: 6),
                        Text(
                          item.notes.isNotEmpty ? item.notes : 'No notes',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        if (miles != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.pin_drop_outlined, size: 18),
                              const SizedBox(width: 4),
                              Text('${miles.toStringAsFixed(1)} miles away'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
