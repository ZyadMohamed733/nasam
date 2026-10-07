import 'package:get_it/get_it.dart';

import '../data/datasources/fake_history_datasource.dart';
import '../data/datasources/history_alert_datasource.dart';
import '../data/repositories/history_repo_impl.dart';
import '../domain/repositories/history_alert_repository.dart';
import '../domain/usecase/get_history_details_usecase.dart';
import '../domain/usecase/get_history_usecase.dart';
import '../presentation/cubit/histroy_alert_cubit.dart';

void registerHistoryAlertDependencies(GetIt getIt) {
  getIt.registerLazySingleton<HistoryAlertDataSource>(
    () => FakeHistoryDatasource(),
  );
  getIt.registerLazySingleton<HistoryAlertRepository>(
    () => HistoryRepoImpl(dataSource: getIt<HistoryAlertDataSource>()),
  );
  getIt.registerLazySingleton<GetHistoryDetailsUseCase>(
    () => GetHistoryDetailsUseCase(getIt<HistoryAlertRepository>()),
  );
  getIt.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(getIt<HistoryAlertRepository>()),
  );
  getIt.registerFactory<HistoryAlertCubit>(
    () => HistoryAlertCubit(
      getIt<GetHistoryUseCase>(),
      getIt<GetHistoryDetailsUseCase>(),
    ),
  );
}
