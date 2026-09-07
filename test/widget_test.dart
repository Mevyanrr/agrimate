import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a Supabase transaction row into the frontend model', () {
    final transaction = TransactionModel.fromJson({
      'id': 'trx-1',
      'status': 'COMPLETED',
      'matched_quantity': 125,
      'price_per_kg': 8000,
      'total_amount': 1000000,
      'created_at': '2026-09-07T10:00:00Z',
      'commodity': {'name': 'Tomat'},
    });

    expect(transaction.id, 'trx-1');
    expect(transaction.commodityName, 'Tomat');
    expect(transaction.commodityEmoji, '🍅');
    expect(transaction.weightKg, 125);
    expect(transaction.unitPrice, 8000);
    expect(transaction.totalPrice, 1000000);
    expect(transaction.status, TransactionStatus.done);
    expect(transaction.transactionDateLabel, '7 Sep 2026');
  });
}
