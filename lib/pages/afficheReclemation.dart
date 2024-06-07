import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AfficheReclemation extends StatefulWidget {
  const AfficheReclemation({super.key});

  @override
  State<AfficheReclemation> createState() => _AfficheReclemationState();
}

class _AfficheReclemationState extends State<AfficheReclemation> {
  List<Map<String, dynamic>> studentsData = [];
  String? emailUser;
  List<QueryDocumentSnapshot> datas = [];
  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('reclemations').get();
    datas.addAll(querySnapshot.docs);
  }

  // List<Map<String, dynamic>> studentsData = [];
  // var _fullNameController;
  // final credential = FirebaseAuth.instance.currentUser;
  // getPdfUrlsFromFirestore() async {
  //   try {
  //     CollectionReference pdfCollection =
  //         FirebaseFirestore.instance.collection('reclemations');
  //     QuerySnapshot querySnapshot = await pdfCollection.get();
  //     DocumentSnapshot studentDoc =
  //         await pdfCollection.doc(credential!.uid).get();
  //     querySnapshot.docs.forEach((doc) {
  //       studentsData.add(studentDoc.data() as Map<String, dynamic>);

  //       _fullNameController.text = studentDoc['full_name'] ?? '';
  //       print(_fullNameController);
  //     });
  //   } catch (e) {
  //     print('Erreur lors de la récupération des URLs des PDF: $e');
  //     // Rejette l'erreur pour la capturer dans catchError
  //   }
  // }

  @override
  void initState() {
    getData();
    getDataFromFirestore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Reclemation Envoie'),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: datas.length,
            itemBuilder: (context, i) {
              if (emailUser == datas[i]['email']) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                  child: Card(
                      child: ListTile(
                    leading: Text((i + 1).toString()),
                    title: Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(datas[i]['full_name'] +
                            ' : Tu as reclamer sur la '),
                        Text(datas[i]['semester']),
                        Text('Nom Du Matiere  : ' + datas[i]['nomMatiere']),
                        Text('La Note Exact : ' + datas[i]['noteExact']),
                        Text('envoie le ' + datas[i]['dateEnvoie'])
                      ],
                    ),
                  )),
                );
              }
            }));
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
              //nom = studentDoc['full_name'] ?? '';
              emailUser = studentDoc['Email'] ?? '';
              //fillier = studentDoc['filiére'] ?? '';
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
