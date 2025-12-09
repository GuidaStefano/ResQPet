import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class FirestoreAdapter<T> {
  T fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  );

  Map<String, dynamic> toFirestore(T data);
}