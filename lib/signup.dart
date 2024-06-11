// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:login1/login.dart';
import 'package:login1/share/snackbar.dart';

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' show basename;
import 'dart:math';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final FocusNode _focusNodeConfirmbac = FocusNode();
  final FocusNode _focusNodeuser = FocusNode();

  final FocusNode _focusNodeConfirtelephone = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword =
      TextEditingController();
  final TextEditingController _controllernni = TextEditingController();
  final TextEditingController _controllerbac = TextEditingController();
  final TextEditingController _controllertelephone = TextEditingController();

  bool _obscurePassword = true;
  File? _file;
  File? cart;
  File? releve;
  File? imgPath;
  String? imgName;
  String? cartName;
  String? releveName;
  bool isLoading = false;

  String? _selectedItem = 'Réseaux informatiques et Télécommunications';
  rec() async {
    final mycart = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (mycart != null) {
      setState(() {
        cart = File(mycart.path);
      });
      cartName = basename(mycart.path);
      int random = Random().nextInt(9999999);
      cartName = "$random$imgName";
      showSnackBar(context, "documment selectinné");
    } else {
      showSnackBar(context, "no documment selectinné");
    }
  }

  rec1() async {
    final mycart = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (mycart != null) {
      setState(() {
        releve = File(mycart.path);
      });
      releveName = basename(mycart.path);
      int random = Random().nextInt(9999999);
      releveName = "$random$releveName";
      showSnackBar(context, "documment selectinné");
    } else {
      showSnackBar(context, "no documment selectinné");
    }
  }

  bool isVerified = false;
  bool isTimeout = false;
  Timer? timer;

  void showVerificationDialog() async {
    timer = Timer(const Duration(minutes: 4), () {
      // Timer de 5 minutes (300 secondes)
      if (!isVerified) {
        isTimeout = true;
        Navigator.of(context).pop(); // Fermer le dialogue
      }
    });
  }

  register() async {
    setState(() {
      isLoading = true;
    });
    getData();

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      await credential.user?.sendEmailVerification();
      showVerificationDialog();
      showDialog(
        context: context,
        barrierDismissible:
            false, // Empêcher de fermer le dialogue en cliquant à l'extérieur
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Vérification de l'e-mail"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.7, // 70% de la largeur de l'écran
              height: MediaQuery.of(context).size.height *
                  0.3, // 30% de la hauteur de l'écran
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centrer verticalement le contenu
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Centrer horizontalement le contenu
                children: [
                  Text(
                      "Un e-mail de vérification a été envoyé à ${_controllerEmail.text}. Veuillez vérifier votre e-mail dans les 4 minutes pour continuer."),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    color: Colors.blue, // Changez la couleur selon vos besoins
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Vérifier périodiquement si l'e-mail est vérifié
      while (!isVerified && !isTimeout) {
        await Future.delayed(Duration(
            seconds: 3)); // Attendre 3 secondes avant chaque vérification
        await FirebaseAuth.instance.currentUser
            ?.reload(); // Recharger l'utilisateur pour obtenir les dernières informations
        isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      }

      // Si l'utilisateur n'a pas vérifié son e-mail dans les 5 minutes, le supprimer
      if (isTimeout && !isVerified) {
        try {
          await FirebaseAuth.instance.currentUser?.delete();

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Signup()));
          showSnackBar(context,
              "Votre compte a été supprimé car vous n'avez pas vérifié votre e-mail dans les 5 minutes.");
        } catch (e) {
          showSnackBar(context, "Erreur lors de la suppression du compte : $e");
        }
        return; // Arrêter l'exécution du code après la suppression de l'utilisateur et la navigation
      } else if (isVerified) {
        Navigator.of(context).pop(); // Fermer le dialogue
        showSnackBar(context, "Votre e-mail a été vérifié avec succès !");
        // Continuer avec le reste du code après vérification de l'e-mail
      }
      // Arrêter le timer une fois terminé
      timer!.cancel();

      final storageRef = FirebaseStorage.instance
          .ref("$_selectedItem/${_controllerUsername.text}/$imgName");
      // $imgName
      await storageRef.putFile(imgPath!);

      final cartepath = FirebaseStorage.instance
          .ref("$_selectedItem/${_controllerUsername.text}/$cartName");

      await cartepath.putFile(cart!);

      final relevepath = FirebaseStorage.instance
          .ref("$_selectedItem/${_controllerUsername.text}/$releveName");

      await relevepath.putFile(releve!);

      String urll = await storageRef.getDownloadURL();

      print(credential.user!.uid);

      CollectionReference users =
          FirebaseFirestore.instance.collection("etudiants");

      DocumentReference filliers = await users.doc(_selectedItem.toString());
      filliers.set({'nom': _selectedItem.toString()});
      CollectionReference etudiants = filliers.collection(credential.user!.uid);
      etudiants
          .doc(credential.user!.uid)
          .set({
            'full_name': _controllerUsername.text,
            'bac': _controllerbac.text,
            'tel': _controllertelephone.text,
            'NNI': _controllernni.text,
            'Email': _controllerEmail.text,
            'urlimage': urll,
            'filiére': _selectedItem.toString()
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, "The account already exists for that email.");
      } else {
        showSnackBar(context, "Erreur ");
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  uploadImage2Screen(ImageSource source) async {
    final pickedImg = await ImagePicker().pickImage(source: source);
    try {
      if (pickedImg != null) {
        setState(() {
          imgPath = File(pickedImg.path);
          imgName = basename(pickedImg.path);
          int random = Random().nextInt(9999999);
          imgName = "$random$imgName";
          print(imgName);
        });
      } else {
        print("NO img selected");
      }
    } catch (e) {
      print("Error => $e");
    }

    if (mounted) Navigator.pop(context);
  }

  showmodel() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(22),
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    uploadImage2Screen(ImageSource.camera);
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera,
                      size: 30,
                    ),
                    SizedBox(
                      width: 11,
                    ),
                    Text(
                      "From Camera",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 22,
              ),
              GestureDetector(
                onTap: () async {
                  uploadImage2Screen(ImageSource.gallery);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      size: 30,
                    ),
                    SizedBox(
                      width: 11,
                    ),
                    Text(
                      "From Gallery",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<QueryDocumentSnapshot> datas = [];
  bool autorise = false;
  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('nouveau etudiant ').get();
    datas.addAll(querySnapshot.docs);
    print(datas);
    for (int i = 0; i < datas.length; i++) {
    
    
      if (_controllernni.text == datas[i]['nni']) {
        print(datas[i]['nni']);
        setState(() {
          autorise = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                "ISCAE",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 40, // Taille de la police
                    fontWeight: FontWeight.bold, // Gras
                    color: Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                "Creé Votre Compte",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 35),
              imgPath == null
                  ? CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 225, 225, 225),
                      radius: 71,
                      // backgroundImage: AssetImage("assets/img/avatar.png"),
                      backgroundImage: AssetImage("assets/img/avatar.png"),
                    )
                  : ClipOval(
                      child: Image.file(
                        imgPath!,
                        width: 145,
                        height: 145,
                        fit: BoxFit.cover,
                      ),
                    ),
              Positioned(
                left: 99,
                bottom: -10,
                child: IconButton(
                  onPressed: () {
                    // uploadImage2Screen();
                    showmodel();
                  },
                  icon: const Icon(Icons.add_a_photo),
                  color: Color.fromARGB(255, 94, 115, 128),
                ),
              ),
              TextFormField(
                controller: _controllernni,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: "NNI",
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter NNI";
                  } else if (value.length < 10) {
                    return "NNI doit etre de 14 chiffre.";
                  } else if (autorise == false) {
                    return "NNI no autorisé";
                  }

                  return null;
                },
                onEditingComplete: () => _focusNodeConfirmbac.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerbac,
                keyboardType: TextInputType.number,
                focusNode: _focusNodeConfirmbac,
                decoration: InputDecoration(
                  labelText: "Numero Bac",
                  prefixIcon: const Icon(Icons.account_box),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter numero bac.";
                  }

                  return null;
                },
                onEditingComplete: () =>
                    _focusNodeConfirtelephone.requestFocus(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // PermissionStatus status =
                      //     await Permission.photos.request();
                      // if (status.isGranted) {
                      rec();
                      if (_file != null) {
                        setState(() {
                          rec();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                      child: const Row(
                        children: [
                          Icon(Icons.photo),
                          SizedBox(width: 10),
                          Text("cart d'identité"),
                        ],
                      ),
                    ),
                  ),
                  cart != null
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ) // Image sélectionnée
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                          size: 30,
                        ) // Aucune image sélectionnée
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      rec1();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 57, vertical: 15),
                      child: const Row(
                        children: [
                          Icon(Icons.file_open_sharp),
                          SizedBox(width: 10),
                          Text("Relevé De Note"),
                        ],
                      ),
                    ),
                  ),
                  releve != null
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ) // Image sélectionnée
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                          size: 30,
                        ) // Aucune image sélectionnée
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[200]!
                      .withOpacity(0.0), // Rendre le conteneur transparent
                  border: Border.all(
                      color: Colors.grey), // Ajouter une bordure si nécessaire
                ),
                //  padding: EdgeInsets.symmetric(horizontal: 0,),

                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedItem,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedItem = newValue;
                    });
                  },
                  items: <String>[
                    "Réseaux informatiques et Télécommunications",
                    "Statistique Appliquée á l'Economie",
                    'Informatique de Gestion',
                    'Développement Informatique',
                    'Finance & Comptabilité',
                    'Banques & Assurances',
                    'Gestion des Ressources Humaines',
                    'Techniques Commerciales et Marketing'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllertelephone,
                keyboardType: TextInputType.number,
                focusNode: _focusNodeConfirtelephone,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: "Telephone",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter phone.";
                  } else if (!RegExp(r'^[2-4]').hasMatch(value)) {
                    // Le texte ne commence pas par 2, 3 ou 4
                    return "Le texte doit commencer par 2, 3 ou 4.";
                  }

                  return null;
                },
                onEditingComplete: () => _focusNodeuser.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerUsername,
                keyboardType: TextInputType.name,
                focusNode: _focusNodeuser,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter username.";
                  }

                  return null;
                },
                onEditingComplete: () => _focusNodeEmail.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerEmail,
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email.";
                  } else if (!(value.contains('@') && value.contains('.'))) {
                    return "Invalid email";
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodePassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodePassword,
                keyboardType: TextInputType.visiblePassword,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_outlined)
                          : const Icon(Icons.visibility_off_outlined)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  } else if (value.length < 8) {
                    return "Password must be at least 8 character.";
                  }
                  return null;
                },
                onEditingComplete: () =>
                    _focusNodeConfirmPassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerConFirmPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodeConfirmPassword,
                maxLength: 8,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_outlined)
                          : const Icon(Icons.visibility_off_outlined)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  } else if (value != _controllerPassword.text) {
                    return "Password doesn't match.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                       await getData();
                      if (_formKey.currentState!.validate() &&
                          imgName != null &&
                          imgPath != null) {
                        await register();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      } else {
                        showSnackBar(context, "ERROR");
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Enregistré"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous avez déja un compte?"),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _controllerUsername.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConFirmPassword.dispose();
    super.dispose();
  }
}