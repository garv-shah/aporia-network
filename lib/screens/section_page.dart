import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maths_club/screens/auth/landing_page.dart';
import 'package:maths_club/screens/quiz_view.dart';
import 'package:maths_club/widgets/section_app_bar.dart';

import '../utils/components.dart';

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
    required PostType type}) {
  return Padding(
    padding: (type == PostType.quiz)
        ? position.padding
        : const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 6.0),
    child: Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
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
                child: Text(title,
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(description,
                  style: Theme.of(context).textTheme.bodyText2,
                  overflow: TextOverflow.ellipsis),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuizView()),
                      );
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
  );
}

/// This is the section page which allows for access to quizzes and posts
class SectionPage extends StatefulWidget {
  Map<String, dynamic> userData;
  String title;
  String? id;
  SectionPage({Key? key, required this.userData, required this.title, required this.id}) : super(key: key);

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// main body
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('Group',
            isEqualTo: widget.id)
            .snapshots(),
        builder: (context, postsSnapshot) {
          if (postsSnapshot.connectionState == ConnectionState.active) {
            List quizzes = [];
            List posts = [];

            for (var i = 0; i < (postsSnapshot.data?.docs.length ?? 0); i++) {
              var doc = postsSnapshot.data?.docs[i];

              // If the start date the is before the current time and the end date is after the current time, is inside quiz period.
              if (doc?['Start Date'].toDate().isBefore(DateTime.now()) && doc?['End Date'].toDate().isAfter(DateTime.now())) {
                // Gets the JSON version of the quiz
                Map<String, dynamic> json = postsSnapshot.data?.docs[i].data() as Map<String, dynamic>;
                quizzes.add(json);
              } else {
                // Gets the JSON version of the post
                Map<String, dynamic> json = postsSnapshot.data?.docs[i].data() as Map<String, dynamic>;
                posts.add(json);
              }
            }

            if (posts.isEmpty && quizzes.isEmpty) {
              return SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  header(widget.title, context,
                      fontSize: 30, backArrow: true),
                  const Expanded(child: Center(child: Text("No posts yet!"))),
                ]),
              );
            } else {
              return ListView(
                children: [
                  SectionAppBar(
                      context,
                      title: widget.title,
                      userData: widget.userData
                  ),
                  // Don't show "quizzes" title if there are no posts
                  (quizzes.isNotEmpty) ? Padding(
                    padding: const EdgeInsets.fromLTRB(26, 16, 0, 16),
                    child: Text("Active Quizzes",
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline4
                            ?.copyWith(color: Theme
                            .of(context)
                            .primaryColorLight)),
                  ) : const SizedBox.shrink(),
                  SizedBox(
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
                              type: PostType.quiz);
                        },
                      ),
                    ),
                  ),
                  // Don't show "posts" title if there are no posts
                  (posts.isNotEmpty) ? Padding(
                    padding: const EdgeInsets.fromLTRB(26, 16, 0, 16),
                    child: Text("Posts",
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline4
                            ?.copyWith(color: Theme
                            .of(context)
                            .primaryColorLight)),
                  ) : const SizedBox.shrink(),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return postCard(context, title: posts[index]['Title'],
                            description: posts[index]['Description'],
                            position: PositionPadding.start,
                            type: PostType.post);
                      }),
                ],
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}
