import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/errors/failures.dart';
import 'package:nasam/features/tracking/domain/entities/tracked_asset.dart';
import 'package:nasam/features/tracking/domain/entities/tracking_vehicle.dart';
import 'package:nasam/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:nasam/features/tracking/domain/usecases/get_tracked_assets_usecase.dart';

class _MockRepository extends Mock implements TrackingRepository {}

void main() {
  late _MockRepository repository;
  late GetTrackedAssetsUseCase useCase;

  const asset = TrackedAsset(
    id: 'AST-0017',
    name: 'الأصل ٢',
    code: 'AST-0017',
    status: VehicleStatus.moving,
    assignedPerson: 'Aya Al-Rashidi',
    routeProgress: .62,
  );

  setUp(() {
    repository = _MockRepository();
    useCase = GetTrackedAssetsUseCase(repository);
  });

  test('passes the repository result straight through on success', () async {
    when(
      () => repository.getTrackedAssets(),
    ).thenAnswer((_) async => const Right([asset]));

    final result = await useCase();

    expect(result, const Right<Failure, List<TrackedAsset>>([asset]));
    verify(() => repository.getTrackedAssets()).called(1);
  });

  // The point of Either here: a failure is a value the caller must destructure,
  // not an exception it can forget to catch.
  test('surfaces the failure rather than throwing', () async {
    const failure = ServerFailure(message: 'unreachable');
    when(
      () => repository.getTrackedAssets(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((f) => f, (_) => null),
      isA<ServerFailure>().having((f) => f.message, 'message', 'unreachable'),
    );
  });
}
