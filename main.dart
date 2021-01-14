import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sizeconfig.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'dataHelper.dart';
import 'transactionCLASS.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomWidgets.dart';
import 'package:intl/intl.dart';

void main() => runApp(BuddyApp());

class BuddyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        Responsive().init(constraints, orientation);
        return MaterialApp(
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Files App',
          home: HomePage(),
        );
      });
    });
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  TextEditingController _c = new TextEditingController();
  double budget = 0.00;
  int spot = 0;
  var dbHelper;
  Future<List<TransactionClass>> allTransactions;
  Future<List<Widget>> allTransactionMedia;
  String name;
  String cat;
  DateFormat formatter = DateFormat('M-d-y');

  @override
  void initState() {
    super.initState();
    loadSpot();
    loadBudget();
    dbHelper = DBHelper();
    allTransactionMedia = createTransactionList();
    refreshList();
  }

  loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      budget = (prefs.getDouble('total') ?? 0);
    });
  }

  loadSpot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      spot = (prefs.getInt('spot') ?? 0);
    });
  }

  refreshList() async {
    setState(() {
      allTransactions = dbHelper.getTransactions();
      allTransactionMedia = createTransactionList();
    });
  }

  Future<List<Widget>> createTransactionList() async {
    int count = await dbHelper.getCount();

    List<Widget> allMediaListItems = [];
    for (int i = count - 1; i >= 0; i--) {
      Widget singleMediaListItem;
      var c;
      c = await dbHelper.getSingleTransaction(i);

      String currVal = '\$' + c.val.toStringAsFixed(2);
      if (c.val < 0) {
        currVal = '-\$' + (-c.val).toStringAsFixed(2);
      }
      String cCat = c.category;
      String time = c.time;
      singleMediaListItem = _mediaListItem(currVal + '   ' + cCat,
          Colors.amber[500], Colors.amber[100], time, icons(cCat));
      allMediaListItems.add(singleMediaListItem);
    }
    return allMediaListItems;
  }

  Widget floatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: null,
              child: CircleAvatar(
                radius: 7.8 * Responsive.widthMultiplier,
                backgroundColor: Colors.red[200],
                child: FaIcon(
                  FontAwesomeIcons.minus,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return expensePopup();
                    });
              },
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 10,
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: null,
              child: CircleAvatar(
                radius: 7.8 * Responsive.widthMultiplier,
                backgroundColor: Color(0xFF63cb99),
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return addPopup();
                    });
              },
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      floatingActionButton: floatingButtons(),
      appBar: AppBar(
        backgroundColor: Color(0xFF2c2c3c),
        leading: Padding(
          padding: EdgeInsets.only(
            top: 1.8 * Responsive.imageSizeMultiplier,
            left: 6 * Responsive.imageSizeMultiplier,
          ),
          child: GestureDetector(
            onTap: () {
              //instead of having navigator buttons i kinda want to just
              //be able to swipe between the two pages
              //Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey[500],
            ),
          ),
        ),
        elevation: 0.0,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: 1.8 * Responsive.imageSizeMultiplier,
              right: 6 * Responsive.imageSizeMultiplier,
            ),
            child: GestureDetector(
                child: Icon(
                  Icons.more_horiz,
                  size: 6 * Responsive.imageSizeMultiplier,
                  color: Colors.grey[500],
                ),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return resetPopup();
                      });
                }),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 0.33 * MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Color(0xFF2c2c3c),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                )),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 6 * Responsive.imageSizeMultiplier,
                    top: 6 * Responsive.imageSizeMultiplier,
                    left: 6 * Responsive.imageSizeMultiplier,
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            right: 3 * Responsive.widthMultiplier,
                          ),
                          child: FaIcon(FontAwesomeIcons.wallet,
                              color: Colors.white)),
                      Text(
                        "budget",
                        style: TextStyle(
                          fontSize: 3.4 * Responsive.textMultiplier,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 6 * Responsive.imageSizeMultiplier,
                    left: 6 * Responsive.imageSizeMultiplier,
                    top: 10 * Responsive.imageSizeMultiplier,
                  ),
                  child: Row(
                    children: <Widget>[
                      budgetText(),
                      Expanded(
                        child: Container(
                          width: 0.57 * MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 1 * Responsive.heightMultiplier,
                                  left: 2 * Responsive.widthMultiplier,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "",
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                    Spacer(),
                                    FutureBuilder(
                                        future: spent(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Text(
                                              "\$0.00",
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            );
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            String spent = snapshot.data
                                                .toStringAsFixed(2);
                                            return Text(
                                              "\$" + spent,
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            );
                                          } else {
                                            return Text(
                                              "\$0.00",
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            );
                                          }
                                        }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0.5 * Responsive.heightMultiplier,
                                  left: 2 * Responsive.widthMultiplier,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "left",
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "spent",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 6 * Responsive.imageSizeMultiplier,
                    left: 6 * Responsive.imageSizeMultiplier,
                    top: 10 * Responsive.imageSizeMultiplier,
                  ),
                  child: Center(
                    child: FutureBuilder(
                        future: spent(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return LinearPercentIndicator(
                              width: 0.87 * MediaQuery.of(context).size.width,
                              lineHeight: 8.0,
                              percent: 0.0,
                              progressColor: Colors.greenAccent,
                              backgroundColor: Colors.grey[700],
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            double spent = snapshot.data;
                            double perc = -spent / (-spent + budget);
                            if (perc > 1.0) {
                              perc = 1.0;
                            } else if (perc < 0.0) {
                              perc = 0.0;
                            }
                            return LinearPercentIndicator(
                              width: 0.87 * MediaQuery.of(context).size.width,
                              lineHeight: 8.0,
                              percent: perc,
                              progressColor: Colors.greenAccent,
                              backgroundColor: Colors.grey[700],
                            );
                          } else {
                            return LinearPercentIndicator(
                              width: 0.87 * MediaQuery.of(context).size.width,
                              lineHeight: 8.0,
                              percent: 0.0,
                              progressColor: Colors.greenAccent,
                              backgroundColor: Colors.grey[700],
                            );
                          }
                        }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4 * Responsive.heightMultiplier,
              bottom: 2 * Responsive.heightMultiplier,
              left: 6 * Responsive.imageSizeMultiplier,
              right: 6 * Responsive.imageSizeMultiplier,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 6 * Responsive.heightMultiplier,
                ),
                Text(
                  "previous transactions",
                  style: TextStyle(
                    fontSize: 3.4 * Responsive.textMultiplier,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                GestureDetector(
                    child: Icon(
                      Icons.more_horiz,
                      size: 6 * Responsive.imageSizeMultiplier,
                      color: Colors.grey[500],
                    ),
                    onTap: () {}),
              ],
            ),
          ),
          FutureBuilder(
              future: allTransactionMedia,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(children: snapshot.data);
                } else {
                  return LinearProgressIndicator();
                }
              }),
        ],
      ),
    );
  }

  Widget expensePopup() {
    return Container(
        height: 400,
        color: Colors.white,
        child: Center(
            child: Column(children: [
          CupertinoTextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            controller: _c,
          ),
          categories(),
          CupertinoButton.filled(
              child: new Text("enter"),
              onPressed: () {
                double change = -double.parse(_c.text);
                DateTime now = DateTime.now();
                String formattedTime = formatter.format(now);
                if (cat == null) {
                  cat = 'other';
                }
                TransactionClass t =
                    TransactionClass(spot, cat, change, formattedTime);
                dbHelper.save(t);
                refreshList();
                setState(() {
                  budget = budget + change;
                  addBudgetToSP();
                  spot += 1;
                  updateSpot();
                });
                Navigator.of(context, rootNavigator: true).pop();
                _c.clear();
              }),
        ])));
  }

  Widget budgetText() {
    if (budget < 0) {
      return Text(
        "-\$" + (-budget).toStringAsFixed(2),
        style: TextStyle(
          fontSize: 7.6 * Responsive.textMultiplier,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        "\$" + budget.toStringAsFixed(2),
        style: TextStyle(
          fontSize: 7.6 * Responsive.textMultiplier,
          color: Colors.white,
        ),
      );
    }
  }

  Widget addPopup() {
    return Container(
        height: 400,
        color: Colors.white,
        child: Center(
            child: Column(children: [
          CupertinoTextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            controller: _c,
          ),
          categories(),
          CupertinoButton.filled(
              child: new Text("enter"),
              onPressed: () {
                double change = double.parse(_c.text);
                DateTime now = DateTime.now();
                String formattedTime = formatter.format(now);
                if (cat == null) {
                  cat = 'other';
                }
                TransactionClass t =
                    TransactionClass(spot, cat, change, formattedTime);
                dbHelper.save(t);
                refreshList();
                setState(() {
                  budget = budget + change;
                  addBudgetToSP();
                  spot += 1;
                  updateSpot();
                });
                Navigator.of(context, rootNavigator: true).pop();
                _c.clear();
              }),
        ])));
  }

  Widget resetPopup() {
    return Container(
        height: 400,
        color: Colors.white,
        child: Center(
            child: Column(children: [
          CupertinoTextField(
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
                  spot = 0;
                  updateSpot();
                });
                Navigator.of(context, rootNavigator: true).pop();
                _c.clear();
              }),
        ])));
  }

  updateSpot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('spot', spot);
      spot = (prefs.getInt('spot') ?? 0);
    });
  }

  addBudgetToSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('total', budget);
      budget = (prefs.getDouble('total') ?? 0);
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

  Future<double> spent() async {
    return await dbHelper.totalSpent();
  }

  icons(String cat) {
    if (cat == ('food/drinks')) {
      return FontAwesomeIcons.utensils;
    } else if (cat == ('groceries')) {
      return FontAwesomeIcons.shoppingBasket;
    } else if (cat == ('clothing')) {
      return FontAwesomeIcons.tshirt;
    } else if (cat == ('bills')) {
      return FontAwesomeIcons.fileInvoiceDollar;
    } else if (cat == ('health')) {
      return FontAwesomeIcons.firstAid;
    } else {
      return FontAwesomeIcons.user;
    }
  }

  Widget _mediaListItem(
      String title, Color icon, Color accent, String meta, IconData mediaIcon) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 2 * Responsive.heightMultiplier,
        left: 6 * Responsive.widthMultiplier,
      ),
      child: Row(
        children: <Widget>[
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: EdgeInsets.all(3 * Responsive.imageSizeMultiplier),
                child: Icon(
                  mediaIcon,
                  size: 6 * Responsive.imageSizeMultiplier,
                  color: icon,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0 * Responsive.widthMultiplier),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 3 * Responsive.textMultiplier,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  height: 0.5 * Responsive.heightMultiplier,
                ),
                Text(
                  meta,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 2 * Responsive.textMultiplier,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
