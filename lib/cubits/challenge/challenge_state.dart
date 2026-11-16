class ChallengeState {
  final int currentTask;
  final bool tiltReady;
  final double? lockedHeading;
  final double? lockedTilt;
  final double? lockedLight;

  const ChallengeState({
    this.currentTask = 0,
    this.tiltReady = false,
    this.lockedHeading,
    this.lockedTilt,
    this.lockedLight,
  });

  bool get directionLocked => lockedHeading != null;
  bool get tiltLocked => lockedTilt != null;
  bool get lightLocked => lockedLight != null;

  bool get canAdvance => switch (currentTask) {
        0 => directionLocked,
        1 => tiltLocked,
        2 => lightLocked,
        _ => false,
      };

  ChallengeState copyWith({
    int? currentTask,
    bool? tiltReady,
    double? lockedHeading,
    double? lockedTilt,
    double? lockedLight,
  }) {
    return ChallengeState(
      currentTask: currentTask ?? this.currentTask,
      tiltReady: tiltReady ?? this.tiltReady,
      lockedHeading: lockedHeading ?? this.lockedHeading,
      lockedTilt: lockedTilt ?? this.lockedTilt,
      lockedLight: lockedLight ?? this.lockedLight,
    );
  }
}
