import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

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
    await DesktopWindow.setFullScreen(true);
  }

  @override
  Widget build(BuildContext context) {
    toggleFullScreen();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 1000,
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
  final _formKey = GlobalKey<FormBuilderState>();
  var degreeOptions = ['B.Sc.', 'B.S.', 'M.Sc.'];
  var genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    fileCounterAsync();
    createRequiredFolders();
    super.initState();
  }

  void fileCounterAsync() async {
    fileCounter = await readFileCounter();
  }

  Future<void> dateChanged(DateTime? dt) async {
    var k = _formKey.currentState?.fields['gender']?.value;
    print(k);
  }

  Future<void> createRequiredFolders() async {
    final dataDir = Directory.current.path;
    final Directory dataDirFolder = Directory("$dataDir\\data\\");
    final File myFile = File("$dataDir\\data\\template.docx");

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

    c..add(TextContent("roll", "${_formKey.currentState?.fields['roll']?.value}"));

    if (_formKey.currentState?.fields['gender']?.value == 'Male') {
      c..add(TextContent("gender", "Mr."))..add(TextContent("gender2", "Son"));
    } else if (_formKey.currentState?.fields['gender']?.value == 'Female') {
      c..add(TextContent("gender", "Mrs."))..add(TextContent("gender2", "Daughter"));
    }
    c
      ..add(TextContent("name", "${_formKey.currentState?.fields['name']?.value}"))
      ..add(TextContent("father_name", "${_formKey.currentState?.fields['father_name']?.value}"))
      ..add(TextContent("degree_level", "${_formKey.currentState?.fields['d_level']?.value}"))
      ..add(TextContent("department", "${_formKey.currentState?.fields['department']?.value}"));

    if (dt!.day < 10) {
      c..add(TextContent("day", "0${dt.day}th"));
      if (dt.day == 1) {
        c..add(TextContent("day", "0${dt.day}st"));
      } else if (dt.day == 2) {
        c..add(TextContent("day", "0${dt.day}nd"));
      } else if (dt.day == 3) {
        c..add(TextContent("day", "0${dt.day}rd"));
      }
    } else {
      c..add(TextContent("day", "${dt.day}th"));
      if (dt.day == 21) {
        c..add(TextContent("day", "${dt.day}st"));
      } else if (dt.day == 22) {
        c..add(TextContent("day", "${dt.day}nd"));
      } else if (dt.day == 23) {
        c..add(TextContent("day", "${dt.day}rd"));
      } else if (dt.day == 31) {
        c..add(TextContent("day", "${dt.day}st"));
      }
    }

    // if (dt.month < 10) {
    //   c..add(TextContent("month", "0${dt.month}"));
    // } else {
    //   c..add(TextContent("month", "${dt.month}"));
    // }

    if (dt.month == 1) {
      c..add(TextContent("month", "January"));
    } else if (dt.month == 2) {
      c..add(TextContent("month", "February"));
    } else if (dt.month == 3) {
      c..add(TextContent("month", "March"));
    } else if (dt.month == 4) {
      c..add(TextContent("month", "April"));
    } else if (dt.month == 5) {
      c..add(TextContent("month", "May"));
    } else if (dt.month == 6) {
      c..add(TextContent("month", "June"));
    } else if (dt.month == 7) {
      c..add(TextContent("month", "July"));
    } else if (dt.month == 8) {
      c..add(TextContent("month", "August"));
    } else if (dt.month == 9) {
      c..add(TextContent("month", "September"));
    } else if (dt.month == 10) {
      c..add(TextContent("month", "October"));
    } else if (dt.month == 11) {
      c..add(TextContent("month", "November"));
    } else if (dt.month == 12) {
      c..add(TextContent("month", "December"));
    }

    String cgpaString = _formKey.currentState?.fields['CGPA']?.value;
    double cgpaDouble = double.parse(cgpaString);
    int cgaInt = cgpaDouble.toInt();

    var secondDigit = ((cgpaDouble * 10) % 10).toInt();
    var thirdDigit = ((cgpaDouble * 100) % 10).toInt();
    var fourthDigit = ((cgpaDouble * 1000) % 10).toInt();

    c
      ..add(TextContent("year", "${dt.year}"))
      ..add(TextContent("CGPA", "${_formKey.currentState?.fields['CGPA']?.value}"));
    if (cgaInt == 1) {
      c..add(TextContent("firstDigit", "One Pt"));
    } else if (cgaInt == 2) {
      c..add(TextContent("firstDigit", "Two Pt"));
    } else if (cgaInt == 3) {
      c..add(TextContent("firstDigit", "Three Pt"));
    } else if (cgaInt == 4) {
      c..add(TextContent("firstDigit", "Four Pt"));
    }

    if (secondDigit == 1) {
      c..add(TextContent("secondDigit", "One"));
    } else if (secondDigit == 2) {
      c..add(TextContent("secondDigit", "Two"));
    } else if (secondDigit == 3) {
      c..add(TextContent("secondDigit", "Three"));
    } else if (secondDigit == 4) {
      c..add(TextContent("secondDigit", "Four"));
    } else if (secondDigit == 5) {
      c..add(TextContent("secondDigit", "Five"));
    } else if (secondDigit == 6) {
      c..add(TextContent("secondDigit", "Six"));
    } else if (secondDigit == 7) {
      c..add(TextContent("secondDigit", "Seven"));
    } else if (secondDigit == 8) {
      c..add(TextContent("secondDigit", "Eight"));
    } else if (secondDigit == 9) {
      c..add(TextContent("secondDigit", "Nine"));
    } else if (secondDigit == 0) {
      c..add(TextContent("secondDigit", "Zero"));
    }

    if (thirdDigit == 1) {
      c..add(TextContent("thirdDigit", "One"));
    } else if (thirdDigit == 2) {
      c..add(TextContent("thirdDigit", "Two"));
    } else if (thirdDigit == 3) {
      c..add(TextContent("thirdDigit", "Three"));
    } else if (thirdDigit == 4) {
      c..add(TextContent("thirdDigit", "Four"));
    } else if (thirdDigit == 5) {
      c..add(TextContent("thirdDigit", "Five"));
    } else if (thirdDigit == 6) {
      c..add(TextContent("thirdDigit", "Six"));
    } else if (thirdDigit == 7) {
      c..add(TextContent("thirdDigit", "Seven"));
    } else if (thirdDigit == 8) {
      c..add(TextContent("thirdDigit", "Eight"));
    } else if (thirdDigit == 9) {
      c..add(TextContent("thirdDigit", "Nine"));
    } else if (thirdDigit == 0) {
      c..add(TextContent("thirdDigit", "Zero"));
    }

    if (fourthDigit == 1) {
      c..add(TextContent("fourthDigit", "One"));
    } else if (fourthDigit == 2) {
      c..add(TextContent("fourthDigit", "Two"));
    } else if (fourthDigit == 3) {
      c..add(TextContent("fourthDigit", "Three"));
    } else if (fourthDigit == 4) {
      c..add(TextContent("fourthDigit", "Four"));
    } else if (fourthDigit == 5) {
      c..add(TextContent("fourthDigit", "Five"));
    } else if (fourthDigit == 6) {
      c..add(TextContent("fourthDigit", "Six"));
    } else if (fourthDigit == 7) {
      c..add(TextContent("fourthDigit", "Seven"));
    } else if (fourthDigit == 8) {
      c..add(TextContent("fourthDigit", "Eight"));
    } else if (fourthDigit == 9) {
      c..add(TextContent("fourthDigit", "Nine"));
    } else if (fourthDigit == 0) {
      c..add(TextContent("fourthDigit", "Zero"));
    }

    c..add(TextContent("degree_level2", "${_formKey.currentState?.fields['d_level']?.value}"));
    if (_formKey.currentState?.fields['d_level']?.value == 'B.Sc.') {
      c..add(TextContent("degree_level2", "Bachelor of Science"));
    } else if (_formKey.currentState?.fields['d_level']?.value == 'B.S.') {
      c..add(TextContent("degree_level2", "Bachelor of Science"));
    } else if (_formKey.currentState?.fields['d_level']?.value == 'M.Sc.') {
      c..add(TextContent("degree_level2", "Master of Science"));
    }
    // ..add(TextContent("degree_title", "${_formKey.currentState?.fields['d_level']?.value}"));

    if (_formKey.currentState?.fields['honors']?.value == true) {
      c..add(TextContent("honours", "with Honors"));
    } else {
      c..add(TextContent("honours", ""));
    }

    final d = await docx.generate(c);
    final of = File(
        "${appDocDir.path}\\MNSUET Degrees\\Generated\\Degree_${_formKey.currentState?.fields['roll']?.value}.docx");

    if (d != null) {
      await of.writeAsBytes(d);
      context.read(fileCounterProvider).state++;
      await persistFileCounter(context.read(fileCounterProvider).state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              // rgb(38, 40, 149)
              height: MediaQuery.of(context).size.height * 0.08,
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
                      fontSize: MediaQuery.of(context).size.width * 0.010,
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
                  padding: const EdgeInsets.all(1.0),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.always,
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: FormBuilderDropdown(
                              name: 'gender',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                labelText: 'Gender',
                              ),
                              // initialValue: 'Male',
                              allowClear: true,
                              hint: Text('Select Gender'),
                              validator: FormBuilderValidators.compose(
                                  [FormBuilderValidators.required(context)]),
                              items: genderOptions
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text('$gender'),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.004,
                        ),
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
                          height: MediaQuery.of(context).size.height * 0.004,
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
                          height: MediaQuery.of(context).size.height * 0.004,
                        ),
                        // FormBuilderTextField(
                        //   name: 'degree_title',
                        //   decoration: InputDecoration(
                        //     labelText: 'Degree Title',
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(20.0),
                        //     ),
                        //     labelStyle: TextStyle(),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: MediaQuery.of(context).size.height * 0.004,
                        // ),
                        FormBuilderTextField(
                          name: 'roll',
                          decoration: InputDecoration(
                            labelText: 'Roll Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            labelStyle: TextStyle(),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.004,
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
                          height: MediaQuery.of(context).size.height * 0.004,
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
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.minLength(context, 5),
                            FormBuilderValidators.maxLength(context, 5)
                          ]),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.004,
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
                          height: MediaQuery.of(context).size.height * 0.004,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: FormBuilderDropdown(
                              name: 'd_level',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                labelText: 'Degree Level',
                              ),
                              // initialValue: 'Male',
                              allowClear: true,
                              hint: Text('Select Degree Level'),
                              validator: FormBuilderValidators.compose(
                                  [FormBuilderValidators.required(context)]),
                              items: degreeOptions
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text('$gender'),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.004,
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
                          height: MediaQuery.of(context).size.height * 0.004,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                _formKey.currentState?.save();
                                if (_formKey.currentState!.validate()) {
                                  saveFileToDisk();
                                  print(await readFileCounter());
                                } else {
                                  print("Validation failed!");
                                }
                              },
                              child: Text("Submit"),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.004,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _formKey.currentState!.reset();
                                FocusScope.of(context).unfocus();
                              },
                              child: Text("Reset"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.004,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 40, 149, 1),
                  borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Created by:",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.01,
                    ),
                    Image.asset('images/Logo_Name_JTech.png'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
