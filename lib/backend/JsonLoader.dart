import 'dart:convert';
import 'dart:io';
import 'package:person_picker/model/participant.dart';

List<Participant> _loadedParticipants = [];

List<Participant> load() {
  return [];
}

void save(List<Participant> participants) {}

void _loadJsonLocal(File file) async {
  List<dynamic> loadedData = await json.decode(await file.readAsString());
  _loadedParticipants =
      loadedData.map((element) => Participant.fromJson(element)).toList();
}
