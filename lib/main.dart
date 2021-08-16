import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TODO",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String s1;
  String s2;
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  adddata() async {
    DocumentReference docref =
        Firestore.instance.collection('TODOLIST').document('${t1.text}');
    docref.setData(
        {'title': '${t1.text}', 'description': '${t2.text}'}).whenComplete(
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t1.text} ADDED'),
        ),
      ),
    );
  }

  delete(DocumentSnapshot documentSnapshot) {
    var val = documentSnapshot['title'];
    var des = documentSnapshot['description'];
    setState(() {
      s1 = val;
      s2 = des;
      DocumentReference documentReference =
          Firestore.instance.collection('TODOLIST').document('$s1');
      documentReference.delete().whenComplete(
          () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('$val Dismissed'),
                    GestureDetector(
                        child: Text('undo'),
                        onTap: () {
                          t1.text = '$val';
                          t2.text = '$des';
                          setState(() {
                            adddata();
                          });
                        })
                  ],
                ),
              ))));
    });
  }

  update(var main, var title, var description) async {
    if (title == main) {
      Firestore.instance.collection('TODOLIST').document('$main').updateData(
          {'title': '$title', 'description': '$description'}).whenComplete(
        () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$main UPDATED'),
          ),
        ),
      );
    } else if (title != main) {
      Firestore.instance.collection('TODOLIST').document('$main').delete();
      Firestore.instance.collection('TODOLIST').document('$title').setData({
        'title': '$title',
        'description': '$description'
      }).whenComplete(() => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$main UPDATED'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: Text('TODO LIST'),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  show(context);
                }),
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('TODOLIST').snapshots(),
          builder: (context, snapshots) {
            return (snapshots.hasData)
                ? Container(
                    child: ListView.builder(
                        itemCount: snapshots.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot;
                          maketran() async {
                            documentSnapshot = snapshots.data.documents[index];
                          }

                          maketran();
                          return (documentSnapshot != null)
                              ? GestureDetector(
                                  onDoubleTap: () {
                                    show1(context, documentSnapshot['title'],
                                        documentSnapshot['description']);
                                  },
                                  child: Dismissible(
                                    key: UniqueKey(),
                                    onDismissed: (direction) {
                                      delete(documentSnapshot);
                                    },
                                    background: Container(color: Colors.red),
                                    child: Container(
                                      child: Card(
                                        elevation: 0,
                                        child: ListTile(
                                          title:
                                              Text(documentSnapshot['title']),
                                          subtitle: Text(
                                              documentSnapshot['description']),
                                          trailing: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                delete(documentSnapshot);
                                              }),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                );
                        }))
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ));
  }

  Widget show1(BuildContext context, var s1, var s2) {
    TextEditingController x1 = TextEditingController();
    TextEditingController x2 = TextEditingController();
    x1.text = s1;
    x2.text = s2;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('UPDATE TODO'),
            content: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'TITLE',
                    ),
                    controller: x1,
                  ),
                  Padding(padding: EdgeInsets.only(top: 50)),
                  TextField(
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: x2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          if (x1.text.isNotEmpty) {
                            setState(() {
                              update(s1, x1.text, x2.text);
                              x1.text = "";
                              x2.text = "";
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Text("Submit"),
                      ),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              x1.text = "";
                              x2.text = "";
                            });
                          },
                          child: Text('Clear')),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget show(BuildContext context) {
    t1.text = "";
    t2.text = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ADD TODO'),
            content: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'TITLE',
                    ),
                    controller: t1,
                  ),
                  Padding(padding: EdgeInsets.only(top: 50)),
                  TextField(
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: t2,
                  ),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        if (t1.text.isNotEmpty) {
                          setState(() {
                            adddata();
                            t1.text = "";
                            t2.text = "";
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
