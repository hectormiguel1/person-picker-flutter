import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:person_picker/backend/store.dart';
import 'package:person_picker/components/customButton.dart';
import 'package:person_picker/components/personTile.dart';
import 'package:person_picker/model/participant.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'settingsPanel.dart';

const INITIAL_INDEX = -1;

class MainView extends StatefulWidget {
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _selectedIndex = INITIAL_INDEX;
  var _scrollListController = ItemScrollController();
  var _itemPosListener = ItemPositionsListener.create();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Random rng = new Random.secure();
  late DataStore _dataStore;

  void selectRandom(int listLength) {
    //Bit shifts to the highest possible 32 bit integer.
    int max = 1 << 31;
    setState(() {
      this._selectedIndex = (rng.nextInt(max)) % listLength;
      _scrollListController.jumpTo(index: _selectedIndex);
    });
  }

  Widget buildButton(BUTTONS buttonToBuild,
      List<Participant> participantList) {
    String buttonText = "Unknown Button Type";
    if (buttonToBuild == BUTTONS.RNG) {
      return CustomButton(buttonType: buttonToBuild,
          onPressed: () => selectRandom(participantList.length),
          buttonText: "Pick Random person",
          buttonIcon: FaIcon(FontAwesomeIcons.random));
    } else if (buttonToBuild == BUTTONS.INCREMENT) {
      return CustomButton(buttonType: buttonToBuild,
          onPressed: () => addPoints(participantList),
          buttonText: "Add Point",
          buttonIcon: FaIcon(FontAwesomeIcons.plus));
    } else if (buttonToBuild == BUTTONS.RESET) {
      return CustomButton(buttonType: buttonToBuild,
          onPressed: () => resetParticipant(participantList),
          buttonText: "Reset points for ${participantList[_selectedIndex].name}",
          buttonIcon: FaIcon(FontAwesomeIcons.undo));
    } else if (buttonToBuild == BUTTONS.RESET_ALL) {
      return CustomButton(buttonType: buttonToBuild,
          onPressed: () => resetAll(participantList),
          buttonText: "Reset All Participants Points",
          buttonIcon: FaIcon(FontAwesomeIcons.trash));
    } else if (buttonToBuild == BUTTONS.DECREMENT) {
      return CustomButton(buttonType: buttonToBuild,
          onPressed: () => decrement(participantList),
          buttonText: "Remove Point",
          buttonIcon: FaIcon(FontAwesomeIcons.minus));
    } else if(buttonToBuild == BUTTONS.DELETE) {
      return CustomButton(buttonType: buttonToBuild, onPressed: () => deleteParticipant(participantList[_selectedIndex]), buttonText: 'Delete ${participantList[_selectedIndex].name}', buttonIcon: FaIcon(FontAwesomeIcons.userMinus),);
    }
    else
      return CustomButton(buttonType: buttonToBuild,
          onPressed: () => {},
          buttonText: buttonText);
  }

  void resetAll(List<Participant> participantList) {
    setState(() {
      participantList.forEach((element) {
        element.numOfPoints = 0;
      });
      saveToJson(participantList);
    });
  }

  void resetParticipant(List<Participant> participantList) {
    setState(() {
      participantList[_selectedIndex].numOfPoints = 0;
      saveToJson(participantList, _selectedIndex);
    });
  }

  void addPoints(List<Participant> participantList) {
    setState(() {
      participantList[_selectedIndex].numOfPoints =
          participantList[_selectedIndex].numOfPoints + 1;
      saveToJson(participantList, _selectedIndex);
    });
  }

  void decrement(List<Participant> participants) {
    setState(() {
      participants[_selectedIndex].numOfPoints--;
      saveToJson(participants, _selectedIndex);
    });
  }

  void saveToJson(List<Participant> participants,
      [index = INITIAL_INDEX]) async {
    _dataStore.save(participants, index);
  }

  Widget buildPersonTile(int index, List<Participant> participantList) {
    if (participantList.length > 0) {
      return PersonTile(person: participantList[index], onPressed: () =>
      {
        this.setState(() {
          _selectedIndex = index;
        }),
      }, isSelected: (index == this._selectedIndex));
    } else {
      return Container();
    }
  }

  Widget buildParticipantView(int participantIndex,
      List<Participant> participantList) {
    final crossAxisSpacing = 50.0;
    final mainAxisSpacing = 50.0;
    final availableSpace = (((MediaQuery
        .of(context)
        .size
        .width - MediaQuery
        .of(context)
        .size
        .width / 3) - crossAxisSpacing) / 250).round();
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
          buildButton(BUTTONS.RNG, participantList),
          SizedBox(
            height: 50,
          ),
          buildButton(BUTTONS.RESET_ALL, participantList),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),

            Text("Person Picked: ${participantList[participantIndex].name}",
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 50),
            Text(
              "Current Points: ${participantList[participantIndex]
                  .numOfPoints}",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 50),

            GridView.count(
              padding: const EdgeInsets.fromLTRB(50, 50, 50, 150),
              crossAxisCount: availableSpace + 1,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                buildButton(BUTTONS.INCREMENT, participantList),
                buildButton(BUTTONS.RNG, participantList),
                buildButton(BUTTONS.DECREMENT, participantList),
                buildButton(BUTTONS.RESET, participantList),
                buildButton(BUTTONS.RESET_ALL, participantList),
                buildButton(BUTTONS.DELETE, participantList),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget floatingButton(DataStore storage) {
    return FloatingActionButton(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      child: Icon(Icons.settings, color: Theme
          .of(context)
          .iconTheme
          .color),
      onPressed: () {
        showModalBottomSheet(
            context: context, builder: (context) => SettingsPanel(storage));
      }
      ,
    );
  }

  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size
        .width;
    return GetBuilder<DataStore>(
        init: DataStore(),
        builder: (dataStore) {
          _dataStore = dataStore;
          return Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .canvasColor,
              key: _scaffoldKey,
              body: Flex(
                  direction: Axis.horizontal,
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      flex: screenSize > 700 ? 1 : 2,
                      child: Container(
                          color: Theme
                              .of(context)
                              .backgroundColor
                              .withOpacity(0.3),
                          child: ScrollablePositionedList.builder(
                            itemCount: dataStore.loadedParticipants.length,
                            itemBuilder: (_, index) =>
                                buildPersonTile(
                                    index, dataStore.loadedParticipants),
                            itemScrollController: _scrollListController,
                            itemPositionsListener: _itemPosListener,
                          )
                      ),
                    ),
                    Expanded(flex: screenSize > 700 ? 3 : 4,
                        child: buildParticipantView(
                            _selectedIndex, dataStore.loadedParticipants))
                  ]),
              floatingActionButton: floatingButton(dataStore));
        });
  }

  void deleteParticipant(Participant participant) {
    _dataStore.removeUser(participant);
        setState(() {
          _selectedIndex = INITIAL_INDEX;
        });
  }
}

