import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:photo_album/photo.dart';
import 'package:test/test.dart';

void main() {
  final Faker faker = Faker();

  group('Photo', () {
    test('Photo factory generates itself from JSON', () {
      int photoId = faker.randomGenerator.integer(10000);
      int albumId = faker.randomGenerator.integer(10000);
      String title = faker.lorem.sentence();
      String photoUrl = faker.internet.httpsUrl();
      String thumbnailUrl = faker.internet.httpsUrl();
      expect(Photo(
        photoId: photoId,
        albumId: albumId,
        title: title,
        photoUrl: photoUrl,
        thumbnailUrl: thumbnailUrl,
      ), Photo.fromJson(jsonDecode('{"id": $photoId, "albumId": $albumId, "title": "$title", "url": "$photoUrl", "thumbnailUrl": "$thumbnailUrl"}')));
    });
  });
}
