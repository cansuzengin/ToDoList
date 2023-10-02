import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async    //asenkron
  {
      var user = await _auth.signInWithEmailAndPassword(email: email, password: password);

      return user.user;
  }
  Future<User?> createPerson(String name, String surname, String email, String password) async{

      var user = await _auth.createUserWithEmailAndPassword(email: email, password: password);


      await _firestore
          .collection('person').doc(user.user?.uid).set({'userName':name,'email':email});

      return user.user;
  }
}

