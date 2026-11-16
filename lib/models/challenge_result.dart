import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeResult {
  final String? id;
  final String challengeDate;

  final double directionError;
  final double tiltError;
  final double lightError;

  final int totalDurationSeconds;

  final double? directionAccuracy;
  final double? tiltAccuracy;
  final double? lightAccuracy;
  final double? accuracy;

  final int? scoringVersion;
  final DateTime? completedAt;

  const ChallengeResult({
    this.id,
    required this.challengeDate,
    required this.directionError,
    required this.tiltError,
    required this.lightError,
    required this.totalDurationSeconds,
    this.directionAccuracy,
    this.tiltAccuracy,
    this.lightAccuracy,
    this.accuracy,
    this.scoringVersion,
    this.completedAt,
  });

  // Convert a completed challenge into Firestore fields.
  Map<String, dynamic> toFirestore() {
    return {
      'challengeDate': challengeDate,
      'directionError': directionError,
      'tiltError': tiltError,
      'lightError': lightError,
      'totalDurationSeconds': totalDurationSeconds,
      if (directionAccuracy != null) 'directionAccuracy': directionAccuracy,
      if (tiltAccuracy != null) 'tiltAccuracy': tiltAccuracy,
      if (lightAccuracy != null) 'lightAccuracy': lightAccuracy,
      if (accuracy != null) 'accuracy': accuracy,
      if (scoringVersion != null) 'scoringVersion': scoringVersion,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert a Firestore document back into a Dart object.
  factory ChallengeResult.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError('Challenge result does not exist.');
    }

    double number(String key) {
      final value = data[key];
      return value is num ? value.toDouble() : 0.0;
    }

    double? optionalNumber(String key) {
      final value = data[key];
      return value is num ? value.toDouble() : null;
    }

    return ChallengeResult(
      id: document.id,
      challengeDate: data['challengeDate'] as String? ?? '',
      directionError: number('directionError'),
      tiltError: number('tiltError'),
      lightError: number('lightError'),
      totalDurationSeconds:
          (data['totalDurationSeconds'] as num?)?.toInt() ?? 0,
      directionAccuracy: optionalNumber('directionAccuracy'),
      tiltAccuracy: optionalNumber('tiltAccuracy'),
      lightAccuracy: optionalNumber('lightAccuracy'),
      accuracy: optionalNumber('accuracy'),
      scoringVersion: (data['scoringVersion'] as num?)?.toInt(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
