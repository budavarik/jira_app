import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jira_app/models.dart';

import 'api_util.dart';

class IssueView extends StatefulWidget {
  final userParameter user;
  final String? fullView;
  final String projectId;
  final Map<String, dynamic> snapshotItem;

  IssueView(
      {Key? key,
      required this.user,
      required this.snapshotItem,
      required this.projectId,
      this.fullView})
      : super(key: key);

  @override
  State<IssueView> createState() => _IssueViewState(
      user: this.user,
      snapshotItem: this.snapshotItem,
      projectId: this.projectId,
      fullView: this.fullView);
}

class _IssueViewState extends State<IssueView> {
  final userParameter user;
  final String? fullView;
  final String projectId;
  final Map<String, dynamic> snapshotItem;
  late Future<List<dynamic>> answerList;
  int darab = 0;
  Map<int, String> answerNameMap = {};
  Map<String, String> answerTransitionMap = {};
  List<String> issueRows = [];
  bool tobbSoros = false;
  int sorokSzama = 0;
  TextEditingController commentController = TextEditingController();

  _IssueViewState(
      {Key? key,
      required this.user,
      required this.snapshotItem,
      required this.projectId,
      this.fullView});

  int selectedIndex = 0;

  Future<List<dynamic>> answerButtons() async {
    answerList = getCrossApp(
        'https://crossapp.hu/jira_app/application/api/get_projectAnswers.php?projectId=${projectId}');
    answerList.then((_answerList) {
      int i = 0;
      darab = _answerList.length;
      for (dynamic answer in _answerList) {
        answerNameMap[i] = answer['transitionName'].toString();
        answerTransitionMap[answer['transitionName']] = answer['transitionId'];
        i++;
      }
    });
    return answerList;
  }

  @override
  void initState() {
    answerList = answerButtons();
    issueRows = fullView.toString().split(";");
    super.initState();
  }

  String stringNormalize(dynamic szoveg) {
    String retVal = "";
    if (szoveg == "" || szoveg == null) {
      retVal = "";
    } else {
      retVal = szoveg;
    }
    return retVal;
  }

  String _keretSzoveg(sorokSzama, aktSor, issueRows) {
    String retVal = "";
    for (int i = aktSor; i < aktSor + sorokSzama; i++) {
      if (i == aktSor) {
        retVal = _szoveg(issueRows[i], snapshotItem).toString();
      } else {
        String tmpString = _szoveg(issueRows[i], snapshotItem).toString();
        if (tmpString != "") {
          retVal = retVal + "\n" + tmpString;
        }
      }
    }
    return retVal;
  }

  String _szoveg(location, snapshotItem) {
    String retVal = "";
    List<String> mezok = location.toString().split(",");
    if (mezok[0].substring(0, 2) == "##") {
      //Ha az első ##keret, akkor levágom és úgy nézem tovább
      mezok.removeAt(0);
    }
    if (mezok[0].substring(mezok[0].length - 1, mezok[0].length) == ":") {
      retVal = retVal + mezok[0] + " ";
      mezok.removeAt(0);
    }
    if (mezok.length == 1) {
      retVal = retVal + snapshotItem[mezok[0]];
    } else if (mezok.length == 2) {
      retVal =
          retVal + stringNormalize(snapshotItem[mezok[0]][mezok[1]].toString());
    } else if (mezok.length == 3) {
      var ertek;
      if (mezok[2] == ('0') || mezok[2] == ('1') || mezok[2] == ('0')) {
        ertek = int.parse(mezok[2]);
      } else {
        ertek = mezok[2];
      }
      if (snapshotItem[mezok[0]][mezok[1]] != null) {
        retVal = retVal +
            stringNormalize(snapshotItem[mezok[0]][mezok[1]][ertek].toString());
      } else {
        retVal = "";
      }
    } else if (mezok.length == 4) {
      var ertek;
      if (mezok[2] == ('0') || mezok[2] == ('1') || mezok[2] == ('0')) {
        ertek = int.parse(mezok[2]);
      } else {
        ertek = mezok[2];
      }
      var ertek2;
      if (mezok[3] == ('0') || mezok[3] == ('1') || mezok[3] == ('0')) {
        ertek2 = int.parse(mezok[3]);
      } else {
        ertek2 = mezok[3];
      }
      retVal = retVal +
          stringNormalize(
              snapshotItem[mezok[0]][mezok[1]][ertek][ertek2].toString());
    }
    return stringNormalize(retVal);
  }


  void showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.red,
          content: Text(message),
        ));
  }

//Mit kell csinálni?
  String handleClick(String value) {
    String transactionCode = answerTransitionMap[value].toString();
    if (commentController.value.text != "") {
      insertLog(user.userId, "${user.userName}: ${snapshotItem['key']}: ${value} tranzakció indítása. Comment: ${commentController.value.text}");
      Navigator.pop(context, [commentController.value.text, transactionCode, snapshotItem['key']]);
    } else {
      showAlert(context, "A comment hozzáadása kötelező!");
    }


    return transactionCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snapshotItem['key']),
        actions: <Widget>[
          PopupMenuButton<String>(
            color: Colors.grey[200],
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {
                for (var answer in answerNameMap.values) answer.toString()
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: issueRows.length,
            itemBuilder: (BuildContext context, int index) {
              if (issueRows[index].substring(0, 2).toString() != "##" &&
                  !tobbSoros) {
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 20, 5, 0),
                  child: ListTile(
                    title: Text(_szoveg(issueRows[index], snapshotItem)),
                  ),
                );
              } else if (issueRows[index].substring(0, 2).toString() == "##" &&
                  !tobbSoros) {
                sorokSzama = int.parse(issueRows[index]
                    .substring(2, issueRows[index].indexOf(",")));
                tobbSoros = sorokSzama > 0;
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 20, 5, 0),
                  child: Column(
                    children: [
                      Text(
                        issueRows[index].substring(
                            issueRows[index].indexOf(",") + 1,
                            issueRows[index].length),
                        style: const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            _keretSzoveg(sorokSzama, index + 1, issueRows),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                if (sorokSzama > 0) {
                  sorokSzama--;
                  tobbSoros = sorokSzama > 0;
                }
                return Container();
              }
            }
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'Megjegyzés hozzáadása',
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.bottom,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add_comment),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0),
                  filled: true,
                  fillColor: Colors.grey[100],
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  hintText: "Add comment....",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
                ),
                controller: commentController,
                keyboardType: TextInputType.name,
              ),
            ),
      ])),
    );
  }
}

