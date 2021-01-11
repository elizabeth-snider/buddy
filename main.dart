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
  String name;
  String cat;
  var popup;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
    loadBudget();
    dbHelper = DBHelper();
    popup = PopupDialog();
  }

  loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      budget = (prefs.getDouble('total') ?? 0);
    });
  }

  refreshList() {
    setState(() {
      allTransactions = dbHelper.getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircleAvatar(
        radius: 7.8 * Responsive.widthMultiplier,
        backgroundColor: Color(0xFF63cb99),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (
                BuildContext context,
              ) =>
                  expensePopup(),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
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
                  showDialog(
                    context: context,
                    builder: (
                      BuildContext context,
                    ) =>
                        resetPopup(),
                  );
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
                      Text(
                        "\$" + budget.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 7.6 * Responsive.textMultiplier,
                          color: Colors.white,
                        ),
                      ),
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
                                    Expanded(
                                      child: Text(
                                        "\$" + "0.00",
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
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
                                    Expanded(
                                      child: Text(
                                        "spent",
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
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
                    child: LinearPercentIndicator(
                      width: 0.87 * MediaQuery.of(context).size.width,
                      lineHeight: 8.0,
                      percent: 0.2,
                      progressColor: Colors.greenAccent,
                      backgroundColor: Colors.grey[700],
                    ),
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
          Column(
            children: <Widget>[
              _mediaListItem(
                  "Podcast with Brenda Evans",
                  Colors.amber[500],
                  Colors.amber[100],
                  "32Mb March 14, 2021",
                  Icons.library_music),
              _mediaListItem("Student Movies for March", Colors.amber[500],
                  Colors.amber[100], "894Mb March 8, 2021", Icons.videocam),
              _mediaListItem("Childhood", Colors.amber[500], Colors.amber[100],
                  "13.4Gb March 8, 2021", Icons.videocam),
              _mediaListItem(
                "Podcast with Larry Taylor",
                Colors.amber[500],
                Colors.amber[100],
                "49Mb February 25, 2021",
                Icons.library_music,
              ),
              _mediaListItem(
                  "Video Blog Youtube",
                  Colors.amber[500],
                  Colors.amber[100],
                  "13.4Gb February 11, 2021",
                  Icons.videocam),
              _mediaListItem(
                "Podcast with Katherine Long",
                Colors.amber[500],
                Colors.amber[100],
                "72Mb February 11 ,2021",
                Icons.library_music,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget expensePopup() {
    return Center(
        child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
                scale: scaleAnimation,
                child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Container(
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0))),
                        child: Container(
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
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
                                ]))))))));
  }

  Widget resetPopup() {
    return Center(
        child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
                scale: scaleAnimation,
                child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Container(
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0))),
                        child: Container(
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
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
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        _c.clear();
                                      }),
                                ]))))))));
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
                borderRadius: BorderRadius.circular(6.8),
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
                    fontSize: 2.3 * Responsive.textMultiplier,
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
                    fontSize: 1.8 * Responsive.textMultiplier,
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
