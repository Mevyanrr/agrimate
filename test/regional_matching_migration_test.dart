import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/202609070005_create_regional_matching.sql',
    ).readAsStringSync();
  });

  test(
    'matching enforces province, commodity, period and remaining quantity',
    () {
      expect(sql, contains('sf.commodity_id = v_demand.commodity_id'));
      expect(sql, contains('normalize_province(sf.province)'));
      expect(sql, contains('normalize_province(v_demand.province)'));
      expect(sql, contains('sf.remaining_quantity > 0'));
      expect(
        sql,
        contains('sf.harvest_start_date <= v_demand.needed_end_date'),
      );
      expect(
        sql,
        contains('sf.harvest_end_date >= v_demand.needed_start_date'),
      );
    },
  );

  test('matching keeps partial allocation and concurrency safeguards', () {
    expect(sql, contains('least(v_needed, v_supply.remaining_quantity)'));
    expect(sql, contains('least(v_available, v_demand.remaining_quantity)'));
    expect(sql, contains('for update of sf skip locked'));
    expect(sql, contains('for update of df skip locked'));
    expect(sql, contains('matches_supply_demand_unique_idx'));
  });

  test('price lookup is province-first with national-only fallback', () {
    expect(sql, contains("cp.region_level = 'PROVINCE'"));
    expect(
      sql,
      contains("cp.region_level = 'NATIONAL' and cp.province is null"),
    );
    expect(sql, contains("cp.source = 'BAPANAS'"));
    expect(
      sql,
      contains("case when cp.region_level = 'PROVINCE' then 0 else 1 end"),
    );
  });

  test('match and transaction use immutable price snapshot fields', () {
    for (final field in [
      'reference_price',
      'price_source',
      'price_source_date',
      'price_region_level',
      'price_province',
    ]) {
      expect(sql, contains(field));
    }
    expect(sql, contains('v_match.reference_price'));
    expect(
      sql,
      isNot(
        contains(
          'get_reference_price(v_supply.commodity_id, v_supply.province);\n+  v_subtotal',
        ),
      ),
    );
  });

  test('reject restoration is idempotent and bounded', () {
    expect(
      sql,
      contains("if v_match.status = 'REJECTED' then return 'REJECTED'"),
    );
    expect(
      sql,
      contains(
        'least(quantity, remaining_quantity + v_match.matched_quantity)',
      ),
    );
  });
}
