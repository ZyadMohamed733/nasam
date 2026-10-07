import 'package:get_it/get_it.dart';

import '../../../core/services/storage_service.dart';
import '../presentation/cubit/onboarding_cubit.dart';

void registerOnboardingDependencies(GetIt getIt) {
  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(getIt<StorageService>()),
  );
}
