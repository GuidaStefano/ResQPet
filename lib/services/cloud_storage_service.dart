import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class CloudStorageService {
  final FirebaseStorage _storage; 

  CloudStorageService(this._storage);

  Future<String> uploadFile(File file) async {

    final storageRef = _storage.ref();
    final uuid = Uuid();

    final uniquePath = "${uuid.v4()}_${file.path.split('/').last}";
    final uploadTask = storageRef.child(uniquePath)
      .putFile(file);

    await uploadTask;

    return uniquePath;
  }

  Future<void> deleteFile(String path) async {
    final deleteFileRef = _storage.ref().child(path);
    await deleteFileRef.delete();
  }

  Future<String> getDownloadURL(String path) async {
    final downloadRef = _storage.ref().child(path);

    return downloadRef.getDownloadURL();
  }
}