import 'package:cloud_firestore/cloud_firestore.dart';

class PriceHistoryEntry {
  final int lowestPrice;
  final String? lowestPriceStore;
  final DateTime recordedAt;

  const PriceHistoryEntry({
    required this.lowestPrice,
    required this.lowestPriceStore,
    required this.recordedAt,
  });

  factory PriceHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PriceHistoryEntry(
      lowestPrice: (data['lowestPrice'] as num).toInt(),
      lowestPriceStore: data['lowestPriceStore'] as String?,
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
    );
  }
}
