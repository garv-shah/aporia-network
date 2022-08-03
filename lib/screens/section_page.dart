import 'package:flutter/material.dart';
import 'package:maths_club/screens/auth/landing_page.dart';
import 'package:maths_club/screens/quiz_view.dart';
import 'package:maths_club/widgets/section_app_bar.dart';

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
  SectionPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// main body
      body: ListView(
        children: [
          SectionAppBar(
            context,
            title: "Senior",
            userData: widget.userData
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 16, 0, 16),
            child: Text("Active Quizzes",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: Theme.of(context).primaryColorLight)),
          ),
          SizedBox(
            height: 175,
            child: Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  postCard(context,
                      title: "T2 W8",
                      description: "Polynomial Applications",
                      position: PositionPadding.start,
                      type: PostType.quiz),
                  postCard(context,
                      title: "T2 W7",
                      description: "Number Theory Fun!",
                      type: PostType.quiz),
                  postCard(context,
                      title: "2022 CAT",
                      description:
                      "Computational & Algorithmic Thinking Competition",
                      position: PositionPadding.end,
                      type: PostType.quiz),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 16, 0, 16),
            child: Text("Posts",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: Theme.of(context).primaryColorLight)),
          ),
          postCard(context, title: "Term 2 Week 6", description: "Senior Problems for Term 2 Week 6", position: PositionPadding.start, type: PostType.post),
          postCard(context, title: "Term 2 Week 5", description: "Senior Problems for Term 2 Week 5", type: PostType.post),
          postCard(context, title: "Term 2 Week 4", description: "Senior Problems for Term 2 Week 4", type: PostType.post),
          postCard(context, title: "Term 2 Week 3", description: "Senior Problems for Term 2 Week 3", type: PostType.post),
          postCard(context, title: "Term 2 Week 2", description: "Senior Problems for Term 2 Week 2", type: PostType.post),
          postCard(context, title: "Term 2 Week 1", description: "Senior Problems for Term 2 Week 1", position: PositionPadding.start, type: PostType.post),
        ],
      ),
    );
  }
}
