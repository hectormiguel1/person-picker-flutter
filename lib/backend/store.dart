import 'dart:convert';
import 'dart:io';
// ignore: avoid_web_libraries_in_flutter
import 'package:file_picker_cross/file_picker_cross.dart';
import "package:universal_html/html.dart" as html;
import 'package:person_picker/model/participant.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

final defaultFileDir = Directory.current;
final defaultFileName = "participants.json";
final defaultHttpFileURI = 'http://personpicker.ddns.net:49153';
//final defaultHttpFileURI = "http://127.0.0.1:49153";
const INDEX_SENTINAL_VALUE = -1;

class DataStore extends GetxController {
  late List<Participant> loadedParticipants;
  late final RxList<Participant> participantsObserver;
  bool loadedLocalFile = false;

  DataStore() {
    loadedParticipants = new List<Participant>.empty(growable: true);
    participantsObserver = loadedParticipants.obs;
    load().then((_) => update());
  }

Future load() async {
    _loadJsonHttp(defaultHttpFileURI).then((_) => update());
  }

  Future save(List<Participant> participants, [int index = INDEX_SENTINAL_VALUE]) async {
    if(loadedLocalFile) {
      return;
    }
    if (index != INDEX_SENTINAL_VALUE) {
      _saveRemotePut(participants, index);
    } else
      _saveRemote(defaultHttpFileURI, participants);
  }

  void deleteAll() {
    loadedParticipants.clear();
    save(loadedParticipants);
  }

  Future<void> add(Participant participant) async {
    loadedParticipants.add(participant);
    loadedParticipants.sort();
    save(loadedParticipants);
    update();
  }

  Map<String, String> GetHeader = {"Accept": "application/json"};
  Future<void> _loadJsonHttp(String uri) async {
    var httpRequest = await http.get(Uri.parse(uri), headers: GetHeader);
    print('Http Request status Code: ${httpRequest.statusCode}');
    if (httpRequest.statusCode == HttpStatus.ok) {
      String requestBody = httpRequest.body;
      //print('GET Request Response Body: ' + requestBody);
      List<dynamic> loadedData = await json.decode(requestBody);
      loadedParticipants.addAll(loadedData.map((element) => Participant.fromJson(element)).toList());
      update( );
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

  Future<void> saveLocallyFromWeb() async {
    final jsonString = json.encode(loadedParticipants);
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'participants.json';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> saveLocallyFromDesktop() async {
    final jsonString = json.encode(loadedParticipants);
    final folderPath = Directory.current.path;
    File fileWriter = File('$folderPath/participants.json');
    fileWriter.writeAsString(jsonString);
  }

  void removeUser(Participant participant) {
    if(loadedParticipants.contains(participant)) {
      loadedParticipants.remove(participant);
      update();
    }
    save(loadedParticipants);
  }

  Future<void> uploadFromWeb() async {
    FilePickerCross file = await FilePickerCross.importFromStorage(
      type: FileTypeCross.custom,
      fileExtension: 'json'
    );
    List<dynamic> loadedData = await json.decode(file.toString());
    loadedParticipants.clear();
    loadedParticipants.addAll(loadedData.map((element) => Participant.fromJson(element)).toList());
    update();
  }

  Future<void> openFromDesktop() async {
    FilePickerCross file = await FilePickerCross.importFromStorage(
        type: FileTypeCross.custom,
        fileExtension: 'json'
    );
    List<dynamic> loadedData = await json.decode(file.toString());
    loadedParticipants.clear();
    loadedParticipants.addAll(loadedData.map((element) => Participant.fromJson(element)).toList());
    update();
  }




}
