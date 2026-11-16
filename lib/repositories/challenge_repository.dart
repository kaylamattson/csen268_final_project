import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/challenge_result.dart';

class ChallengeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChallengeRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _results {
    return _firestore.collection('users').doc(_userId).collection('results');
  }

  // Save one completed Daily Challenge.
  Future<String> saveResult(ChallengeResult result) async {
    final document = await _results.add(
      result.toFirestore(),
    );

    return document.id;
  }

  // Retrieve one challenge using its document ID.
  Future<ChallengeResult?> getResult(String resultId) async {
    final document = await _results.doc(resultId).get();

    if (!document.exists) return null;

    return ChallengeResult.fromFirestore(document);
  }

  // Retrieve all saved results for the signed-in user.
  Future<List<ChallengeResult>> getResults() async {
    final snapshot =
        await _results.orderBy('completedAt', descending: true).get();

    return snapshot.docs.map(ChallengeResult.fromFirestore).toList();
  }
}
