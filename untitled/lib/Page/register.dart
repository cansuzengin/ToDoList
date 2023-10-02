import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/service/auth.dart';
import 'login.dart';

class LogUpPage extends StatefulWidget {
  _LogUpPageState createState() => _LogUpPageState();

}
class _LogUpPageState extends State<LogUpPage>{
  String? name;
  String? surname;
  String? email;
  String? password;
  late bool _success;
  late String _userEmail;

  final TextEditingController _nameController=TextEditingController();
  final TextEditingController _surnameController=TextEditingController();
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  AuthService _authService=AuthService();
  final _formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Form(
        key: _formKey,
          child: Padding(     //Kenarları ortalar.
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.black,),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                      labelText: "Ad",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) { //TextField'daki bilgiyi value değerine atar.
                      if (value != null && value.isEmpty) {
                        return "Adınızı giriniz.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value){
                      name=value;
                    }
                ),
                SizedBox(height: 15.0,),
                TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.black,),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                      labelText: "Soyad",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) { //TextField'daki bilgiyi value değerine atar.
                      if (value != null && value.isEmpty) {
                        return "Soyadınızı giriniz.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value){
                      surname=value;
                    }
                ),
                SizedBox(height: 15.0,),
                TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail, color: Colors.black,),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                      labelText: "E-mail",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) { //TextField'daki bilgiyi value değerine atar.
                      if (value != null && value.isEmpty) {
                        return "Email giriniz.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value){
                      email=value;
                    }
                ),
                SizedBox(height: 15.0,),
                TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.black,),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                      labelText: "Şifre",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) { //TextField'daki bilgiyi value değerine atar.
                      if (value != null && value.isEmpty) {
                        return "Şifre giriniz.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value){
                      password=value;
                    }
                ),
                SizedBox(height: 20.0,),
                _LogUpButton(),
              ],
            ),
          ),
      ),
    );
  }
  Widget _LogUpButton() => RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Text("Kayıt Ol",style: TextStyle(fontSize: 15)),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          try {
          var user =await _authService.createPerson(
              _nameController.text, _surnameController.text,
              _emailController.text, _passwordController.text);

          if(user!=null)
            {
              setState(() {
                _success=true;
                _userEmail=user.email!;
              });
            }else{
            setState(() {
              _success=false;
            });
          }

          print(user);
          } on FirebaseAuthException catch (e) {
            print(e.runtimeType);
            print(e);
          }
          if(_passwordController.text.length < 6)
          {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: Text("Hata"),
                    content: Text("Şifre en az 6 karakter içermelidir"),
                    actions: [
                      MaterialButton(
                        child: Text("Tamam"),
                        onPressed: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => LogUpPage()));
                        },
                      ),
                    ],
                  );
                });
          }
          else
          {
              debugPrint("giriş başarılı");
              if(_success)
              {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Mesaj"),
                        content: Text("Kayıt Başarılı"),
                        actions: [
                          MaterialButton(
                            child: Text("Tamam"),
                            onPressed: (){
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => MyApp()));
                            },
                          ),
                        ],
                      );
                    });
              }
              else
                {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Hata"),
                          content: Text("Kayıt Tamamlanamadı"),
                          actions: [
                            MaterialButton(
                              child: Text("Tamam"),
                              onPressed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => LogUpPage()));
                              },
                            ),
                          ],
                        );
                      });
                }
            }
        }
      }

  );
}
