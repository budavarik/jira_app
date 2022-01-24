import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'api_util.dart';
import 'models.dart';
import 'projects_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<String> _cegValaszto = [];
  Map<String, String> _cegValasztoMap = {};
  String _selectedLocation = "";
  String title = "JIRA application";
  userParameter loginUser = new userParameter(userId: "", userName: "", password: "", companyLink: "", displayName: "");

  @override
  void initState() {
    setCegek().then((_cegek) => _cegek);
    super.initState();
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.red,
              content: Text(message),
            ));
  }

  Future<dynamic> setCegek() {
    Future _cegek = getCrossApp(
        "https://crossapp.hu/jira_app/application/api/get_cegek.php");
    _cegek.then((_cegek) {
      setState(() {
        int i = 0;
        for (dynamic _company in _cegek) {
          _cegValaszto.add(_company['companyName']);
          _cegValasztoMap.putIfAbsent(
              _company['companyName'], () => _company['companyLink']);
          if (i == 0) {
            _selectedLocation = _company['companyName'];
            i++;
          }
        }
      });
    });
    return _cegek;
  }

  //Ellenőrizni kell, hogy jók a megadott user adatok. Ezt úgy lehet, hogy csinálok egy lekérdezést
  //Lépései:
  //         1. Meg kell keresnem, hogy az adott cégnek mi a linkje
  //         2. Bekérdezek: /rest/api/2/user/search?username=kbudavari@bnref
  userParameter _tesztUser(userName, password) {

    var _link = _cegValasztoMap[_selectedLocation].toString() +
        "/rest/api/2/user/search?username=" +
        userName;
    Future _checkUser = runApiGet(userName, password, Uri.parse(_link));
    _checkUser.then((_checkUser) {
      if (_checkUser.length == 1) {
        setState(() {
          var _user = _checkUser[0];
          //Ellenőrzöm, h télleg az a user?
          if (_user['emailAddress'] == userName) {
            //Ha az a user, megkeresem a saját adatbázisban, h elrakhassam az adatait
//            Future _checkcrossappUser = runApiGet(
//                "",
//                "",
//                Uri.parse(
//                    'https://crossapp.hu/jira_app/application/api/get_user.php?userName=${userName}&companyName=${_selectedLocation}'));
//            _checkcrossappUser.then((_checkcrossappUser) {
            Future _checkcrossappUser = getCrossApp(
                "https://crossapp.hu/jira_app/application/api/get_user.php?userName=${userName}&companyName=${_selectedLocation}");
            _checkcrossappUser.then((_checkcrossappUser) {
              if (_checkcrossappUser.length == 1) {
                var _userId = _checkcrossappUser[0]['userId'];
                var _userName = _checkcrossappUser[0]['jiraUserName'];
                var _password = password;
                var _companyLink =
                    _cegValasztoMap[_selectedLocation].toString();
                var _displayName = _checkcrossappUser[0]['userDisplayName'];
                loginUser = userParameter(
                                userId: _userId,
                                userName: _userName,
                                password: _password,
                                companyLink: _companyLink,
                                displayName: _displayName);
                insertLog(_userId, "${_userName} sikeres bejelentkezés");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => ProjectList(user: loginUser)));
              }
            });

            //user = new userParameter(userId: userId, userName: userName, password: password, companyLink: companyLink, displayName: displayName)
            //user.displayName = _user['displayName'];

            //Meg kell keresni a userId-t a crossApp users táblában. Később kell:
            //crossApp userId, userName, password. De ezt elég a következő oldalon.
          }
        });
      } else {
        showAlert(context, "Hiba az authentikációnál!");
      }
    });
    return loginUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/b2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      //Email field
                      SizedBox(
                        width: 320,
                        height: 60,
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.white),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 5.0),
                            filled: true,
                            fillColor: Colors.grey[400]?.withOpacity(0.4),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Email",
                            labelText: "Email",
                            hintStyle: const TextStyle(
                                color: Colors.white, fontSize: 25.0),
                          ),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 24),
                      ),
                      //Password field
                      SizedBox(
                        width: 320,
                        height: 60,
                        child: TextFormField(
                          obscureText: true,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.password, color: Colors.white),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 5.0),
                            filled: true,
                            fillColor: Colors.grey[400]?.withOpacity(0.4),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Password",
                            labelText: "Password",
                              hintStyle: const TextStyle(
                                color: Colors.white, fontSize: 25.0),
                          ),
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 24),
                      ),

                      DropdownButton<String>(
                        hint: Text('Please choose a location'),
                        // Not necessary for Option 1
                        value: _selectedLocation,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocation = newValue!;
                          });
                        },
                        items: _cegValaszto.map((location) {
                          return DropdownMenuItem(
                            child: Text(location),
                            value: location,
                          );
                        }).toList(),
                      ),

                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 24),
                      ),

                      //Login button
                      OutlinedButton(
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              backgroundColor: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: Colors.blue,
                          shape: const StadiumBorder(),
                          side: const BorderSide(width: 5, color: Colors.blue),
                        ),
                        onPressed: () {
                          //_tesztUser(emailController.value.text.toString(), passwordController.value.text.toString());
                          _tesztUser("kbudavari@bnref.hu", "KB@@3334");
                          if (loginUser.userId != "") {
/*                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => {} ),
                            );
*/
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
