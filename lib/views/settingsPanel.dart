import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:person_picker/backend/store.dart';
import 'package:person_picker/model/participant.dart';

class SettingsPanel extends StatefulWidget{
  final dataStore;


  SettingsPanel(this.dataStore);
  @override
  State<StatefulWidget> createState() => _SettingsPanelState(dataStore);

}

class _SettingsPanelState extends State<SettingsPanel> {
  final DataStore _dataStore;
  _SettingsPanelState(this._dataStore);

  Widget _darkModeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Enable Dark Mode:"),
        Switch(
            activeColor: Theme
                .of(context)
                .primaryColor,
            value: AdaptiveTheme
                .of(context)
                .mode == AdaptiveThemeMode.dark,
            onChanged: (newVal) {
              if (newVal) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            }
        ),
      ],
    );
  }

  Widget _deleteAllParticipants() {
    return SizedBox(
      height: 100,
      width: 100,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).errorColor)),
        child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.trash),
              SizedBox(width: 10),
              Text("Remove All Participants", textAlign: TextAlign.center,)
            ]),
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text("Delete All Participants?"),
              content: Text("Are you sure you want to delete all participants?"),
              actions: [
                TextButton(child: Text("Cancel", style:  Theme
                    .of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(
                  color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark? Colors.white : Colors.black,
                )), onPressed: () => Navigator.of(context).pop()),
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.red,
                    child: Text("Delete All", style: Theme.of(context).textTheme.button!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )), onPressed: () {
                  _dataStore.deleteAll();
                  Navigator.of(context).pop();
                })
              ]
            );
          });
        },
      ),
    );
  }

  void _addParticipant() {
    String participantFName = "";
    String participantLName = "";
    showDialog(context: context, builder: (context) {
      return Dialog(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        insetPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SizedBox(
            height: 200,
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                    decoration: InputDecoration(
                        hintText: "Enter Participant First Name....",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  onChanged: (value) => participantFName = value,
                ),
                SizedBox(height: 20,),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Enter Participant Last Name....",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  onChanged: (value) => participantLName = value,
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((15))),
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  FlatButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Text("Add Participant", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      _dataStore.loadedParticipants.add(Participant(name: '$participantFName $participantLName'));
                      Navigator.of(context).pop();
                    },
                  ),
                ],)
              ]
            ),
          ),
        )
      );
    });
  }

  Widget _addParticipantButton() {
    return SizedBox(
      width: 100,
      height: 100,
      child: ElevatedButton(
        child: Column(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.userPlus),
              SizedBox(height: 10),
              Text("Add a new Participant", textAlign: TextAlign.center,)
            ]),
        onPressed: () => _addParticipant(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataStore>(
      builder: (dataStore) =>
          Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  _darkModeToggle(),
                  SizedBox(height: 20),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _deleteAllParticipants(),
                        SizedBox(width: 50),
                        _addParticipantButton(),
                        SizedBox(width: 50),
                        _addSaveLocalButton(),
                        SizedBox(width: 50),
                        _uploadLocal(),
                      ]),
                  SizedBox(height: 50),

                ],
              )
          ),
    );
  }

  Widget _addSaveLocalButton() {
    return SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange[900])),
        child: Column(mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.save),
          SizedBox(height: 10),
          Text("Save Locally", textAlign: TextAlign.center,)
        ]),
    onPressed: () =>  kIsWeb? _dataStore.saveLocallyFromWeb() : _dataStore.saveLocallyFromDesktop()));
  }

  Widget _uploadLocal() {
    return SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal)),
            child: Column(mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  kIsWeb? FaIcon(FontAwesomeIcons.upload) : FaIcon(FontAwesomeIcons.file),
                  SizedBox(height: 10),
                  kIsWeb? Text("Upload Local Participant File", textAlign: TextAlign.center) : Text("Open Local File", textAlign: TextAlign.center)
                ]),
            onPressed: () =>  kIsWeb? _dataStore.uploadFromWeb() : _dataStore.openFromDesktop()));
  }

}