import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/features/play_back/data/datasources/playback_fixture_datasource.dart';
import 'package:nasam/features/play_back/data/repositories/playback_repository_impl.dart';

import '../../../helpers/fixture_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'fixture segments replay on the requested day and keep their status',
    () async {
    final repository = PlaybackRepositoryImpl(
      PlaybackFixtureDataSource(
        bundle: DiskAssetBundle(),
        latency: Duration.zero,
      ),
    );
    final day = DateTime(2026, 3, 1);

    final result = await repository.getSegments(
      assetId: 'AST-0017',
      from: day,
      to: day.add(const Duration(days: 1)),
    );

    final segments = result.getOrElse(() => throw StateError('no segments'));
    expect(segments, hasLength(6));
      expect(
        segments.every(
          (segment) =>
              segment.startedAt.year == day.year &&
              segment.startedAt.month == day.month &&
              segment.startedAt.day == day.day,
        ),
        isTrue,
      );
      expect(
        segments.every((segment) => segment.status == 'قيد الانتظار'),
        isTrue,
      );
    },
  );
}
