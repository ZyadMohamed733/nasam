import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nasam/core/services/storage_service.dart';
import 'package:nasam/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class _MockStorageService extends Mock implements StorageService {}

void main() {
  late _MockStorageService storage;

  setUp(() {
    storage = _MockStorageService();
    when(() => storage.setOnboardingSeen()).thenAnswer((_) async {});
  });

  group('OnboardingCubit', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'starts on the first slide',
      build: () => OnboardingCubit(storage),
      verify: (cubit) {
        expect(cubit.state.pageIndex, 0);
        expect(cubit.state.isComplete, isFalse);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'tracks the slide the user swipes to',
      build: () => OnboardingCubit(storage),
      act: (cubit) => cubit
        ..onPageChanged(1)
        ..onPageChanged(2),
      expect: () => const [
        OnboardingState(pageIndex: 1),
        OnboardingState(pageIndex: 2),
      ],
    );

    // PageView reports the page on every settle, including back onto the one
    // already showing; re-emitting would rebuild the whole page for nothing.
    blocTest<OnboardingCubit, OnboardingState>(
      'ignores a repeat of the current slide',
      build: () => OnboardingCubit(storage),
      act: (cubit) => cubit
        ..onPageChanged(0)
        ..onPageChanged(1)
        ..onPageChanged(1),
      expect: () => const [OnboardingState(pageIndex: 1)],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'finishing records that the intro was seen',
      build: () => OnboardingCubit(storage),
      act: (cubit) => cubit.finish(),
      expect: () => const [OnboardingState(isComplete: true)],
      verify: (_) => verify(() => storage.setOnboardingSeen()).called(1),
    );

    // Skipping from slide one and finishing from slide three are the same
    // action, so neither may leave the flag unset.
    blocTest<OnboardingCubit, OnboardingState>(
      'skipping from the middle records it too',
      build: () => OnboardingCubit(storage),
      act: (cubit) async {
        cubit.onPageChanged(1);
        await cubit.finish();
      },
      expect: () => const [
        OnboardingState(pageIndex: 1),
        OnboardingState(pageIndex: 1, isComplete: true),
      ],
      verify: (_) => verify(() => storage.setOnboardingSeen()).called(1),
    );
  });
}
