import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lab_test/sign_up_screen.dart';
import 'package:lab_test/recipe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        brightness: Brightness.light,
      ),
      home: const HomeRecipeList(
        title: 'Recipe List',
      ),
    );
  }
}

class HomeRecipeList extends StatefulWidget {
  final String title;
  const HomeRecipeList({Key? key, required this.title}) : super(key: key);

  @override
  State<HomeRecipeList> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeRecipeList> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpScreen(),
          ),
        );
      } else {
        print('User is signed in!');
        print("User ${user.toString()}");
      }
    });
  }

  
  int recipelength = 0;
  final db = FirebaseFirestore.instance;

  // create controllers to handle inputs
  TextEditingController taskController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  // create a boolean variable to handle input fields
  bool viewInputfields = false;

  // create a function to add new recipe
  void addTask(String task, String name) async {
    final docRef = db.collection('recipeList').doc();
    docRef.set(RECIPEModel(recipelength, task, name, 3).toJson()).then(
        (value) => Fluttertoast.showToast(msg: "recipe added successfully!"),
        onError: (e) => print("Error adding recipe: $e"));
    recipelength++;
    setState(() {});
  }

  // create a function to remove recipe
  void removeTask(dynamic docID, RECIPEModel recipe) {
    print(recipe.id);
    //data base name 
    db.collection('recipeList').doc(docID.toString()).delete().then(
        (value) => Fluttertoast.showToast(msg: "recipe deleted Successfully!"),
        onError: (e) => print("Error deleting recipe: $e"));
    setState(() {
      //increment length
      recipelength--;
      
    });
  }


//update recipe
  void changeTaskStatus(dynamic docID, RECIPEModel recipe) {
    recipe.status = 1;
    db.collection('recipeList').doc(docID.toString()).set(recipe.toJson()).then(
        (value) => Fluttertoast.showToast(msg: "recipe updated Successfully!"),
        onError: (e) => print("Error updating recipe: $e"));
    setState(() {
     
    });
  }


//get recipelist.......................................................................................................
  Future getRECIPELists() async {
    return db.collection("recipeList").get();
  }



// sign out ............................
  Future<String?> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Fluttertoast.showToast(msg: "Sign Out Successfull");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
        ),
      );
      return null;
    } on FirebaseAuthException catch (ex) {
      return "${ex.code}: ${ex.message}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              )),
          actions: [
            IconButton(
                onPressed: () {
                  signOut();
                },
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout_outlined)),
          ],
        ),
        body: Center(
          child: Stack(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //show and hide input fields according to the variable value...
              if (viewInputfields)
                Container(
                  padding: const EdgeInsets.all(20),
                  height: 250,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  
                  // add new recipe..................
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Add New Recipe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        controller: taskController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Description',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Recipe Name',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              addTask(taskController.text, nameController.text);
                              taskController.clear();
                              nameController.clear();
                              setState(() {
                                viewInputfields = false;
                              });
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              if (!viewInputfields)
                FutureBuilder(
                  future: getRECIPELists(),
                  builder: ((context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == null) {
                      return const SizedBox();
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const SizedBox(
                        child: Center(child: Text("No Recipe List")),
                      );
                    }

                    if (snapshot.hasData) {
                      List<Map<dynamic, dynamic>> recipeList = [];

                      for (var doc in snapshot.data!.docs) {
                        final recipe = RECIPEModel.fromJson(
                            doc.data() as Map<String, dynamic>);
                        Map<dynamic, dynamic> map = {
                          "docId": doc.id,
                          "recipe": recipe
                        };
                        recipe.add(map);
                      }

                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: recipeList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                                title: Text(recipeList[index]["recipe"].task!),
                                subtitle: Text(recipeList[index]["recipe"].name!),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        tooltip: "Press to mark as complete",
                                        onPressed: () {
                                          changeTaskStatus(
                                              recipeList[index]["docId"],
                                              recipeList[index]["recipe"]);
                                        },
                                        icon: Icon(
                                          recipeList[index]["recipe"].status! == 1
                                              ? Icons.check_circle_rounded
                                              : Icons.check_circle_outline,
                                          color:
                                              recipeList[index]["recipe"].status! ==
                                                      1
                                                  ? Colors.green
                                                  : Colors.grey[800],
                                        )),
                                    IconButton(
                                        tooltip: "Press to Delete Task",
                                        onPressed: () {
                                          removeTask(recipeList[index]["docId"],
                                              recipeList[index]["recipe"]);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        )),
                                  ],
                                )),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  }),
                )
            ],
          ),
        ),
        
        // add new RECIPE
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              viewInputfields = true;
            });
          },
          tooltip: 'Add RECIPE',
          child: const Icon(Icons.add),
        ));
  }
}
