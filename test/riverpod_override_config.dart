import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

List<Override> getRiverpodConfig() {
  return [
    firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
    firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
    firebaseStorageProvider.overrideWithValue(MockFirebaseStorage()),
  ];
}