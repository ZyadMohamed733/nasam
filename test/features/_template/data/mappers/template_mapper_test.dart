import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/core/errors/exceptions.dart';
import 'package:nasam/features/_template/data/mappers/template_mapper.dart';
import 'package:nasam/features/_template/data/models/template_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('toEntity', () {
    test('maps a fully populated response', () {
      final entity = TemplateMapper.toEntity(Fixtures.templateModel);
      expect(entity, Fixtures.templateEntity);
    });

    // The work that justifies the mapper existing at all.
    test('parses the ISO string into a DateTime', () {
      final entity = TemplateMapper.toEntity(Fixtures.templateModel);
      expect(entity.createdAt, DateTime.utc(2026, 3, 5, 9, 30));
      expect(entity.createdAt.isUtc, isTrue);
    });

    test('gives absent server fields a default so the domain is non-null', () {
      final entity = TemplateMapper.toEntity(Fixtures.sparseTemplateModel);
      expect(entity.description, '');
      expect(entity.driverName, 'Unassigned');
      expect(entity.isActive, isFalse);
    });

    test('drops the field the domain does not care about', () {
      // row_version is present on the model and has nowhere to go on the
      // entity; that is the point.
      expect(Fixtures.templateModel.rowVersion, 7);
      expect(
        TemplateMapper.toEntity(Fixtures.templateModel),
        Fixtures.templateEntity,
      );
    });

    test('an unparseable date is a server contract violation, not a guess', () {
      const model = TemplateModel(id: 'x', title: 'x', createdAt: 'not-a-date');
      expect(
        () => TemplateMapper.toEntity(model),
        throwsA(isA<ServerException>()),
      );
    });

    test('normalises a non-UTC timestamp to UTC', () {
      const model = TemplateModel(
        id: 'x',
        title: 'x',
        createdAt: '2026-03-05T12:30:00+03:00',
      );
      expect(
        TemplateMapper.toEntity(model).createdAt,
        DateTime.utc(2026, 3, 5, 9, 30),
      );
    });
  });

  group('fromEntity', () {
    test('round-trips a populated entity', () {
      final model = TemplateMapper.fromEntity(Fixtures.templateEntity);
      expect(model.driverName, 'Yousef');
      expect(model.createdAt, '2026-03-05T09:30:00.000Z');
      expect(TemplateMapper.toEntity(model), Fixtures.templateEntity);
    });

    test('the default driver becomes null again on the wire', () {
      final entity = Fixtures.templateEntity.copyWith(driverName: 'Unassigned');
      expect(TemplateMapper.fromEntity(entity).driverName, isNull);
    });
  });

  group('fromJson', () {
    test('reads snake_case keys', () {
      final model = TemplateModel.fromJson(const {
        'id': 'template-1',
        'title': 'Fleet Unit',
        'description': 'Tracked vehicle',
        'driver_name': 'Yousef',
        'created_at': '2026-03-05T09:30:00Z',
        'is_active': true,
        'row_version': 7,
      });
      expect(model, Fixtures.templateModel);
    });

    test('tolerates a response missing every optional key', () {
      final model = TemplateModel.fromJson(const {
        'id': 'template-1',
        'title': 'Fleet Unit',
        'created_at': '2026-03-05T09:30:00Z',
      });
      expect(model, Fixtures.sparseTemplateModel);
    });
  });
}
