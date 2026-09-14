import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/storage_service.dart';

/// Which slide is showing, and whether the intro has been dismissed.
///
/// Onboarding has no data or domain layer on purpose: there is nothing to
/// fetch and nothing to model. The only state worth owning outside the widget
/// is the page index and the one side effect — recording that the intro is
/// done — which is here so it can be tested without pumping a PageView.
class OnboardingState {
  const OnboardingState({this.pageIndex = 0, this.isComplete = false});

  final int pageIndex;

  /// Set once the intro has been recorded as seen. The page listens for this
  /// rather than navigating from inside the cubit, so routing stays in the
  /// widget layer.
  final bool isComplete;

  OnboardingState copyWith({int? pageIndex, bool? isComplete}) =>
      OnboardingState(
        pageIndex: pageIndex ?? this.pageIndex,
        isComplete: isComplete ?? this.isComplete,
      );

  @override
  bool operator ==(Object other) =>
      other is OnboardingState &&
      other.pageIndex == pageIndex &&
      other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(pageIndex, isComplete);
}

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._storage) : super(const OnboardingState());

  final StorageService _storage;

  /// How many slides there are is the page's business — it owns the list — so
  /// the cubit only records which one is showing. It deliberately takes no
  /// `pageCount` constructor argument: injectable ignores Dart default values
  /// and would try to resolve an `int` from the container, which is not
  /// registered and throws when the page is built.
  void onPageChanged(int index) {
    if (index == state.pageIndex) return;
    emit(state.copyWith(pageIndex: index));
  }

  /// Records that the intro is done. Skipping and finishing the last slide
  /// both land here, so they cannot drift apart.
  Future<void> finish() async {
    await _storage.setOnboardingSeen();
    emit(state.copyWith(isComplete: true));
  }
}
