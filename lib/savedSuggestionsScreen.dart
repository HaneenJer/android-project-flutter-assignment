import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/services.dart';
import 'Authentican.dart';

class ShowSuggestions extends StatefulWidget {
  List savedSuggestions;
  Set saved;

  ShowSuggestions(this.savedSuggestions, this.saved);

  @override
  _showSuggestionsState createState() =>
      _showSuggestionsState(this.savedSuggestions, this.saved);
}

class _showSuggestionsState extends State<ShowSuggestions> {
  List savedSuggestions;
  Set saved;
  User? currUser = FirebaseAuth.instance.currentUser;

  _showSuggestionsState(this.savedSuggestions, this.saved);

  @override
  Widget build(BuildContext context) {
    if (!savedSuggestions.isNotEmpty) {
      return Container(
        child:
            const Text('No Saved Suggestions', style: TextStyle(fontSize: 20)),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      );
    }
    TextButton yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () => Navigator.of(context).pop(true),
      style: TextButton.styleFrom(
        primary: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
    TextButton noButton = TextButton(
      child: const Text(
        "No",
      ),
      onPressed: () => Navigator.of(context).pop(false),
      style: TextButton.styleFrom(
        primary: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
    return Scaffold(
      body: ListView.builder(
        itemCount: savedSuggestions.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            child: savedSuggestions[index],
            background: Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.white, size: 25),
                  Text(
                    "Delete Suggestion",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            onDismissed: (DismissDirection direction) {
              setState(() {
                savedSuggestions.removeAt(index);
                WordPair pair = saved.elementAt(index);
                saved.remove(pair);
                String wordpair = pair.asSnakeCase;
                if (AuthRepository.instance().status == Status.Authenticated) {
                  removeWordPair(currUser!, wordpair.trim());
                }
              });
            },
            confirmDismiss: (DismissDirection direction) async {
              AlertDialog alert = AlertDialog(
                title: const Text("Delete Suggestion",
                    style: TextStyle(fontSize: 20)),
                content: Text(
                    "Are you sure you want to delete ${saved.elementAt(index).toString()}"
                    " from your saved suggestions?"),
                actions: [
                  yesButton,
                  noButton,
                ],
              );
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
          );
        },
      ),
    );
  }
}
