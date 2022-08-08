import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:maths_club/screens/post_creation/create_post_view.dart';
import 'package:maths_club/screens/section_views/post_view.dart';
import 'package:maths_club/screens/section_views/quiz_view.dart';
import 'package:maths_club/widgets/section_app_bar.dart';
import 'dart:ui';

/// An enum for the horizontal carousel that returns padding based on position.
enum PositionPadding {
  start(EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0)),
  middle(EdgeInsets.all(8.0)),
  end(EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0));

  const PositionPadding(this.padding);
  final EdgeInsetsGeometry padding;
}

/// An enum for the type of post.
enum PostType {
  post,
  quiz;
}

/// Creates cards for posts and quizzes.
Widget postCard(BuildContext context,
    {PositionPadding position = PositionPadding.middle,
    required String title,
    required String description,
    required PostType type, required Map<String, dynamic> data, required String role}) {
  return Padding(
    padding: (type == PostType.quiz)
        ? position.padding
        : const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 6.0),
    child: Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        splashColor: Theme.of(context).colorScheme.primary.withAlpha(40),
        highlightColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        onTap: () {
          if (type == PostType.post) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostView(data: data)
              ),
            );
          } else if (type == PostType.quiz) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuizView(data: data)
              ),
            );
          }
        },
        child: SizedBox(
          height: 151,
          width: 165,
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16.0, 8.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(title,
                            style: Theme.of(context).textTheme.headline5?.copyWith(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ),
                      (role == 'Admin') ? SizedBox(
                        height: 32.0,
                        width: 32.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreatePost(postData: data)
                              ),
                            );
                          },
                          child: Icon(Icons.edit, color: Theme.of(context).hintColor)
                        ),
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                ),
                Text(description,
                    style: Theme.of(context).textTheme.bodyText2,
                    overflow: TextOverflow.ellipsis),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                  child: OutlinedButton(
                      onPressed: () {
                        if (type == PostType.post) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostView(data: data)
                            ),
                          );
                        } else if (type == PostType.quiz) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizView(data: data)
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                          minimumSize: const Size(80, 40),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          )),
                      child: Text(
                        'Read More',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// This is the section page which allows for access to quizzes and posts
class SectionPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String role;
  final String title;
  final String? id;
  const SectionPage(
      {Key? key, required this.userData, required this.title, required this.id, required this.role})
      : super(key: key);

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  String searchValue = '';
  List<String> searchResults = ['nothing'];

  Algolia algolia = const Algolia.init(
    applicationId: '3AX0WXX57C',
    apiKey: '7d3fc81ef87a6ade4dcf5b845e3f8984',
  );

  updateSearch(String value) async {
    searchResults = ['nothing'];
    AlgoliaQuery query = algolia.instance.index('maths-club-posts').query(value);
    List<AlgoliaObjectSnapshot> results = (await query.getObjects()).hits;

    setState(() {
      searchValue = value;

      for (var result in results) {
        searchResults.add(result.objectID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var pixelRatio = window.devicePixelRatio;
    var logicalScreenSize = window.physicalSize / pixelRatio;
    var logicalHeight = logicalScreenSize.height;

    return Scaffold(
      /// main body
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: StreamBuilder<QuerySnapshot>(
            key: ValueKey<String>(searchValue),
            // If there has been no search done, don't filter by search results,
            // but if a search has been done, only return documents withtin that
            stream: (searchValue == '') ?
            FirebaseFirestore.instance
                .collection('posts')
                .where('Group', isEqualTo: widget.id)
                .snapshots() :
            FirebaseFirestore.instance
                .collection('posts')
                .where('Group', isEqualTo: widget.id)
                .where(FieldPath.documentId, whereIn: searchResults)
                .snapshots(),
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.active) {
                List<Map<String, dynamic>> quizzes = [];
                List<Map<String, dynamic>> posts = [];

                for (QueryDocumentSnapshot<Object?>? doc in (postsSnapshot.data?.docs ?? [])) {
                  try {
                    // If the start date is before the current time and the end
                    // date is after the current time, is inside quiz period. The
                    // following check will throw an error if the date properties
                    // are not defined, and that would be the case in a post.
                    if (doc?['Start Date'].toDate().isBefore(DateTime.now()) &&
                        doc?['End Date'].toDate().isAfter(DateTime.now()) && doc?['createQuiz'] == true) {
                      // Gets the JSON version of the quiz
                      Map<String, dynamic> json = doc?.data() as Map<String, dynamic>;
                      json['ID'] = doc?.id;
                      quizzes.add(json);
                    } else {
                      // This path is normally called for what used to be a valid
                      // quiz, but the valid range has expired
                      Map<String, dynamic> json = doc?.data()
                      as Map<String, dynamic>;
                      json['ID'] = doc?.id;
                      posts.add(json);
                    }
                  } on StateError catch (_) {
                    // Gets the JSON version of the post
                    Map<String, dynamic> json = doc?.data()
                        as Map<String, dynamic>;
                    json['ID'] = doc?.id;
                    posts.add(json);
                  }
                }

                  return ListView(
                    children: [
                      SectionAppBar(context,
                          title: widget.title, userData: widget.userData, onSearch: (String search) => updateSearch(search), searchController: TextEditingController(text: searchValue)),
                      // If no posts are found, don't try to display posts!
                      (posts.isEmpty && quizzes.isEmpty) ? SizedBox(height: logicalHeight - 120, child: const Center(child: Text('Nothing found!'))) : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Don't show "quizzes" title if there are no posts
                          (quizzes.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(26, 16, 0, 16),
                                  child: Text("Active Quizzes",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorLight)),
                                )
                              : const SizedBox.shrink(),
                          (quizzes.isNotEmpty)
                              ? SizedBox(
                            height: 175,
                            child: Center(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: quizzes.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return postCard(context,
                                      title: quizzes[index]['Quiz Title'],
                                      description: quizzes[index]['Quiz Description'],
                                      position: PositionPadding.start,
                                      type: PostType.quiz,
                                      data: quizzes[index],
                                  role: widget.role);
                                },
                              ),
                            ),
                          ) : const SizedBox.shrink(),
                          // Don't show "posts" title if there are no posts
                          (posts.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(26, 16, 0, 16),
                                  child: Text("Posts",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorLight)),
                                )
                              : const SizedBox.shrink(),
                          (posts.isNotEmpty)
                              ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (BuildContext context, int index) {
                                return postCard(context,
                                    title: posts[index]['Title'],
                                    description: posts[index]['Description'],
                                    position: PositionPadding.start,
                                    type: PostType.post,
                                    data: posts[index],
                                role: widget.role);
                              }) : const SizedBox.shrink(),
                        ],
                      ),
                    ],
                  );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
