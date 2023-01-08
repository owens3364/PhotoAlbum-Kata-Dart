import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:photo_album/photo.dart';

import 'application.dart';

final photosUrl = Uri.https('jsonplaceholder.typicode.com', 'photos');

Future<List<dynamic>> getPhotosJson() async => jsonDecode((await get(photosUrl)).body);

void main() async {
  List<Map<String, dynamic>> photosJson = [];
  try {
    print('Loading photos...');
    photosJson = (await getPhotosJson()).cast<Map<String, dynamic>>();
    print('Photos loaded!\n');
  } catch (e, stackTrace) {
    print('Fetching photo data failed. The data may be formatted incorrectly, or you may have an unstable internet connection.');
    print('Please try again later.');
    print(e);
    print(stackTrace);
    return;
  }
  try {
    startApplication(photosJson.map(Photo.fromJson).toList());
  } catch (e, st) {
    if (e != 'Exit') {
      print('An unknown error occurred.');
      print(e);
      print(st);
    }
  }
}

// If this program was more advanced and required stronger OOP design, I'd make a class to supply dependencies
// Or put this in a class with variables that are functions that could be set to other functions
// So that io functions could be appropriately mocked
// Dart Mockito library does not use reflection because many popular applications of dart require that reflection is not used
// This offers substantial performance benefits in the real world, but forces you to write code a little differently for testability/mockability/DI
void startApplication(List<Photo> photos) {
  while (true) {
    runApplicationRound(photos, stdin.readLineSync);
  }
}
