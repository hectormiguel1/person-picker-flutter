import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:person_picker/model/participant.dart';

final INITIAL_INDEX = -1;

enum BUTTONS { RNG, INCREMENT, RESET, RESET_ALL }

class MainView extends StatefulWidget {
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _selectedIndex = INITIAL_INDEX;
  var _doneLoading = false;
  List<Participant> _participants = [];

  _MainViewState() {
    Future.delayed(Duration.zero).then((_) => loadJson());
  }
  void selectRandom() {
    Random rng = Random();
    setState(() {
      this._selectedIndex = rng.nextInt(_participants.length);
    });
  }

  void loadJson() async {
    final Directory directory = await Directory.current;
    final File jsonFile = File('${directory.path}/participants.json');
    List<dynamic> loadedJson = await json.decode(await jsonFile.readAsString());
    _participants =
        loadedJson.map((person) => Participant.fromJson(person)).toList();
    setState(() => _doneLoading = true);
  }

  Widget buildButton(BUTTONS buttonToBuild) {
    String buttonText = "";
    MaterialStateProperty<Color> buttonColor =
        MaterialStateProperty.all<Color>(Colors.white);
    var callFunction;
    if (buttonToBuild == BUTTONS.RNG) {
      buttonText = "Pick Random Person";
      buttonColor = MaterialStateProperty.all<Color>(Colors.blue);
      callFunction = () => selectRandom();
    } else if (buttonToBuild == BUTTONS.INCREMENT) {
      buttonText = "Add Point";
      buttonColor = MaterialStateProperty.all<Color>(Colors.green);
      callFunction = () => addPoints();
    } else if (buttonToBuild == BUTTONS.RESET) {
      buttonText = "Reset Current Participant";
      buttonColor = MaterialStateProperty.all<Color>(Colors.red);
      callFunction = () => resetParticipant();
    } else if (buttonToBuild == BUTTONS.RESET_ALL) {
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
      saveToJson();
    });
  }

  void addPoints() {
    setState(() {
      _participants[_selectedIndex].numOfPoints =
          _participants[_selectedIndex].numOfPoints + 1;
      saveToJson();
    });
  }

  void saveToJson() async {
    final Directory directory = await Directory.current;
    final File jsonFile = File('${directory.path}/participants.json');
    await jsonFile.writeAsString(json.encode(
        _participants.map((participant) => participant.toJson()).toList()));
  }

  Widget buildPersonTile(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 0.0, 10.0, 0.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(_participants[index].name,
            style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.grey)),
        leading: Icon(Icons.person),
        selected: _selectedIndex == index,
        focusColor: Colors.blue,
        selectedTileColor: Colors.indigo[900],
        hoverColor: Colors.blue,
        onTap: () => {
          setState(() {
            this._selectedIndex = index;
          })
        },
      ),
    );
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

  Widget build(BuildContext context) {
    if (!_doneLoading) {
      return CircularProgressIndicator(color: Colors.blue);
    } else {
      return Scaffold(
          body: Flex(
              direction: Axis.horizontal,
              textDirection: TextDirection.ltr,
              children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[900]!.withOpacity(0.5),
                child: ListView(
                    children: _participants
                        .map((person) =>
                            buildPersonTile(_participants.indexOf(person)))
                        .toList()),
              ),
            ),
            Expanded(flex: 3, child: buildParticipantView(_selectedIndex))
          ]));
    }
  }
}
