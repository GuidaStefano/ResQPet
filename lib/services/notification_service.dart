import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  
  static const topicName = "segnalazioni";
  
  final FirebaseMessaging _firebaseMessaging;

  NotificationService(this._firebaseMessaging);

  Future<void> subscriptToTopic() async {
    await _firebaseMessaging.subscribeToTopic(topicName);
  }

  Future<void> unsubscribeFromTopic() async {
    await _firebaseMessaging.unsubscribeFromTopic(topicName);
  }
}