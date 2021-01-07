import 'package:budget/dataHelper.dart';
import 'package:budget/transactionCLASS.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
  var dbHelper;
  Future<List<TransactionClass>> allTransactions;
  String name;

  
  refreshList() {
    setState((){
      allTransactions = dbHelper.getTransactions();
    });
  }
  
  @override
  void initState() {
    super.initState();
    loadBudget();
    dbHelper = DBHelper();
    //refreshList(); 
  }
  

  

  Widget build(BuildContext context) {
    return buildWidgets(context, _c);
  }

  Widget buildWidgets(context, _c) {
    return SingleChildScrollView(
      child: Column(
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
      )
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
                              double change = -double.parse(_c.text);
                              TransactionClass t = TransactionClass(null, 'category name', change);
                              dbHelper.save(t);
                              refreshList(); 
                              setState(() {
                                budget = budget + change;
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
                              double change = double.parse(_c.text);
                              TransactionClass t = TransactionClass(null, 'category name', change);
                              dbHelper.save(t);
                              refreshList(); 
                              setState(() {
                                budget = budget + change;
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
                              dbHelper.deleteAll();
                              refreshList();
                              setState(() {
                                budget = double.parse(_c.text);
                                addBudgetToSF();
                              });
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

mixin Alignmnent {
}

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

  Future<List<TransactionClass>> allTransactions;
  var dbHelper;

  @override
  void initState(){
    super.initState();
    dbHelper = DBHelper();
    refreshList();
  }

  refreshList() {
    setState((){
      allTransactions = dbHelper.getTransactions();
    });
  }

  SingleChildScrollView dataTable(List <TransactionClass> transactions){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Category')
          ),
          DataColumn(
            label: Text('Amount')
          ),
        ],
        rows: transactions
          .map(
            (transaction) => DataRow( cells: 
                      [
                        DataCell(
                          Text(transaction.category)
                        ),
                        DataCell(
                          Text(transaction.val.toString())
                        ),
                      ]
            )
          ).toList()
        ,
      )
    );
  }

  list(){
    return Expanded(
      child: FutureBuilder(
        future: allTransactions,
        builder: (context, snapshot){
          
          if (null == snapshot.data || snapshot.data.length == 0){
            return Text('No Transactions');
          }

          else if(snapshot.hasData){
            return dataTable(snapshot.data);

            }
          return CircularProgressIndicator();
          }
        ),
    );
  }



  @override
  Widget build(BuildContext context) {

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[list()],
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
    DataPage(),
  ];

  void _onItemTapped(int index){
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //369 MaterialApp is new line maybe bad lol
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