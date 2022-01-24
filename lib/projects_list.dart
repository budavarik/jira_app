import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'api_util.dart';
import 'project_view.dart';

class ProjectList extends StatefulWidget {
  final userParameter user;

  ProjectList({Key? key, required this.user});

  @override
  State<ProjectList> createState() => _ProjectListState(user: this.user);
}

class _ProjectListState extends State<ProjectList> {
  bool checkedValue = false;
  final userParameter user;
  late Future<List<dynamic>> _projetsList;

  _ProjectListState({Key? key, required this.user});

  @override
  void initState() {
    super.initState();
    _projetsList = getCrossApp(
        'https://crossapp.hu/jira_app/application/api/get_projects.php?userId=${user.userId}').then((_projetsList) => _projetsList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
            future: _projetsList,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return ListView.builder(
                  itemExtent: 60,
                  padding: const EdgeInsets.all(25),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SingleChildScrollView(
                      child: Column(children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              fixedSize: const Size(350, 50)),
                          onPressed: () {
                            insertLog(user.userId, "${user.userName}: ${snapshot.data[index]['projectName']} (${snapshot.data[index]['projectId']}) projekt kiválasztása");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectView(user: user, projectId: snapshot.data[index]['projectId'], jql: snapshot.data[index]['jql'], title: snapshot.data[index]['listTitle'],
                                                                      subTitle: snapshot.data[index]['listSubTitle'], fullView: snapshot.data[index]['fullView'])));
                          },
                          child: Text(snapshot.data[index]['projectName']),
                        ),
                      ]),
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
