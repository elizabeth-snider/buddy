import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:core';
import 'dart:convert';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'dataHelper.dart';
import 'transactionCLASS.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return CupertinoApp(
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: Default(),
    );
  }
}

class Default extends StatefulWidget {
  @override
  _DefaultState createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  int _currentPage = 0;

  static List<Widget> _bothPages = <Widget>[
    HomePage(),
    HistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bothPages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: '',
          ),
          new BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.history),
            label: '',
          ),
        ],
        currentIndex: _currentPage,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _c = new TextEditingController();
  double budget = 0.0;
  int spot = 0;
  AnimationController _ac;
  var dbHelper;
  Future<List<TransactionClass>> allTransactions;
  String name;
  String cat;

  refreshList() {
    setState(() {
      allTransactions = dbHelper.getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widgets(context, _c),
    );
  }

  @override
  void initState() {
    super.initState();
    loadBudget();
    dbHelper = DBHelper();
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  Widget widgets(context, _c) {
    return Column(
      children: [
        Container(
            height: 200,
            child: Align(
              alignment: Alignment.center,
              child: budgetText(),
            )),
        row(context, _c),
        Container(
            height: 200,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: originalButton(context, _c))),
      ],
    );
  }

  Widget row(context, _c) {
    return Row(
      children: [
        Expanded(
            child: Container(
                width: 200,
                height: 250,
                child: Align(
                  alignment: Alignment.center,
                  child: expenseButton(context, _c),
                ))),
        Expanded(
            child: Container(
                width: 200,
                height: 250,
                child: Align(
                  alignment: Alignment.center,
                  child: addButton(context, _c),
                ))),
      ],
    );
  }

  Widget expenseButton(context, _c) {
    return CupertinoButton(
        child: Icon(CupertinoIcons.minus),
        onPressed: () {
          showCupertinoDialog(
              context: context,
              builder: (
                BuildContext context,
              ) =>
                  CupertinoPopupSurface(
                      //isSurfacePainted: false,
                      child: Center(
                          child: Container(
                              height: 300,
                              width: 300,
                              child: Center(
                                  child: Column(
                                children: <Widget>[
                                  new CupertinoTextField(
                                    padding: EdgeInsets.all(2),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    controller: _c,
                                  ),
                                  categories(),
                                  CupertinoButton.filled(
                                      child: new Text("enter"),
                                      onPressed: () {
                                        double change = -double.parse(_c.text);
                                        if (cat == null) {
                                          cat = 'other';
                                        }
                                        TransactionClass t =
                                            TransactionClass(null, cat, change);
                                        dbHelper.save(t);
                                        refreshList();
                                        setState(() {
                                          budget = budget + change;
                                          addBudgetToSP();
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        _c.clear();
                                      }),
                                ],
                              ))))));
        });
  }

  Widget addButton(context, _c) {
    return CupertinoButton(
        child: Icon(CupertinoIcons.add),
        onPressed: () {
          showCupertinoDialog(
              context: context,
              builder: (
                BuildContext context,
              ) =>
                  CupertinoPopupSurface(
                      //isSurfacePainted: false,
                      child: Center(
                          child: Container(
                              height: 300,
                              width: 300,
                              child: Center(
                                  child: Column(
                                children: <Widget>[
                                  new CupertinoTextField(
                                    padding: EdgeInsets.all(2),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    controller: _c,
                                  ),
                                  categories(),
                                  CupertinoButton.filled(
                                      child: new Text("enter"),
                                      onPressed: () {
                                        double change = double.parse(_c.text);
                                        if (cat == null) {
                                          cat = 'other';
                                        }
                                        TransactionClass t =
                                            TransactionClass(null, cat, change);
                                        dbHelper.save(t);
                                        refreshList();
                                        setState(() {
                                          budget = budget + change;
                                          addBudgetToSP();
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        _c.clear();
                                      }),
                                ],
                              ))))));
        });
  }

  Widget originalButton(context, _c) {
    return CupertinoButton.filled(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: const Text('enter your budget here'),
        onPressed: () {
          showCupertinoDialog(
              context: context,
              builder: (
                BuildContext context,
              ) =>
                  CupertinoPopupSurface(
                      //isSurfacePainted: false,
                      child: Center(
                          child: Container(
                              height: 300,
                              width: 300,
                              child: Center(
                                  child: Column(
                                children: [
                                  CupertinoTextField(
                                    padding: EdgeInsets.all(2),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    controller: _c,
                                  ),
                                  CupertinoButton.filled(
                                      child: new Text("enter"),
                                      onPressed: () {
                                        dbHelper.deleteAll();
                                        refreshList();
                                        setState(() {
                                          budget = double.parse(_c.text);
                                          addBudgetToSP();
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        _c.clear();
                                      }),
                                ],
                              ))))));
        });
  }

  Widget categories() {
    bool pressed = false;
    return Column(children: [
      Row(
        children: [
          Expanded(
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: IconButton(
                      alignment: Alignment.center,
                      icon: FaIcon(FontAwesomeIcons.utensils),
                      color: pressed ? Colors.blue : Colors.black,
                      onPressed: () {
                        setState(() {
                          if (pressed) {
                            pressed = false;
                          } else {
                            pressed = true;
                          }
                          cat = "food/drinks";
                        });
                      }))),
          Expanded(
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: IconButton(
                      alignment: Alignment.center,
                      icon: FaIcon(FontAwesomeIcons.shoppingBasket),
                      color: pressed ? Colors.blue : Colors.black,
                      onPressed: () {
                        setState(() {
                          if (pressed) {
                            pressed = false;
                          } else {
                            pressed = true;
                          }
                          cat = "groceries";
                        });
                      }))),
          Expanded(
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: IconButton(
                      alignment: Alignment.center,
                      icon: FaIcon(FontAwesomeIcons.tshirt),
                      color: pressed ? Colors.blue : Colors.black,
                      onPressed: () {
                        setState(() {
                          if (pressed) {
                            pressed = false;
                          } else {
                            pressed = true;
                          }
                          cat = "clothing";
                        });
                      }))),
        ],
      ),
      Row(
        children: [
          Expanded(
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: IconButton(
                      alignment: Alignment.center,
                      icon: FaIcon(FontAwesomeIcons.fileInvoiceDollar),
                      color: pressed ? Colors.blue : Colors.black,
                      onPressed: () {
                        setState(() {
                          if (pressed) {
                            pressed = false;
                          } else {
                            pressed = true;
                          }
                          cat = "bills";
                        });
                      }))),
          Expanded(
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: IconButton(
                      alignment: Alignment.center,
                      icon: FaIcon(FontAwesomeIcons.firstAid),
                      color: pressed ? Colors.blue : Colors.black,
                      onPressed: () {
                        setState(() {
                          if (pressed) {
                            pressed = false;
                          } else {
                            pressed = true;
                          }
                          cat = "health";
                        });
                      }))),
          Expanded(
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: IconButton(
                      alignment: Alignment.center,
                      icon: FaIcon(FontAwesomeIcons.user),
                      color: pressed ? Colors.blue : Colors.black,
                      onPressed: () {
                        setState(() {
                          if (pressed) {
                            pressed = false;
                          } else {
                            pressed = true;
                          }
                          cat = "personal/other";
                        });
                      }))),
        ],
      )
    ]);
  }

  Widget budgetText() {
    String _budgetString = "\$" + budget.toStringAsFixed(2);
    return Text(
      _budgetString,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 40,
      ),
    );
  }

  addBudgetToSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('total', budget);
      budget = (prefs.getDouble('total') ?? 0);
    });
  }

  loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      budget = (prefs.getDouble('total') ?? 0);
    });
  }
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() {
    return _HistoryPageState();
  }
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<TransactionClass>> allTransactions;
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    refreshList();
  }

  refreshList() {
    setState(() {
      allTransactions = dbHelper.getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('history'),
        ),
        SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.only(top: 8),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return list();
              },
              childCount: 1,
            ))),
      ],
    );
  }

  SingleChildScrollView dataTable(List<TransactionClass> transactions) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Amount')),
          ],
          rows: transactions
              .map((transaction) => DataRow(cells: [
                    DataCell(Text(transaction.category)),
                    DataCell(Text(transaction.val.toString())),
                  ]))
              .toList(),
        ));
  }

  list() {
    return Material(
        color: Colors.white,
        child: FutureBuilder(
            future: allTransactions,
            builder: (context, snapshot) {
              if (null == snapshot.data || snapshot.data.length == 0) {
                return Text('No Transactions');
              } else if (snapshot.hasData) {
                return dataTable(snapshot.data);
              }
              return CircularProgressIndicator();
            }));
  }
}
