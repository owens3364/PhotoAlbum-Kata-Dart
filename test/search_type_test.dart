import 'package:photo_album/search_type.dart';
import 'package:test/test.dart';

void main() {
  group('SearchType', () {
    test('SearchType of i is SearchType.photoId', () {
      expect(SearchType.of('i'), SearchType.photoId);
    });

    test('SearchType of I is SearchType.photoId', () {
      expect(SearchType.of('I'), SearchType.photoId);
    });

    test('SearchType of a is SearchType.photoId', () {
      expect(SearchType.of('a'), SearchType.albumId);
    });

    test('SearchType of A is SearchType.photoId', () {
      expect(SearchType.of('A'), SearchType.albumId);
    });

    test('SearchType of t is SearchType.photoId', () {
      expect(SearchType.of('t'), SearchType.title);
    });

    test('SearchType of T is SearchType.photoId', () {
      expect(SearchType.of('T'), SearchType.title);
    });

    test('SearchType of empty string is null', () {
      expect(SearchType.of(''), null);
    });

    test('SearchType of garbage data is null', () {
      expect(SearchType.of('awefiodsnajf'), null);
    });

    test('SearchType toString of photoId is photo id', () {
      expect(SearchType.photoId.toString(), 'photo id');
    });

    test('SearchType toString of albumId is album id', () {
      expect(SearchType.albumId.toString(), 'album id');
    });

    test('SearchType toString of title is title', () {
      expect(SearchType.title.toString(), 'title');
    });
  });
}
