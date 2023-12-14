import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter/services.dart';
import 'package:aporia_app/screens/section_views/admin_view/create_user_view.dart';
import 'package:aporia_app/screens/section_views/admin_view/manage_user_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:aporia_app/screens/home_page.dart';

import '../../../utils/config/config.dart';

class UserModel extends ISuspensionBean {
  String username;
  String role;
  String email;
  String? profilePicture;
  String? pfpType;
  String? userType;
  String id;

  UserModel({
    required this.username,
    required this.role,
    required this.email,
    required this.profilePicture,
    required this.pfpType,
    required this.userType,
    required this.id,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        role = json['role'],
        email = json['email'],
        profilePicture = json['profilePicture'],
        pfpType = json['pfpType'],
        userType = json['userType'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'username': username,
        'role': role,
        'profilePicture': profilePicture,
        'pfpType': pfpType,
        'userType': userType,
        'id': id
      };

  @override
  String getSuspensionTag() => role;
}

class UsersPage extends StatefulWidget {
  UsersPage(
      {Key? key,
      this.orderID,
      this.chosenUser})
      : super(key: key);
  final String? orderID;
  UserModel? chosenUser;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  /// Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  List<UserModel> userList = [];
  // the displayed user list after searching/sorting
  List<UserModel> displayedUserList = [];

  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void loadData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('userInfo').get();
    QuerySnapshot<Map<String, dynamic>> roles =
        await FirebaseFirestore.instance.collection('roles').get();

    // Get data from docs and convert map to List
    userList = querySnapshot.docs.map((user) {
      Map<String, dynamic> userMap = user.data() as Map<String, dynamic>;
      String userRole = "Unknown Role";

      for (var role in roles.docs) {
        if (role.data()['members'].contains(user.id) && userRole == "Unknown Role") {
          userRole = role.data()['tag'];
        }
      }

      return UserModel(
        username: userMap['username'],
        role: userRole,
        email: userMap['email'],
        profilePicture: userMap['profilePicture'],
        pfpType: userMap['pfpType'],
        userType: userMap['userType'],
        id: user.id,
      );
    }).toList();

    // remove yourself
    // userList.remove(userList.firstWhere(
    //         (element) => element.id == FirebaseAuth.instance.currentUser!.uid));

    _handleList(userList);
  }

  void _handleList(List<UserModel> list) {
    displayedUserList.clear();

    if (list.isEmpty) {
      setState(() {});
      return;
    }

    displayedUserList.addAll(list);

    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(displayedUserList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(displayedUserList);

    setState(() {});

    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: 0);
    }
  }

  Widget getSusItem(BuildContext context, String tag, {double susHeight = 40}) {
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16.0),
      color: const Color.fromARGB(40, 197, 203, 209),
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: false,
        style: const TextStyle(
          fontSize: 14.0,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  Widget getListItem(BuildContext context, UserModel model,
      {double susHeight = 40}) {
    return ListTile(
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeInOutQuart,
        switchOutCurve: Curves.easeInOutQuart,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: (widget.chosenUser?.id == model.id)
            ? const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.done),
              )
            : SizedBox(
          width: 40,
              height: 40,
              child: Hero(
                  tag: '${model.username} Profile Picture',
                  child: fetchProfilePicture(
                      model.profilePicture, model.pfpType, model.username)),
            ),
      ),
      title: Text(model.username),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ManageUserPage(userInfo: model, canEdit: true,)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateUser()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Manage Users'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColorLight),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            }),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 225, 226, 230),
                      width: 0.33),
                  color: const Color.fromARGB(255, 239, 240, 244),
                  borderRadius: BorderRadius.circular(12)),
              child: TextField(
                autofocus: false,
                onChanged: (text) {
                  if (text.isEmpty) {
                    _handleList(userList);
                  } else {
                    // handling search
                    List<UserModel> list = userList.where((user) {
                      return user.username
                          .toLowerCase()
                          .contains(text.toLowerCase());
                    }).toList();
                    _handleList(list);
                  }
                },
                controller: textEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF333333),
                    ),
                    suffixIcon: Offstage(
                      offstage: textEditingController.text.isEmpty,
                      child: InkWell(
                        onTap: () {
                          textEditingController.clear();
                          _handleList(userList);
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'Search Users',
                    hintStyle: const TextStyle(color: Color(0xFF999999))),
              ),
            ),
            Expanded(
              child: AzListView(
                data: displayedUserList,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: displayedUserList.length,
                itemBuilder: (BuildContext context, int index) {
                  UserModel model = displayedUserList[index];
                  return getListItem(context, model);
                },
                itemScrollController: itemScrollController,
                susItemBuilder: (BuildContext context, int index) {
                  UserModel model = displayedUserList[index];
                  return getSusItem(context, model.getSuspensionTag());
                },
                indexBarOptions: const IndexBarOptions(
                  needRebuild: true,
                  selectTextStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  selectItemDecoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  indexHintWidth: 96,
                  indexHintHeight: 97,
                  indexHintDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/ic_index_bar_bubble_white.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  indexHintAlignment: Alignment.centerRight,
                  indexHintTextStyle:
                      TextStyle(fontSize: 24.0, color: Colors.black87),
                  indexHintOffset: Offset(-30, 0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
