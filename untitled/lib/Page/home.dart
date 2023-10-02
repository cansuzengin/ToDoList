import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Page/login.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../service/NotificationService.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  String title='';
  String description ='';
  String boolean="";
  late final uid;
  late final username;
  late final surname;
  late final email;
  late int kontrol=1;
  bool isChecked = false;
  var userSnap;

  List todos =[];
  List listTitle=[];
  TextEditingController dateinput = TextEditingController();
  TextEditingController timeinput = TextEditingController();

  final FirebaseFirestore _firestore =FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;



  void inputData() {
    final User? user = auth.currentUser!;
    uid = user?.uid;
    email=user?.email;
  }

  createTodos(){
    DocumentReference documentReference =_firestore.collection(uid).doc(description);
    Map<String,String> todos={
      "todoTitle": title,
      "todoDesc": description,
      "todoDate": dateinput.text,
      "todoHour": timeinput.text,
      "isChecked": boolean,
    };
    documentReference.set(todos).whenComplete(() =>  print("createTodos"));
  }

  deleteTodos(item){
    DocumentReference documentReference =_firestore.collection(uid).doc(item);
    documentReference.delete().whenComplete(() => print("deleteTodos"));
  }

  createArchive(){
    DocumentReference documentReferencee =_firestore.collection(email).doc(description);
    Map<String,String> archive={
      "todoTitle": title,
      "todoDesc": description,
      "todoDate": dateinput.text,
      "todoHour": timeinput.text,
      "isChecked": boolean,
    };
    documentReferencee.set(archive).whenComplete(() =>  print("createArchive"));
  }
  late String _timeString;
  deleteArchive(item){
    DocumentReference documentReference =_firestore.collection(email).doc(item);
    documentReference.delete().whenComplete(() => print("deleteArchive"));
  }

  void _getTime() {
    final String formattedDateTime =
    DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
    DateTime dt1 = DateTime.parse(formattedDateTime);
    setState(() {
    });
  }
  void initState()
  {
    super.initState();
    tz.initializeTimeZones();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());

    inputData();
    userSnap = FirebaseFirestore.instance.collection(uid).where("isChecked", isEqualTo: "false").snapshots();

    dateinput.text = "";
    timeinput.text="";
    boolean="false";

    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification!=null)
        {
          print(message.notification!.body);
          print(message.notification!.title);
        }
    });
  }
  @override
  Widget build(BuildContext context) {
  int selectedindex=0;

    return Scaffold(
      appBar: AppBar(
        title: Text("To do list"),
        backgroundColor: Colors.black45,
      ),

      body: new Container(
          margin: const EdgeInsets.only(top: 10.0, right: 5.0, left: 5.0),
          child: new Row(
          children: <Widget>[
              new Expanded(
                  child: new Column(
                    children: <Widget>[

                    new StreamBuilder<QuerySnapshot>(
                      stream: userSnap,builder: (context, snapshot) {
                      if (!snapshot.hasData) return Text('Loading...');
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index){
                            QueryDocumentSnapshot<Object?>? documentSnapshot=snapshot.data?.docs[index];

                            final String formattedDateTime =DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
                            DateTime dt1 = DateTime.parse(formattedDateTime);
                            DateTime dt2 = DateTime.parse(documentSnapshot!["todoDate"]+" "+documentSnapshot["todoHour"]);

                            Duration diff =dt2.difference(dt1);

                            if(diff.inHours==1)
                              {
                                print(diff);
                                NotificationService().showNotification(1, "Görev Saati Yaklaşıyor!", documentSnapshot["todoDesc"]);
                              }
                            return Dismissible(
                              key:Key(index.toString()),
                              child: Card(
                                  elevation: 8,
                                  margin: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child:Slidable(
                                      key: const ValueKey(0),
                                      startActionPane:ActionPane(
                                        motion: ScrollMotion(),
                                        dismissible: DismissiblePane(onDismissed: () {

                                        }),
                                        children:[
                                          SlidableAction(
                                            onPressed: (context) {
                                              title =documentSnapshot["todoTitle"];
                                              description =documentSnapshot["todoDesc"];
                                              dateinput.text=documentSnapshot["todoDate"];
                                              timeinput.text =documentSnapshot["todoHour"];
                                              boolean="true";
                                              createTodos();
                                              final snackBar=SnackBar(content: Text("Görev Tamamlandı."));
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            },
                                            label: 'Tamamlandı',
                                            backgroundColor: Colors.deepPurpleAccent,
                                          ),
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: ScrollMotion(),
                                        dismissible: DismissiblePane(onDismissed: () {

                                        }),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                                deleteTodos((documentSnapshot!=null) ? (documentSnapshot["todoDesc"]):"");
                                                deleteArchive((documentSnapshot!=null) ? (documentSnapshot["todoDesc"]):"");
                                                final snackBar=SnackBar(content: Text("Görev Silindi."));
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            },
                                            label: 'Sil',
                                            backgroundColor: Colors.deepPurpleAccent
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text((documentSnapshot!=null) ? (documentSnapshot["todoTitle"]):""),
                                        subtitle: Text((documentSnapshot!=null) ? ((documentSnapshot["todoDesc"]!=null) ? documentSnapshot["todoDesc"] : "") : ""),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                            children: [
                                            IconButton(onPressed: () {
                                              title =documentSnapshot["todoTitle"];
                                              description =documentSnapshot["todoDesc"];
                                              dateinput.text=documentSnapshot["todoDate"];
                                              timeinput.text =documentSnapshot["todoHour"];
                                              if(kontrol==1)
                                                {
                                                  createArchive();
                                                  deleteTodos((documentSnapshot!=null) ? (documentSnapshot["todoDesc"]):"");
                                                  final snackBar=SnackBar(content: Text("Görev Arşivlendi."));
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                }
                                              if(kontrol==2)
                                                {
                                                  createTodos();
                                                  deleteArchive((documentSnapshot!=null) ? (documentSnapshot["todoDesc"]):"");
                                                  final snackBar=SnackBar(content: Text("Görev Arşivden Geri Alındı."));
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                }
                                              }, icon: Icon(Icons.archive_outlined)),
                                            ],
                                        ),
                                    )
                                  )
                                ),
                              );
                            }
                          );
                        },
                      ),
                    ],
                  ),
              ),
            ],
          ),
      ),


      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Hoşgeldiniz",style: TextStyle(fontSize: 15)),
              accountEmail: Text(email,style: TextStyle(fontSize: 18),),
              decoration: BoxDecoration(
                color: Colors.black45,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Anasayfa"),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  kontrol=1;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text("Arşivler"),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  userSnap = FirebaseFirestore.instance.collection(email).snapshots();
                  kontrol=2;
                  Navigator.pop(context);
                });
              },
            ),
            ExpansionTile(
              title: Text("Başlıklar"),
              trailing: Icon(Icons.arrow_drop_down),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.fact_check_outlined),
                  title: Text("Hepsi"),
                  trailing: Icon(Icons.arrow_right),
                  onTap: (){
                    setState(() {
                      userSnap = FirebaseFirestore.instance.collection(uid).snapshots();
                      Navigator.pop(context);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.work),
                  title: Text("İş"),
                  trailing: Icon(Icons.arrow_right),
                  onTap: (){
                    setState(() {
                      userSnap = FirebaseFirestore.instance.collection(uid).where("todoTitle", isEqualTo: "is").snapshots();
                      Navigator.pop(context);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.work),
                  title: Text("Okul"),
                  trailing: Icon(Icons.arrow_right),
                  onTap: (){
                    setState(() {
                      userSnap = FirebaseFirestore.instance.collection(uid).where("todoTitle", isEqualTo: "Okul").snapshots();
                      Navigator.pop(context);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.family_restroom),
                  title: Text("Aile"),
                  trailing: Icon(Icons.arrow_right),
                  onTap: () {
                    setState(() {
                      userSnap = FirebaseFirestore.instance.collection(uid).where("todoTitle", isEqualTo: "Aile").snapshots();
                      Navigator.pop(context);
                    });
                  }
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Ev"),
                  trailing: Icon(Icons.arrow_right),
                  onTap: (){
                    setState(() {
                      userSnap = FirebaseFirestore.instance.collection(uid).where("todoTitle", isEqualTo: "Ev").snapshots();
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Çıkış"),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>MyLoginPage()));
              },
            ),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black45,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.white,
        currentIndex: selectedindex,
        onTap: (index) => setState(() {
          if(index==1)
          {
            userSnap = FirebaseFirestore.instance.collection(uid).where("isChecked", isEqualTo: "true").snapshots();
          }
          else
          {
            userSnap = FirebaseFirestore.instance.collection(uid).where("isChecked", isEqualTo: "false").snapshots();
          }
        }),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
          label: "Notlarım",

          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: "Tamamlandı"
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {

              return AlertDialog(

                title: Text("Görev Ekle"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Başlık',
                      ),
                      onChanged: (String value){
                        title =value;
                      },
                    ),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Görev',
                      ),
                      onChanged: (String value){
                        description =value;
                      },
                    ),
                    SizedBox(height: 8,),
                    TextField(
                      controller: dateinput,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Tarih',
                      ),
                      readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),

                                      lastDate: DateTime(2101)
                                  );
                                  if(pickedDate != null ){
                                    print(pickedDate);
                                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                    print(formattedDate);

                                    setState(() {
                                      dateinput.text = formattedDate;
                                    });
                                  }else{
                                    print("Tarih seçilmedi.");
                                  }
                                }
                    ),
                    SizedBox(height: 8,),
                    TextField(
                      controller: timeinput,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Saat',
                      ),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime =  await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                        );

                        if(pickedTime != null )
                        {
                          print(pickedTime.format(context));
                          DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());

                          print(parsedTime);
                          String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
                          print(formattedTime);

                          setState(() {
                            timeinput.text = formattedTime;
                          });
                        }
                        else
                        {
                          print("Saat seçilmedi.");
                        }
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  SizedBox(
                    width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                        ),
                        onPressed: (){
                          createTodos();
                          final snackBar=SnackBar(content: Text("Görev Kaydedildi."));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          if(title!="" || description!="")
                            {
                              setState(() {
                                listTitle.add(title);
                                todos.add(description);
                              });
                              title="";
                              description="";
                              Navigator.pop(context);
                            }
                        },
                        child: Text('Kaydet'),
                    ),
                  ),
                ]
              );
            }
          );
        }
      ),
    );
  }
}