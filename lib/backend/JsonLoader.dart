import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:person_picker/model/participant.dart';
import 'package:http/http.dart' as http;

List<Participant> _loadedParticipants = [];

final defaultFileDir = Directory.current;
final defaultFileName = "participants.json";
final defaultHttpFileURI = "https://raw.githubusercontent.com/hectormiguel1/person-picker-flutter/main/participants.json";
final HTTP_OK_RESPONSE = 200;
final Map<String, String> defaultHttpPostHeader = {'Content-Type': 'application/json'};

Future<List<Participant>> load() async {
  if (kIsWeb) {
    await _loadJsonHttp(defaultHttpFileURI);
  } else {
    await _loadJsonLocal(File(defaultFileDir.path + "/" + defaultFileName));
  }
  return _loadedParticipants;
}

void save(List<Participant> participants) async {
  if(kIsWeb) {
    await _saveRemote(defaultHttpFileURI, participants);
  } else {
    await _saveLocal(participants, File(defaultFileDir.path + "/" + defaultFileName));
  }
}

Future<void> _loadJsonLocal(File file) async {
  List<dynamic> loadedData = await json.decode(await file.readAsString());
  _loadedParticipants =
      loadedData.map((element) => Participant.fromJson(element)).toList();
}

Future<void> _saveLocal(List<Participant> persons, File filePath) async {
  await filePath.writeAsString(json.encode(
      persons.map((person) => person.toJson()).toList()
  ));
}

Future<void> _loadJsonHttp(String uri) async {
  var httpRequest = await http.get(Uri.parse(uri));
  if(httpRequest.statusCode == HTTP_OK_RESPONSE) {
    List<dynamic> loadedData = await json.decode(httpRequest.body);
    _loadedParticipants = loadedData.map( (element) => Participant.fromJson(element)).toList();
  }
}

Future<void> _saveRemote(String postURI, List<Participant> persons) async {
  try {
    var httpRequest = await http.post(
        Uri.parse(postURI), headers: defaultHttpPostHeader,
        body: json.encode(persons.map((person) => person.toJson()).toList())
    );
  }catch (_){
    print("Error caught!");
  }
}



