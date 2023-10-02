import 'package:firebase_messaging/firebase_messaging.dart';

class messaging_service{
  final FirebaseMessaging _firebaseMessaging=FirebaseMessaging.instance;
  MessagingService()
  {
    _firebaseMessaging.getToken().then((value) => print(value));
    FirebaseMessaging.onMessage.listen((message) {
      print(message);

    });
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  }
  Future<void> backgroundHandler(RemoteMessage message) async{
    print(message.data.toString());
    print(message.notification!.title);

  }


}