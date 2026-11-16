import 'package:flutter_bloc/flutter_bloc.dart';

import 'challenge_state.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  ChallengeCubit({int initialTask = 0})
      : super(ChallengeState(currentTask: initialTask));

  void confirmTiltReady() {
    if (state.currentTask != 1 || state.tiltReady) return;

    emit(state.copyWith(tiltReady: true));
  }

  void lockDirection(double heading) {
    if (state.currentTask != 0 || state.directionLocked) return;

    emit(state.copyWith(lockedHeading: heading));
  }

  void lockTilt(double angle) {
    if (state.currentTask != 1 || !state.tiltReady || state.tiltLocked) {
      return;
    }

    emit(state.copyWith(lockedTilt: angle));
  }

  void lockLight(double lux) {
    if (state.currentTask != 2 || state.lightLocked) return;

    emit(state.copyWith(lockedLight: lux));
  }

  void nextTask() {
    if (!state.canAdvance || state.currentTask >= 2) return;

    emit(state.copyWith(currentTask: state.currentTask + 1));
  }
}
