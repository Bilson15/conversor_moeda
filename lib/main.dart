import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Home(),
    theme: ThemeData(
        hintColor: Colors.white,
        primaryColor: Colors.amber,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.white),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http
      .get(Uri.parse('https://api.hgbrasil.com/finance?key=9a569215'));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          title: const Text("\$ Conversor de Moeda \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: FutureBuilder<Map>(
              future: getData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: Text(
                        "Carregando dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      dolar =
                          snapshot.data!["results"]["currencies"]["USD"]["buy"];
                      euro =
                          snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 30.0, 0, 0)),
                            const Icon(
                              Icons.monetization_on,
                              size: 150.0,
                              color: Colors.amber,
                            ),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 30.0)),
                            buildTextField(
                                "Reais", "R\$", realController, _realChanged),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 14.0, 0, 0)),
                            buildTextField("Dólares", "US", dolarController,
                                _dolarChanged),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 14.0, 0, 0)),
                            buildTextField(
                                "Euros", "€", euroController, _euroChanged),
                          ],
                        ),
                      );
                    }
                }
              }),
        ));
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controllers, Function f) {
  return TextFormField(
    controller: controllers,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: const OutlineInputBorder(),
        prefixText: prefix,
        contentPadding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0)),
    style: const TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: (value) => f(value),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
