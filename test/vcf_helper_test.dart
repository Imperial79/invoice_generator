import 'package:flutter_test/flutter_test.dart';
import 'package:prime_invoice/Helper/vcf_helper.dart';
import 'package:prime_invoice/Models/Customer_Model.dart';

void main() {
  group('VcfHelper Tests', () {
    test('generateVcf correctly formats single contact', () {
      final customer = CustomerModel(
        name: 'Rajesh Sharma',
        phone: '9876543210',
        clientType: 'Customer',
      );

      final vcf = VcfHelper.generateVcf([customer]);

      expect(vcf, contains('BEGIN:VCARD\r\n'));
      expect(vcf, contains('VERSION:3.0\r\n'));
      expect(vcf, contains('FN:Rajesh Sharma\r\n'));
      expect(vcf, contains('N:;Rajesh Sharma;;;\r\n'));
      expect(vcf, contains('TEL;TYPE=CELL:9876543210\r\n'));
      expect(vcf, contains('END:VCARD\r\n'));
    });

    test('generateVcf correctly formats multiple contacts', () {
      final customers = [
        CustomerModel(name: 'Alice Johnson', phone: '9876500001'),
        CustomerModel(name: 'Bob Enterprise', phone: '9876500002', clientType: 'Business'),
      ];

      final vcf = VcfHelper.generateVcf(customers);

      expect(vcf, contains('FN:Alice Johnson\r\n'));
      expect(vcf, contains('TEL;TYPE=CELL:9876500001\r\n'));
      expect(vcf, contains('FN:Bob Enterprise\r\n'));
      expect(vcf, contains('TEL;TYPE=CELL:9876500002\r\n'));
      expect(vcf, contains('ORG:Bob Enterprise\r\n'));

      final vcardStarts = 'BEGIN:VCARD'.allMatches(vcf).length;
      final vcardEnds = 'END:VCARD'.allMatches(vcf).length;
      expect(vcardStarts, 2);
      expect(vcardEnds, 2);
    });

    test('generateVcf escapes special characters', () {
      final customer = CustomerModel(
        name: 'Doe, John; Jr.',
        phone: '+91 9876543210',
      );

      final vcf = VcfHelper.generateVcf([customer]);
      expect(vcf, contains(r'FN:Doe\, John\; Jr.'));
      expect(vcf, contains(r'N:;Doe\, John\; Jr.;;;'));
    });

    test('generateVcf handles empty contacts', () {
      final customers = [
        CustomerModel(name: '', phone: ''),
      ];

      final vcf = VcfHelper.generateVcf(customers);
      expect(vcf, isEmpty);
    });
  });
}
