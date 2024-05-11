import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/task_model.dart';
import 'login_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  showNotification(message);
}

void showNotification(RemoteMessage message) async {
  if (message.notification != null) {
    showBigTextNotification(
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        fln: flutterLocalNotificationsPlugin);
  } else {
    showBigTextNotification(
        title: message.data["title"] ?? "",
        body: message.data["body"] ?? "",
        fln: flutterLocalNotificationsPlugin);
  }
}

showBigTextNotification(
    {var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin fln}) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    "App Test",
    "App test",
    importance: Importance.max,
    icon: "mipmap/ic_launcher",
    priority: Priority.high,
  );

  var not = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails());
  await fln.show(0, title, body, not);
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController taskNameCtr = TextEditingController();
  bool isLoading = false;
  List<TaskModel> listOfTask = [];

  void registerNotification() {
    firebaseMessaging.getToken().then((value) {
      debugPrint(value);
    });
    firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage: ${message.toString()}");
      showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    firebaseMessaging.getInitialMessage().then((message) {
      debugPrint("getInitialMessage: ${message.toString()}");
      if (message != null) {
        showNotification(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    //var iOSInitialize =  IOSInitializationSettings();
    var initializationsSettings = InitializationSettings(
        android: androidInitialize, iOS: const DarwinInitializationSettings());
    // iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize(flutterLocalNotificationsPlugin);
    registerNotification();
    getTaskList();
  }

  addTaskInFirebase() async {
    if (taskNameCtr.text == "") {
      Fluttertoast.showToast(msg: "Please enter task");
    } else {
      Navigator.pop(context);
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance.collection('tasks').add({
        'taskName': taskNameCtr.text.trim(),
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection("tasks")
            .doc(value.id)
            .update({"id": value.id}).then((value) {
          setState(() {
            isLoading = false;
          });
          // Clear form fields and image
          taskNameCtr.clear();
          Fluttertoast.showToast(msg: "Task added successfully!");
          getTaskList();
        }).catchError((error) => debugPrint("Failed to add product: $error"));
      });
    }
  }

  editTaskInFirebase(String id) async {
    if (taskNameCtr.text == "") {
      Fluttertoast.showToast(msg: "Please enter task");
    } else {
      Navigator.pop(context);
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection("tasks")
          .doc(id)
          .update({"taskName": taskNameCtr.text}).then((value) async {
        setState(() {
          isLoading = false;
        });
        // Clear form fields and image
        taskNameCtr.clear();
        Fluttertoast.showToast(msg: "Task updated successfully!");
        getTaskList();
      });
    }
  }

  deleteTaskInFirebase(String id) async {
    Navigator.pop(context);
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("tasks")
        .doc(id)
        .delete()
        .then((value) async {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Task deleted successfully!");
      getTaskList();
    });
  }

  getTaskList() {
    listOfTask.clear();
    FirebaseFirestore.instance.collection('tasks').get().then((value) {
      setState(() {
        for (int i = 0; i < value.docs.length; i++) {
          listOfTask.add(TaskModel.fromJson(value.docs[i].data()));
        }
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          actions: [
            IconButton(
                onPressed: () {
                  _auth.signOut();
                  _googleSignIn.signOut();
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }), (route) => false);
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Add Task'),
                  content: Form(
                    child: TextFormField(
                      controller: taskNameCtr,
                      decoration:
                          const InputDecoration(labelText: 'Enter Task'),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        addTaskInFirebase();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
        body: listOfTask.isNotEmpty
            ? ListView.builder(
                itemCount: listOfTask.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(listOfTask[index].taskName ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              taskNameCtr.text =
                                  listOfTask[index].taskName ?? "";
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Update Task'),
                                    content: Form(
                                      child: TextFormField(
                                        controller: taskNameCtr,
                                        decoration: const InputDecoration(
                                            labelText: 'Enter Task'),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Update'),
                                        onPressed: () {
                                          editTaskInFirebase(
                                              listOfTask[index].id ?? "");
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: const Text(
                                        'Are you sure you want to delete this task?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          deleteTaskInFirebase(
                                              listOfTask[index].id ?? "");
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                  );
                })
            : const Center(
                child: Text("No Any Task"),
              ));
  }
}
