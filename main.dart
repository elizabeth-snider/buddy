import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'data.dart';
import 'package:path/path.dart';
import 'package:budget/models/transaction.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: new ThemeData(primaryColor: Colors.white),
        debugShowCheckedModeBanner: false,
        title: 'welcome to budge',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('welcome to budge'),
          ),
          body: BothPages(),
        ));
  }
}


class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  TextEditingController _c = new TextEditingController();
  double budget = 0.0;
  Widget build(BuildContext context) {
    return buildWidgets(context, _c);
  }

  @override
  void initState() {
    super.initState();
    loadBudget();
  }

  Widget buildWidgets(context, _c) {
    return Column(
      children: [
        Container(
            height: 100,
            child: Align(
              alignment: Alignment.center,
              child: budgetText(),
            )),
        row(context, _c),
        Container(
            height: 80,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: originalButton(context, _c))),
      ],
    );
  }

  Widget row(context, _c) {
    return Row(
      children: [
        Container(
            width: 200,
            height: 250,
            child: Align(
              alignment: Alignment.center,
              child: expenseButton(context, _c),
            )),
        Container(
            width: 200,
            height: 350,
            child: Align(
              alignment: Alignment.center,
              child: addButton(context, _c),
            )),
      ],
    );
  }

  Widget expenseButton(context, _c) {
    return Material(
        child: Center(
            child: Ink(
      decoration: ShapeDecoration(
        color: Colors.red,
        shape: CircleBorder(),
      ),
      child: IconButton(
          alignment: Alignment.center,
          icon: Icon(Icons.minimize),
          color: Colors.black,
          onPressed: () {
            showDialog(
                child: new Dialog(
                    insetPadding: EdgeInsets.all(70),
                    child: new Column(
                      children: <Widget>[
                        new TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: 'enter your expense here'),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _c,
                        ),
                        RaisedButton(
                            child: new Text("enter"),
                            onPressed: () {
                              setState(() {
                                budget = budget - double.parse(_c.text);
                                addBudgetToSF();
                              });
                              Navigator.pop(context);
                              _c.clear();
                            }),
                      ],
                    )),
                context: context);
          }),
    )));
  }

  Widget addButton(context, _c) {
    return Material(
        child: Center(
            child: Ink(
      decoration: ShapeDecoration(
        color: Colors.lightGreen,
        shape: CircleBorder(),
      ),
      child: IconButton(
          icon: Icon(Icons.add),
          color: Colors.black,
          onPressed: () {
            showDialog(
                child: new Dialog(
                    insetPadding: EdgeInsets.all(70),
                    child: new Column(
                      children: <Widget>[
                        new TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: 'enter your expense here'),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _c,
                        ),
                        RaisedButton(
                            child: new Text("enter"),
                            onPressed: () {
                              setState(() {
                                budget = budget + double.parse(_c.text);
                                addBudgetToSF();
                              });

                              var newTransaction = Transactions(val: _c.text,category: 'idk yet' );
                              DBProvider.db.newTransaction(newTransaction);
                              Navigator.pop(context);
                              _c.clear();
                            }),
                      ],
                    )),
                context: context);
          }),
    )));
  }

  Widget originalButton(context, _c) {
    return RaisedButton(
        textColor: Colors.black,
        child: const Text('enter your budget here'),
        onPressed: () {
          setState(() {
            showDialog(
                child: new Dialog(
                    insetPadding: EdgeInsets.all(70),
                    child: new Column(
                      children: <Widget>[
                        new TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'enter your budget here'),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _c,
                        ),
                        RaisedButton(
                            child: new Text("enter"),
                            onPressed: () {

                              setState(() {
                                budget = double.parse(_c.text);
                                addBudgetToSF();
                              });
                              
                              var newTransaction = Transactions(val: _c.text,category: 'idk yet' );
                              DBProvider.db.newTransaction(newTransaction);

                  
                              Navigator.pop(context);
                              _c.clear();
                            }),
                      ],
                    )),
                context: context);
          });
        });
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

  addBudgetToSF() async {
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
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  Map<String, String> newTransaction = {};

  Future _transactionFuture;

  @override
  void initState(){
    super.initState();
    _transactionFuture = getTransactions();
  }
  getTransactions() async{
    final _transdata = await DBProvider.db.getCat();
    return _transdata;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
        future: _transactionFuture, 
        builder: (_, transData){
          switch(transData.connectionState){
            case ConnectionState.none:
              return Container();
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.active:
              return Container();
            case ConnectionState.done:
              if(!newTransaction.containsKey('category')){
                newTransaction = Map<String, String>.from(transData.data);
              }
              return Column(children: <Widget>[
                Text(
                  newTransaction['category'],
                  ),
                Text(
                  newTransaction['val'],
                )
                  ]);
          }
          return Container();
        }
      )
    );
  }
}




class BothPages extends StatefulWidget {
  @override
  _BothPagesState createState() => _BothPagesState();
}

class _BothPagesState extends State<BothPages> {
  int _currentPage = 0;

  static List<Widget> _bothPages = <Widget>[
    MyWidget(),
    HistoryPage(),
  ];

  void _onItemTapped(int index){
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
            icon: Icon(Icons.home),
            label: "Main"
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History"
          ),
        ],
        currentIndex: _currentPage,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        ),
    );
  }
}