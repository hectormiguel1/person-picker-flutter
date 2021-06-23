import 'dart:convert';
import 'dart:io';
import 'package:person_picker/model/participant.dart';
import 'package:http/http.dart' as http;

List<Participant> _loadedParticipants = [];

final defaultFileDir = Directory.current;
final defaultFileName = "participants.json";
final defaultHttpFileURI = 'http://personpicker.ddns.net:49153';
//final defaultHttpFileURI = "http://127.0.0.1:49153";
const INDEX_SENTINAL_VALUE = -1;


Future<List<Participant>> load() async {
  await _loadJsonHttp(defaultHttpFileURI);
  return _loadedParticipants;
}

void save(List<Participant> participants, [int index = INDEX_SENTINAL_VALUE]) async {
  if (index != INDEX_SENTINAL_VALUE) {
    _saveRemotePut(participants, index);
  } else
    await _saveRemote(defaultHttpFileURI, participants);

}

void deleteAll() {
  _loadedParticipants.clear();
  save(_loadedParticipants);
}

void add(Participant participant) {
  _loadedParticipants.add(participant);
  save(_loadedParticipants);
}



Future<void> _loadJsonLocal(File file) async {
  List<dynamic> loadedData = await json.decode(await file.readAsString());
  _loadedParticipants =
      loadedData.map((element) => Participant.fromJson(element)).toList();
}

Future<void> _saveLocal(List<Participant> persons, File filePath) async {
  await filePath.writeAsString(
      json.encode(persons.map((person) => person.toJson()).toList()));
}

Map<String, String> GetHeader = {"Accept": "application/json"};
Future<void> _loadJsonHttp(String uri) async {
  var httpRequest = await http.get(Uri.parse(uri), headers: GetHeader);
  print('Http Request status Code: ${httpRequest.statusCode}');
  if (httpRequest.statusCode == HttpStatus.ok) {
    String requestBody = httpRequest.body;
    //print('GET Request Response Body: ' + requestBody);
    List<dynamic> loadedData = await json.decode(requestBody);
    _loadedParticipants =
        loadedData.map((element) => Participant.fromJson(element)).toList();
  }
}
Future<void> _saveRemote(String postURI, List<Participant> persons) async {
  try {
    var httpRequest = await http.post(Uri.parse(postURI),
        body: json.encode(persons.map((person) => person.toJson()).toList()));
  } catch (_) {
    print("Error caught!");
  }
}

void _saveRemotePut(List<Participant> participants, int index) async {
  Map<String, dynamic> putBody = {
    'index': index,
    'participant': participants[index].toJson()
  };
  try {
    var httpRequest = await http.put(
        Uri.parse(defaultHttpFileURI), body: json.encode(putBody));
  } catch(error) {
    print(error);
  }

}
