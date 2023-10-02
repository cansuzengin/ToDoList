import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/Page/home.dart';
import 'package:untitled/Page/register.dart';
import 'package:untitled/service/auth.dart';
import 'package:untitled/service/NotificationService.dart';

Future<void> backgroundHandler(RemoteMessage message) async{
  print(message.data.toString());
  print(message.notification!.title);
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //Ekrandaki demo yazısını kaldırır.
      title: 'TO DO LİST',
      theme: ThemeData(

        primarySwatch: Colors.deepPurple,
      ),
      home: MyLoginPage(),
    );
  }
}

class MyLoginPage extends StatefulWidget {

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
    String? username;
    String? password;
    int _success =1;
    String _userEmail="";

    final _formKey=GlobalKey<FormState>();
    final TextEditingController _emailController=TextEditingController();
    final TextEditingController _passwordController=TextEditingController();
    AuthService _authService=AuthService();
    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      resizeToAvoidBottomInset: false,  //Çizginin kaymasını önler.

        body: Form(
        key: _formKey,   //validate, save işlemleri için
          child: Padding(     //Kenarları ortalar.

          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(      //Widget'ları alt alta dizer.
            mainAxisAlignment: MainAxisAlignment.center,  //Ortalamak için kullanılır.
            children: <Widget>[
              Image(image: AssetImage('images/todo.jpg'),width: 350,height: 200,),
              SizedBox(height: 20.0,),
            TextFormField(
              controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail, color: Colors.black,),
                  fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(   //TextField'ı kutu şeklinde gösterir.
                  borderSide: BorderSide(color: Colors.black,),  //Kutunun rengi
                  borderRadius: BorderRadius.circular(25.7),
                ),
                  labelText: "E-mail",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                validator: (value){   //TextField'daki bilgiyi value değerine atar.
                  if(value!=null && value.isEmpty) {
                    return "E-mail giriniz.";
                  } else {
                    return null;
                  }
                },
                onSaved: (value){
                    username=value;
                }
            ),
            SizedBox(height: 10.0,), //Kutular arası boşluk.
            TextFormField(
              controller: _passwordController,
                obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.black,),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(   //TextField'ı kutu şeklinde gösterir.
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(25.7),//Kutunun rengi
                ),
                labelText: "Şifre",
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              validator: (value){   //TextField'daki bilgiyi value değerine atar.
                if(value!=null && value.isEmpty) {
                  return "Şifrenizi giriniz.";
                } else {
                  return null;
                }
              },
              onSaved: (value){
                password=value;
              }
            ),
            
            Row(    //Widget'ları yan yana dizer.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                MaterialButton(
                  child: Text("üye ol"),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LogUpPage()));
                  },
                ),
              ],
            ),
            _LoginButton(),
          ],
         ),
        ),
      ),
    );
  }

   Widget _LoginButton() => RaisedButton(

       shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(18),

         ),
       child: Text("Giriş yap",style: TextStyle(fontSize: 15,),
       ),

       onPressed: () async{
         if(_formKey.currentState!.validate()) {
           _formKey.currentState!.save();

           var user;
           try{
              user = await _authService.signIn(_emailController.text, _passwordController.text);
           } on FirebaseAuthException catch (e) {
             print(e.runtimeType);
             print(e);
           }

              if(user!=null)
                {
                    _success=2;
                    _userEmail=user.email!;
                }
              else{
                _success=3;
              }

            if(_success==3)
             {
               showDialog(
                   barrierDismissible: false,
                   context: context,
                   builder: (BuildContext context){
                 return AlertDialog(
                   title: Text("Hata"),
                   content: Text("E-mail veya şifre hatalı.."),
                   actions: [
                     MaterialButton(
                       child: Text("Tamam"),
                       onPressed: ()=> Navigator.pop(context),
                     ),
                   ],
                 );
               });
             }
            else{
              debugPrint("Giriş başarılı..");
              Navigator.push(context, MaterialPageRoute(builder: (context) =>HomePage()));
            }
          }
       }
   );
}