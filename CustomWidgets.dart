import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'transactionCLASS.dart';
import 'dataHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopupDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog>
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

  Widget resetBudget() {
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
}
