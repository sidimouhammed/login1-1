import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:login1/pages/afficheReclemation.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/material/dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rectlmation extends StatefulWidget {
  const Rectlmation({super.key});

  @override
  State<Rectlmation> createState() => _RectlmationState();
}

class _RectlmationState extends State<Rectlmation> {
  final matiereController = TextEditingController();
  final noteController = TextEditingController();
  final descripController = TextEditingController();
  File? _selectedImage;
  String? _semester;

  String? urlImage;
  bool? valide;
  List<Map<String, dynamic>> studentsData = [];
  String? nom;
  String? emailUser;
  String? fillier;
  String? reclemationExamen = 'Non';
  String? etat;

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    etat = 'Envoyée';
    final now = DateTime.now();
    valide = false;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Reclmation'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AfficheReclemation()));
              },
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: ListView(
          children: [
            const Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Selectionz le Semester',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: Text('Semester 1'),
                    value: "Semester 1",
                    groupValue: _semester,
                    onChanged: (value) {
                      setState(() {
                        _semester = value;
                      });
                      print(value);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: Text('Semester 2'),
                    value: "Semester 2",
                    groupValue: _semester,
                    onChanged: (value) {
                      setState(() {
                        _semester = value;
                      });
                      print(value);
                    },
                  ),
                ),
              ],
            ),
            const Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Reclemation Devoir",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: matiereController,
                decoration: InputDecoration(
                    hintText: "Nom de Matiere",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            // if (_devoirOuExamen == "Devoir")
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: noteController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                decoration: InputDecoration(
                    hintText: "Note exacte",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            // if (_devoirOuExamen == "Devoir")
            const Text(
              'Selectionez la copie du note',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            //if (_devoirOuExamen == "Devoir")
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    child: Container(
                        height: 50,
                        child: Image.asset('assets/img/gallery.png')),
                  ),
                  //if (_devoirOuExamen == "Devoir")
                  MaterialButton(
                      onPressed: () {
                        _pickImageFromCamera();
                      },
                      child: Container(
                          height: 50,
                          child: Image.asset('assets/img/camera.png'))),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text(
                    "Tu as Reclemation Sur L'Examen ?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile(
                    title: Text('Oui'),
                    value: "Oui",
                    groupValue: reclemationExamen,
                    onChanged: (value) {
                      setState(() {
                        reclemationExamen = value;
                      });
                      print(value);
                    },
                  ),
                  RadioListTile(
                    title: Text('Non'),
                    value: "Non",
                    groupValue: reclemationExamen,
                    onChanged: (value) {
                      setState(() {
                        reclemationExamen = value;
                      });
                      print(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            //1234567843s6fr7gt
            // _selectedImage != null
            //     ? Image.file(_selectedImage!)
            //     : const Text('please get image'),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: descripController,
                decoration: InputDecoration(
                    hintText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () {
                    showCupertinoDialog<void>(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                              title: const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                              content: const Text(
                                  'vous voullez envoie le reclemation ?'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  child: Text('No'),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('Yes'),
                                  isDefaultAction: true,
                                  onPressed: () async {
                                    await saveImage();
                                    addDataToSave(
                                        _semester.toString().trim(),
                                        reclemationExamen.toString(),
                                        matiereController.text.trim(),
                                        noteController.text.trim(),
                                        descripController.text.trim(),
                                        valide,
                                        now,
                                        etat);

                                    Navigator.pop(context);
                                    setState(() {
                                      _semester = "";
                                      reclemationExamen = 'Non';
                                      matiereController.text = "";
                                      noteController.text = "";
                                      noteController.text = "";
                                      descripController.text = "";
                                      _selectedImage = null;
                                      urlImage = null;
                                    });
                                  },
                                )
                              ],
                            ));
                  },
                  child: Text('Envoie ')),
            ),
          ],
        ),
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }

  final credential = FirebaseAuth.instance.currentUser;
  Future addDataToSave(String semester, reclemationExamen, String nomMat,
      String note, String descrp, valide, now, etat) async {
    await FirebaseFirestore.instance
        .collection('reclemations')
        .add({
      'semester': semester,
      'reclemationDeExamen': reclemationExamen,
      'nomMatiere': nomMat,
      'noteExact': note,
      'descrip': descrp,
      'valide': valide,
      'urlImage': urlImage,
      'full_name': nom,
      'email': emailUser,
      'filiére': fillier,
      'dateEnvoie': now.toString(),
      'etat': etat
      //'examen'
    });
  }

  Future saveImage() async {
    if (_selectedImage != null) {
      var ImageName = basename(_selectedImage!.path);
      var refStorage = FirebaseStorage.instance.ref('reclemations/$ImageName');
      await refStorage.putFile(_selectedImage!);

      urlImage = await refStorage.getDownloadURL();
    } else {
      urlImage = null;
    }
  }

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
              nom = studentDoc['full_name'] ?? '';
              emailUser = studentDoc['Email'] ?? '';
              fillier = studentDoc['filiére'] ?? '';
              // _fullNameController.text = studentDoc['full_name'] ?? '';
              // _phoneNumberController.text = studentDoc['tel'] ?? '';
            });
            print("Data fetched successfully");
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
  }
}
