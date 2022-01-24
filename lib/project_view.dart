import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'api_util.dart';
import 'issue_view.dart';

class ProjectView extends StatefulWidget {
  final userParameter user;
  final String projectId;
  final String jql;
  final dynamic title;
  final String? subTitle;
  final String? fullView;

  ProjectView(
      {Key? key,
      required this.user,
      required this.projectId,
      required this.jql,
      this.title,
      this.subTitle,
      this.fullView});

  @override
  State<ProjectView> createState() => _ProjectViewState(
      user: this.user,
      projectId: this.projectId,
      jql: this.jql,
      title: this.title,
      subTitle: this.subTitle,
      fullView: this.fullView);
}

class _ProjectViewState extends State<ProjectView> {
  final userParameter user;
  final String projectId;
  final String jql;
  final dynamic title;
  final String? subTitle;
  final String? fullView;
  late Future<List<dynamic>> _issueList;

  _ProjectViewState(
      {Key? key,
      required this.user,
      required this.projectId,
      required this.jql,
      this.title,
      this.subTitle,
      this.fullView});

  @override
  void initState() {
    _issueList = runApiGet(
        user.userName, user.password, Uri.parse(user.companyLink + jql));
    super.initState();
  }

  Future<dynamic> _callPostApi(comment, transactionCode, key) async {
    var apiUrl = "";
    Map body = {};
    if (transactionCode != "0") {
      body = {
        "update": {
          "comment": [
            {
              "add": {"body": "${comment}"}
            }
          ]
        },
        "transition": {"id": "${transactionCode}"}
      };
      apiUrl = "${user.companyLink}/rest/api/2/issue/${key}/transitions";
    } else {
      //Ha nulla, akkor csak komment hozzáadása
      body = {
        "body": "${comment}"
      };
      apiUrl = "${user.companyLink}/rest/api/2/issue/${key}/comment";
    }
    return await runApiPost(user.userName, user.password, apiUrl, body);
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

  String _szoveg(location, snapshotItem) {
    String retVal = "";
    bool tobbSoros = false;
    List<String> sorok = location.toString().split(";");
    if (tobbSoros) retVal = retVal + "/n";
    tobbSoros = true;
    for (String sor in sorok) {
      List<String> mezok = sor.toString().split(",");
      if (mezok[0].substring(mezok[0].length - 1, mezok[0].length) == ":") {
        retVal = retVal + mezok[0] + " ";
        mezok.removeAt(0);
      }
      if (mezok.length == 1) {
        retVal = retVal + snapshotItem[mezok[0]];
      } else if (mezok.length == 2) {
        retVal = retVal + snapshotItem[mezok[0]][mezok[1]];
      } else if (mezok.length == 3) {
        var ertek;
        if (mezok[2] == ('0') || mezok[2] == ('1') || mezok[2] == ('0')) {
          ertek = int.parse(mezok[2]);
        } else {
          ertek = mezok[2];
        }
        retVal = retVal + snapshotItem[mezok[0]][mezok[1]][ertek];
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
        retVal = retVal + snapshotItem[mezok[0]][mezok[1]][ertek][ertek2];
      }
    }
    return stringNormalize(retVal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName),
      ),
      body: AnimatedContainer(
        duration: Duration(seconds: 5),
        child: FutureBuilder<List<dynamic>>(
            future: _issueList,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: Colors.grey,
                      shadowColor: Colors.black,
                      elevation: 10,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                              leading: SizedBox(
                                height: 50.0,
                                width: 50.0, // fixed width and height
                                child: Image.asset("assets/images/bnref.jpg"),
                              ),
                              title: Text(
                                _szoveg(title, snapshot.data[index]),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle:
                                  Text(_szoveg(subTitle, snapshot.data[index])),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => IssueView(
                                            user: user,
                                            snapshotItem: snapshot.data[index],
                                            projectId: projectId,
                                            fullView: fullView))).then((value) {
                                  Future result = _callPostApi(value[0], value[1], value[2]);
                                  result.then((result) {
                                    if (mounted) {
                                      _issueList = runApiGet(user.userName, user.password, Uri.parse(user.companyLink + jql));
                                      setState(() {});
                                    }
                                  });
                                });
                              }),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}
