import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/profileSnappingSheet.dart';
import 'package:hello_me/savedSuggestionsScreen.dart';
import 'package:hello_me/services.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'Authentican.dart';
import 'loginScreen.dart';

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  List savedList = [];
  Set all_saved = {};
  User? currUser = FirebaseAuth.instance.currentUser;
  late String imageUrl;
  final SnappingSheetController _snappingSheetController =
      SnappingSheetController();

  Future<void> _pushSaved() async {
    all_saved = await getSavedSuggestions(currUser!);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = all_saved.map(
            // final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];
          savedList = divided.toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ShowSuggestions(savedList, all_saved),
            // body: ShowSuggestions(savedList,_saved),
          );
        },
      ),
    );
  }

  Widget _buildRow(WordPair pair) {
    all_saved.addAll(_saved);
    final alreadySaved = all_saved.contains(pair);

    // final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Theme.of(context).primaryColor : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          String wordpair = pair.asSnakeCase;
          if (alreadySaved) {
            if (AuthRepository.instance().status == Status.Authenticated) {
              removeWordPair(currUser!, wordpair);
            }
            all_saved.remove(pair);
          } else {
            all_saved.add(pair);
            if (AuthRepository.instance().status == Status.Authenticated) {
              addWordPair(currUser!, wordpair);
            }
          }
        });
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      // The itemBuilder callback is called once per suggested
      // word pairing, and places each suggestion into a ListTile
      // row. For even rows, the function adds a ListTile row for
      // the word pairing. For odd rows, the function adds a
      // Divider widget to visually separate the entries. Note that
      // the divider may be difficult to see on smaller devices.
      itemBuilder: (context, i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return const Divider();
        }

        // The syntax "i ~/ 2" divides i by 2 and returns an
        // integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings
        // in the ListView,minus the divider widgets.
        final index = i ~/ 2;
        // If you've reached the end of the available word
        // pairings...
        if (index >= _suggestions.length) {
          // ...then generate 10 more and add them to the
          // suggestions list.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool snappingSheetUp = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          currUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  tooltip: "Logout",
                  onPressed: () {
                    String? email = currUser?.email;
                    AuthRepository.instance().signOut(email!);
                    currUser = null;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RandomWords()),
                        (route) => false);
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.login_outlined),
                  tooltip: "Login",
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
        ],
      ),
      body: currUser != null
          ? SnappingSheet(
              child: _buildSuggestions(),
              lockOverflowDrag: true,
              snappingPositions: const [
                SnappingPosition.factor(
                  positionFactor: 0.0,
                  grabbingContentOffset: GrabbingContentOffset.top,
                ),
                SnappingPosition.factor(
                  snappingCurve: Curves.ease,
                  positionFactor: 0.5,
                ),
                SnappingPosition.factor(positionFactor: 0.2),
              ],
              controller: _snappingSheetController,
              grabbingHeight: 55,
              grabbing: GestureDetector(
                child: const DefaultGrabbing(),
                onTap: () {
                  _snappingSheetController.snapToPosition(
                      SnappingPosition.factor(
                          positionFactor: (snappingSheetUp ? 0.25 : 0.04)));
                  snappingSheetUp = !snappingSheetUp;
                },
              ),
              sheetBelow: SnappingSheetContent(
                draggable: true,
                child: profileContent(),
              ),
            )
          : _buildSuggestions(),
    );
    // );
  }
}
