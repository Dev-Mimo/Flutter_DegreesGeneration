import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

// ignore: implementation_imports
import 'package:docx_template/src/template.dart';

// ignore: implementation_imports
import 'package:docx_template/src/model.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:desktop_window/desktop_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  Future<void> toggleFullScreen() async {
    await DesktopWindow.toggleFullScreen();
    bool isFullScreen = await DesktopWindow.getFullScreen();

    await DesktopWindow.setFullScreen(true);
  }

  @override
  Widget build(BuildContext context) {
    toggleFullScreen();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: "images/logo.png",
        nextScreen: MyHomePage(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.blue,
      ),
    );
  }
}

int fileCounter = 0;
StateProvider<int> fileCounterProvider = StateProvider((ref) => fileCounter);

Future<int> readFileCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt("fileCounter") ?? 0;
}

Future<bool> persistFileCounter(var fileCounter) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setInt("fileCounter", fileCounter);
}

Future<void> resetFileCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("fileCounter");
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    fileCounterAsync();
    createRequiredFolders();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fileCounterAsync() async {
    fileCounter = await readFileCounter();
  }

  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> dateChanged(DateTime? dt) async {
    // DateTime? at = _formKey.currentState?.fields['date']?.value;
  }

  Future<void> createRequiredFolders() async {
    final dataDir = Directory.current.path;
    final Directory dataDirFolder = Directory("${dataDir}\\data\\");
    final File myFile = File("${dataDir}\\data\\template.docx");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDocDirFolder = Directory("${appDocDir.path}\\MNSUET Degrees\\");

    if (await appDocDirFolder.exists()) {
      print("${appDocDirFolder.path} exists ~!");
    } else {
      final Directory appDocDirNewFolder = await appDocDirFolder.create(recursive: true);
    }

    final Directory templateDirFolder = Directory("${appDocDir.path}\\MNSUET Degrees\\Template\\");

    if (await templateDirFolder.exists()) {
      print("${templateDirFolder.path} exists!");
    } else {
      final Directory templateDirNewFolder = await templateDirFolder.create(recursive: true);
    }

    final Directory generatedDirFolder =
        Directory("${appDocDir.path}\\MNSUET Degrees\\Generated\\");

    if (await generatedDirFolder.exists()) {
      print("${generatedDirFolder.path} exists!");
    } else {
      final Directory generatedDirNewFolder = await generatedDirFolder.create(recursive: true);
    }

    if (await dataDirFolder.exists()) {
      myFile.copy('${templateDirFolder.path}\\template.docx');
    }
  }

  Future<void> saveFileToDisk() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final f = File("${appDocDir.path}\\MNSUET Degrees\\Template\\template.docx");
    final docx = await DocxTemplate.fromBytes(await f.readAsBytes());
    Content c = Content();
    DateTime? dt = _formKey.currentState?.fields['date']?.value;

    c
      ..add(TextContent("name", "${_formKey.currentState?.fields['name']?.value}"))
      ..add(TextContent("father_name", "${_formKey.currentState?.fields['father_name']?.value}"))
      ..add(TextContent("degree_level", "${_formKey.currentState?.fields['degree_level']?.value}"))
      ..add(TextContent("department", "${_formKey.currentState?.fields['department']?.value}"));

    if (dt!.day < 10) {
      c..add(TextContent("day", "0${dt.day}"));
    } else {
      c..add(TextContent("day", "${dt.day}"));
    }

    if (dt.month < 10) {
      c..add(TextContent("month", "0${dt.month}"));
    } else {
      c..add(TextContent("month", "${dt.month}"));
    }

    c
      ..add(TextContent("year", "${dt.year}"))
      ..add(TextContent("CGPA", "${_formKey.currentState?.fields['CGPA']?.value}"))..add(
        TextContent(
            "degree_level2", "${_formKey.currentState?.fields['degree_level']?.value}"))..add(
        TextContent("degree_title", "${_formKey.currentState?.fields['degree_title']?.value}"));

    if (_formKey.currentState?.fields['honors']?.value == true) {
      c..add(TextContent("honours", "with Honors"));
    } else {
      c..add(TextContent("honours", ""));
    }

    final d = await docx.generate(c);
    final of = File(
        "${appDocDir.path}\\MNSUET Degrees\\Generated\\degree${context
            .read(fileCounterProvider)
            .state}.docx");
    // final of = File('C:\\generated${context.read(fileCounterProvider).state}.docx');

    if (d != null) {
      await of.writeAsBytes(d);
      context
          .read(fileCounterProvider)
          .state++;
      await persistFileCounter(context
          .read(fileCounterProvider)
          .state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                // rgb(38, 40, 149)
                height: MediaQuery.of(context).size.height * 0.11,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 40, 149, 1),
                  borderRadius: new BorderRadius.only(
                    bottomLeft: Radius.circular(80.0),
                    bottomRight: Radius.circular(80.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/logo.png'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.01,
                    ),
                    Text(
                      "Muhammad Nawaz Sharif \nUniversity of Engineering\n & Technology, Multan",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.014,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FormBuilder(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderTextField(
                            name: 'father_name',
                            decoration: InputDecoration(
                              labelText: "Father's Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderTextField(
                            name: 'degree_level',
                            decoration: InputDecoration(
                              labelText: 'Degree Level',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderTextField(
                            name: 'department',
                            decoration: InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderDateTimePicker(
                            name: 'date',
                            inputType: InputType.date,
                            format: DateFormat('dd-MM-yyyy'),
                            onChanged: dateChanged,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderTextField(
                            name: 'CGPA',
                            decoration: InputDecoration(
                              labelText: 'CGPA',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderTextField(
                            name: 'degree_title',
                            decoration: InputDecoration(
                              labelText: 'Degree Title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelStyle: TextStyle(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          FormBuilderCheckbox(
                            name: 'honors',
                            initialValue: false,
                            title: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: "Honors?",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ]),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              saveFileToDisk();
                              print(await readFileCounter());
                            },
                            child: Text("Submit"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
