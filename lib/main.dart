import "package:flutter/material.dart";
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'loginPage.dart';

dynamic database;

class ToDoModelClass {
  int? id;
  String title;
  String description;
  String date;

  ToDoModelClass({
    required this.title,
    required this.description,
    required this.date,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
    };
  }
}

Future<void> updateData(int? ind, ToDoModelClass toDo) async {
  final db = await database;
  await db.update(
    'ToDoCard',
    toDo.toMap(),
    where: 'id = ?',
    whereArgs: [ind],
  );
}

List<Map<String, dynamic>> cardData = [];

// Future<List<ToDoModelClass>> getData() async {
Future<void> getData() async {
  final localDB = await database;

  cardData = await localDB.query("ToDoCard");
  print(await cardData);
}

Future<void> insertData(ToDoModelClass obj) async {
  final localDB = await database;

  await localDB.insert(
    'ToDoCard',
    obj.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> deleteCard(int ind) async {
  final localDb = await database;
  await localDb.delete('ToDoCard', where: 'id = ?', whereArgs: [ind]);
  await getData();
}

void main() async {
  runApp(const MyApp());
  database = openDatabase(
    join(await getDatabasesPath(), 'ToDoListDB.db'),
    version: 1,
    onCreate: (db, version) {
      return db.execute('''CREATE TABLE ToDoCard(
    id INTEGER PRIMARY KEY, 
    title TEXT,
    description TEXT,
    date TEXT)''');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class ToDoStyling extends StatefulWidget {
  const ToDoStyling({Key? key}) : super(key: key);

  @override
  State createState() => _ToDoStylingState();
}

class _ToDoStylingState extends State<ToDoStyling> {
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descritpionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData().then((_) {
      setState(() {});
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  int cardPose = -1;
  bool isNewCard = true;
  void editCard(bool newCard, BuildContext context, [int? id]) {
    showBottomSheet(true, context, id);
  }

  void submit(bool newCard, [int? id]) async {
    if (titleController.text.isNotEmpty &&
        descritpionController.text.isNotEmpty &&
        dateController.text.isNotEmpty) {
      final obj = ToDoModelClass(
        title: titleController.text,
        description: descritpionController.text,
        date: dateController.text,
        id: id,
      );

      if (!newCard) {
        insertData(obj);
        await getData();
        setState(() {});
      } else {
        updateData(id!, obj);

        await getData();
        setState(() {});
      }
    }

    titleController.clear();
    descritpionController.clear();
    dateController.clear();
  }

  void showBottomSheet(bool newCard, BuildContext context, [int? id]) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        isDismissible: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Create Task",
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Title",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w400,
                        color: const Color.fromRGBO(0, 139, 148, 1),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Enter Task",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(0, 139, 148, 1),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Description",
                      style: GoogleFonts.quicksand(
                        color: const Color.fromRGBO(0, 139, 148, 1),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    TextField(
                      controller: descritpionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(0, 139, 148, 1),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Date",
                      style: GoogleFonts.quicksand(
                        color: const Color.fromRGBO(0, 139, 148, 1),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.date_range_outlined),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(0, 139, 148, 1),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.purpleAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2025),
                          );
                          String formatedDate =
                              DateFormat.yMMMd().format(pickeddate!);
                          setState(() {
                            dateController.text = formatedDate;
                          });
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(
                      onPressed: () {
                        //submit(true);
                        if (!newCard) {
                          submit(newCard);
                        } else {
                          submit(newCard, id);
                        }

                        Navigator.of(context).pop();
                        //setState(() {});
                      },
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                        Color.fromRGBO(0, 139, 148, 1),
                      )),
                      child: Text(
                        "Submit",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(255, 255, 255, 1),
                        ),
                      )),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        });
  }

  var listOfColors = [
    const Color.fromRGBO(250, 232, 232, 1),
    const Color.fromRGBO(232, 237, 250, 1),
    const Color.fromRGBO(250, 249, 232, 1),
    const Color.fromRGBO(250, 232, 250, 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(
                    "Good Morning",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Ganesh",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: 800,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(217, 217, 217, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Create To-Do List",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                      //width: 800,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: cardData.length,
                        itemBuilder: (BuildContext context, int itemCount) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 16,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: listOfColors[
                                    itemCount % listOfColors.length],
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 10),
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.network(
                                              "https://cdn-icons-png.flaticon.com/512/2098/2098402.png"),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${cardData[itemCount]["title"]}",
                                                style: GoogleFonts.quicksand(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17,
                                                  color: const Color.fromRGBO(
                                                      0, 0, 0, 1),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "${cardData[itemCount]["description"]}",
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color.fromRGBO(
                                                      84, 84, 84, 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 14.0),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            "${cardData[itemCount]["date"]}",
                                            style: GoogleFonts.quicksand(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color.fromRGBO(
                                                  132, 132, 132, 1),
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isNewCard = false;
                                                    cardPose = itemCount;
                                                    titleController.text =
                                                        cardData[itemCount]
                                                            ["title"];
                                                    descritpionController.text =
                                                        cardData[itemCount]
                                                            ["description"];
                                                    dateController.text =
                                                        cardData[itemCount]
                                                            ["date"];
                                                    editCard(
                                                        true,
                                                        context,
                                                        cardData[itemCount]
                                                            ['id']);
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Color.fromRGBO(
                                                      0, 139, 148, 1),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () async {
                                                  int ind =
                                                      cardData[itemCount]['id'];
                                                  await deleteCard(ind);
                                                  setState(() {});
                                                },
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Color.fromRGBO(
                                                      0, 139, 148, 1),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(111, 81, 255, 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(0, 139, 148, 1),
        onPressed: () {
          showBottomSheet(false, context);
        },
        child: const Icon(
          size: 50,
          Icons.add,
        ),
      ),
    );
  }
}
