import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:person_picker/backend/JsonLoader.dart';
import 'package:person_picker/components/customButton.dart';
import 'package:person_picker/components/personTile.dart';
import 'package:person_picker/model/participant.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../settingsPanel.dart';

const INITIAL_INDEX = -1;

class MainView extends StatefulWidget {
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _selectedIndex = INITIAL_INDEX;
  var _doneLoading = false;
  List<Participant> _participants = [];
  var _scrollListController = ItemScrollController();
  var _itemPosListener = ItemPositionsListener.create();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Random rng = new Random.secure();

  _MainViewState() {
    Future.delayed(Duration.zero).then((_) => loadJson());
  }

  void selectRandom() {
    //Bit shifts to the highest possible 32 bit integer.
    int max = 1 << 31;
    setState(() {
      this._selectedIndex = ( rng.nextInt(max) ) % _participants.length;
      _scrollListController.jumpTo(index: _selectedIndex);
    });
  }

  void loadJson() async {
    load().then((participants) =>
    {
      setState(() {
        _participants = participants;
        _doneLoading = true;
        if(_participants.length < _selectedIndex) {
          _selectedIndex = INITIAL_INDEX;
        }
      })
    });
  }

  Widget buildButton(BUTTONS buttonToBuild) {
    String buttonText = "";
    MaterialStateProperty<Color> buttonColor =
    MaterialStateProperty.all<Color>(Colors.white);
    var callFunction;
    if (buttonToBuild == BUTTONS.RNG) {
      return CustomButton(buttonType: buttonToBuild, onPressed: () => selectRandom(), buttonText: "Pick Random person", buttonIcon: FaIcon(FontAwesomeIcons.random));
    } else if (buttonToBuild == BUTTONS.INCREMENT) {
      return CustomButton(buttonType: buttonToBuild, onPressed: () => addPoints(), buttonText: "Add Points", buttonIcon: FaIcon(FontAwesomeIcons.plus));
    } else if (buttonToBuild == BUTTONS.RESET) {
      return CustomButton(buttonType: buttonToBuild, onPressed: () => resetParticipant(), buttonText: "Reset Current Participant", buttonIcon: FaIcon(FontAwesomeIcons.undo));
    } else if (buttonToBuild == BUTTONS.RESET_ALL) {
      return CustomButton(buttonType: buttonToBuild, onPressed: () => resetAll(), buttonText: "Reset All Participants Points", buttonIcon: FaIcon(FontAwesomeIcons.trash));
      buttonText = "Reset All Participants Points";
      buttonColor = MaterialStateProperty.all<Color>(Colors.redAccent);
      callFunction = () => resetAll();
    }
    final buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      backgroundColor: buttonColor,
      elevation: MaterialStateProperty.all<double>(20.0),
    );
    return SizedBox(
      width: 200,
      height: 100,
      child: ElevatedButton(
        style: buttonStyle,
        child: Text(buttonText),
        onPressed: callFunction,
      ),
    );
  }

  void resetAll() {
    setState(() {
      _participants.forEach((element) {
        element.numOfPoints = 0;
      });
      saveToJson();
    });
  }

  void resetParticipant() {
    setState(() {
      _participants[_selectedIndex].numOfPoints = 0;
      saveToJson(_selectedIndex);
    });
  }

  void addPoints() {
    setState(() {
      _participants[_selectedIndex].numOfPoints =
          _participants[_selectedIndex].numOfPoints + 1;
      saveToJson(_selectedIndex);
    });
  }

  void saveToJson([index = INITIAL_INDEX]) async {
    save(_participants, index);
  }

  Widget buildPersonTile(int index) {
    if(_participants.length > 0) {
      return PersonTile(person: _participants[index], onPressed: () => {
        this.setState(() {
          _selectedIndex = index;
        }),
      }, isSelected: (index == this._selectedIndex));
    } else {
      return Container();
    }
  }

  Widget buildParticipantView(int participantIndex) {
    if (participantIndex == INITIAL_INDEX) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              "Select Participant from List, or Press Button to select Random Participant. "),
          SizedBox(
            height: 50,
          ),
          buildButton(BUTTONS.RNG),
          SizedBox(
            height: 50,
          ),
          buildButton(BUTTONS.RESET_ALL),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Person Picked: ${_participants[_selectedIndex].name}",
              style: TextStyle(fontSize: 24)),
          SizedBox(height: 50),
          Text(
            "Current Points: ${_participants[_selectedIndex].numOfPoints}",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildButton(BUTTONS.INCREMENT),
              SizedBox(
                width: 20,
              ),
              buildButton(BUTTONS.RNG),
              SizedBox(
                width: 20,
              ),
              buildButton(BUTTONS.RESET),
            ],
          ),
          SizedBox(height: 50),
          buildButton(BUTTONS.RESET_ALL),
        ],
      );
    }
  }

  Widget floatingButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
      onPressed: () {
        showModalBottomSheet(context: context, builder: (context) => SettingsPanel());
      }
      ,
    );
  }

  Widget build(BuildContext context) {
    if (!_doneLoading) {
      return CircularProgressIndicator(color: Theme.of(context).primaryColor);
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        key: _scaffoldKey,
          body: Flex(
              direction: Axis.horizontal,
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                      color: Theme.of(context).backgroundColor.withOpacity(0.3),
                      child: ScrollablePositionedList.builder(
                        itemCount: _participants.length,
                        itemBuilder: (_, index) => buildPersonTile(index),
                        itemScrollController: _scrollListController,
                        itemPositionsListener: _itemPosListener,
                      )
                  ),
                ),
                Expanded(flex: 3,
                    child: Center(child: ListView(
                      scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(100, 100, 100, 100),
                        children: [buildParticipantView(_selectedIndex)])))
              ]),
      floatingActionButton: floatingButton(),);
    }
  }
}
