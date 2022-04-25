import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

void addWordPair(User user, String wordPair) {
  FirebaseFirestore.instance
      .collection("usersSuggestions")
      .doc(user.uid)
      .collection("wordsPairs")
      .add({"pair ": wordPair});
}

void removeWordPair(User user, String wordPair) {
  var doc = FirebaseFirestore.instance
      .collection("usersSuggestions")
      .doc(user.uid)
      .collection("wordsPairs");

  var toDelete = doc.where("pair ", isEqualTo: wordPair).get();
  toDelete.then((value) {
    for (var element in value.docs) {
      doc.doc(element.id).delete().then((value) {});
    }
  });
}

Future<Set> getSavedSuggestions(User user) async {
  var doc = await FirebaseFirestore.instance
      .collection("usersSuggestions")
      .doc(user.uid)
      .collection("wordsPairs")
      .get();
  Set savedSuggestions = {};

  for (DocumentSnapshot document in doc.docs) {
    String word = document.data().toString();
    word = word.split(":")[1];
    word = word.split("}")[0];
    WordPair wordpair = stringToWordPair(word);
    savedSuggestions.add(wordpair);
  }
  return savedSuggestions;
}

WordPair stringToWordPair(String word) {
  String firstWord = word.split("_")[0];
  String secWord = word.split("_")[1];
  WordPair wordpair = WordPair(firstWord.trim(), secWord.trim());

  return wordpair;
}

Future<void> uploadAvatarImage(String filePath, String fileName)  async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  File file = File(filePath);
  await storage.ref('usersAvatars').child(fileName).putFile(file);
}

Future<String> downloadAvatarImage() async {
  // User? currUser = FirebaseAuth.instance.currentUser;
  // final Reference storageReference = FirebaseStorage.instance
  //     .ref()
  //     .child("usersAvatars")
  //     .child("${}");
  // String downloadURL;
  //
  // UploadTask uploadTask = storageReference.putFile(mFileImage);
  //
  // downloadURL = await (await uploadTask).ref.getDownloadURL();

  User? currUser = FirebaseAuth.instance.currentUser;
  try {
    return await FirebaseStorage.instance
        .ref("usersAvatars")
        .child("${currUser?.uid}")
        .getDownloadURL();
  } on Exception catch (e) {
    return ('https://firebasestorage.googleapis.com/v0/b/hellome-c32a4.appspot'
        '.com/o/usersAvatars%2FdefaultAvatar.png?alt=media&token=61905115-203f-436e-8407-1eb5122c609c');
  }
}
