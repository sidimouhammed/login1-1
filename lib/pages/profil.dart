import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modifier.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nniController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> studentsData = [];

  Future<void> getDataFromFirestore() async {
    try {
      final credential = FirebaseAuth.instance.currentUser;
      if (credential == null) {
        print("User is not logged in");
        return;
      }

      // Récupérer la référence de la collection principale
      CollectionReference etudiantsCollection =
          FirebaseFirestore.instance.collection('etudiants');

      // Récupérer tous les documents de la collection principale
      QuerySnapshot querySnapshot = await etudiantsCollection.get();

      // Parcourir tous les documents
      // Parcourir tous les documents
      for (var doc in querySnapshot.docs) {
        // Récupérer la sous-collection avec l'UID de l'étudiant
        CollectionReference studentSubCollection =
            etudiantsCollection.doc(doc.id).collection(credential.uid);

        // Vérifier si la sous-collection contient des documents
        QuerySnapshot subCollectionSnapshot = await studentSubCollection.get();
        if (subCollectionSnapshot.docs.isNotEmpty) {
          // Si la sous-collection contient des documents, récupérer les données
          DocumentSnapshot studentDoc =
              await studentSubCollection.doc(credential.uid).get();
          if (studentDoc.exists) {
            setState(() {
              studentsData.add(studentDoc.data() as Map<String, dynamic>);
              _fullNameController.text = studentDoc['full_name'] ?? '';
              _nniController.text = studentDoc['NNI'] ?? '';
              _phoneNumberController.text = studentDoc['tel'] ?? '';
              _emailController.text = studentDoc['Email'] ?? '';
            });
            print("Data fetched successfully");
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nniController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Profile'),
      ),
      body: studentsData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 25),
                Container(
                  height: 190,
                  width: 190,
                  child: CircleAvatar(
                    //backgroundColor: Colors.white,
                    // radius: 60,
                    maxRadius: 80,
                    child: ClipOval(
                      child: Image.network(
                        studentsData[0]['urlimage'],
                        width: 145,
                        height: 145,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.person),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintText: "NOM Et Prenom",
                            enabled: false,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nniController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.perm_identity),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintText: "NNI",
                            enabled: false,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.phone),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintText: "Number",
                            enabled: false,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.email),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintText: "Email",
                            enabled: false,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text('Vous voulez modifier le '),
                        const SizedBox(height: 5),
                        const Text('email ou numéro de téléphone ?'),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: () {
                              showCupertinoDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CupertinoAlertDialog(
                                        title: const Icon(
                                          Icons.warning,
                                          color: Colors.red,
                                        ),
                                        content: const Text(
                                            'Vous voulez modifier le email ou numéro de téléphone ?'),
                                        actions: <CupertinoDialogAction>[
                                          CupertinoDialogAction(
                                            child: const Text('No'),
                                            isDefaultAction: true,
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: const Text('Yes'),
                                            isDefaultAction: true,
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const UpDate()));
                                            },
                                          ),
                                        ],
                                      ));
                            },
                            child: const Text('Contact Admin'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
