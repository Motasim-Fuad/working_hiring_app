import 'package:flutter_test/flutter_test.dart';
import 'package:working_hiring/app/data/models/order_model.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('providerName is the company name, never the personal name', () {
      final order = OrderModel.fromJson({
        'id': 1,
        'provider': {
          'id': 3,
          'company_name': 'Acme Ltd',
          'full_name': 'John Doe',
          'username': 'john',
        },
      });

      expect(order.provider, 3);
      expect(order.providerName, 'Acme Ltd');
    });

    test('providerName is null when provider has no company name', () {
      final order = OrderModel.fromJson({
        'id': 1,
        'provider': {'id': 3, 'full_name': 'John Doe'},
      });

      expect(order.providerName, isNull);
    });

    test('customerName prefers full_name', () {
      final order = OrderModel.fromJson({
        'id': 1,
        'customer': {'id': 4, 'full_name': 'Ann Lee', 'first_name': 'Ann'},
      });

      expect(order.customer, 4);
      expect(order.customerName, 'Ann Lee');
    });

    test('parses numeric strings for amount', () {
      final order = OrderModel.fromJson({'id': 1, 'amount': '12.50'});

      expect(order.amount, 12.5);
    });
  });
}
