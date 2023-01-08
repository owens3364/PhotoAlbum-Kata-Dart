import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_album/application.dart';
import 'package:photo_album/photo.dart';
import 'package:photo_album/search_type.dart';
import 'package:test/test.dart';

abstract class PrintFunction {
  void call(dynamic args);
}

abstract class ReadLineFunction {
  String? call();
}

class MockPrintFunction extends Mock implements PrintFunction {}
class MockReadLineFunction extends Mock implements ReadLineFunction {}

void main() {
  final Faker faker = Faker();

  Function(dynamic) mockPrintFunction = MockPrintFunction();
  String? Function() mockReadLineFunction = MockReadLineFunction();

  setUp(() {
    mockPrintFunction = MockPrintFunction();
    mockReadLineFunction = MockReadLineFunction();
  });

  group('getSearchType', () {
    test('Should print instructions for user', () {
      try {
        getSearchType(() => throw Exception(), mockPrintFunction);
      } on Exception {}
      verify(mockPrintFunction('Enter "a" to find all photos in an specific album, "i" to show a photo with a specific ID, "t" to search for photos by title, or "q" to quit.'));
    });

    test('Should read user input', () {
      when(mockReadLineFunction()).thenReturn('q');
      try {
        getSearchType(mockReadLineFunction, mockPrintFunction);
      } catch (e) {}
      verify(mockReadLineFunction());
    });

    test('Should exit on q inputted', () {
      when(mockReadLineFunction()).thenReturn('q');
      dynamic thrown;
      try {
        getSearchType(mockReadLineFunction, mockPrintFunction);
      } catch (e) {
        thrown = e;
      }
      expect(thrown, "Exit");
    });

    test('Should exit on Q inputted', () {
      when(mockReadLineFunction()).thenReturn('Q');
      dynamic thrown;
      try {
        getSearchType(mockReadLineFunction, mockPrintFunction);
      } catch (e) {
        thrown = e;
      }
      expect(thrown, "Exit");
    });

    test('Should return search type for valid SearchType inputs', () {
      when(mockReadLineFunction()).thenReturn(faker.randomGenerator.element('IiAaTt'.split('')));
      SearchType searchType = getSearchType(mockReadLineFunction, mockPrintFunction);
      expect(SearchType.values.contains(searchType), isTrue);
    });

    test('Should state invalid input and try again if input is invalid', () {
      List<String Function()> mockReturns = [() => faker.randomGenerator.string(12), () => throw Exception()];
      when(mockReadLineFunction()).thenAnswer((_) => mockReturns.removeAt(0)());
      try {
        getSearchType(mockReadLineFunction, mockPrintFunction);
      } on Exception {}
      verify(mockPrintFunction('Invalid input; please try again.\n'));
      verify(mockPrintFunction('Enter "a" to find all photos in an specific album, "i" to show a photo with a specific ID, "t" to search for photos by title, or "q" to quit.')).called(2);
    });
  });

  group('getQuery', () {
    test('Should print instructions for user', () {
      SearchType searchType = faker.randomGenerator.element(SearchType.values);
      try {
        getQuery(searchType, () => throw Exception(), mockPrintFunction);
      } on Exception {}
      verify(mockPrintFunction('Enter a query for $searchType.'));
    });

    test('Should read user input', () {
      SearchType searchType = faker.randomGenerator.element(SearchType.values);
      when(mockReadLineFunction()).thenAnswer((_) => throw Exception());
      try {
        getQuery(searchType, mockReadLineFunction, mockPrintFunction);
      } on Exception {}
      verify(mockReadLineFunction());
    });

    test('Should state null input is invalid', () {
      SearchType searchType = faker.randomGenerator.element(SearchType.values);
      List<String? Function()> mockReturns = [() => null, () => throw Exception()];
      when(mockReadLineFunction()).thenAnswer((_) => mockReturns.removeAt(0)());
      try {
        getQuery(searchType, mockReadLineFunction, mockPrintFunction);
      } on Exception {}
      verify(mockPrintFunction('Invalid input; please try again.\n'));
      verify(mockPrintFunction('Enter a query for $searchType.')).called(2);
    });

    test('Should state blank input is invalid', () {
      SearchType searchType = faker.randomGenerator.element(SearchType.values);
      List<String? Function()> mockReturns = [() => '', () => throw Exception()];
      when(mockReadLineFunction()).thenAnswer((_) => mockReturns.removeAt(0)());
      try {
        getQuery(searchType, mockReadLineFunction, mockPrintFunction);
      } on Exception {}
      verify(mockPrintFunction('Invalid input; please try again.\n'));
      verify(mockPrintFunction('Enter a query for $searchType.')).called(2);
    });

    test('Should accept any input when searchType is SearchType.title', () {
      String queryInput = faker.randomGenerator.string(12);
      when(mockReadLineFunction()).thenReturn(queryInput);
      String queryResult = getQuery(SearchType.title, mockReadLineFunction, mockPrintFunction);
      expect(queryResult, queryInput);
    });

    test('Should mark non-integers as invalid when searchType is SearchType.photoId or SearchType.albumId', () {
      // This was occasionally generating actual numbers; making the random string longer makes this almost impossible to happen again by chance
      String queryInput = faker.randomGenerator.string(20, min: 10);
      List<String Function()> mockReturns = [() => queryInput, () => throw Exception()];
      when(mockReadLineFunction()).thenAnswer((_) => mockReturns.removeAt(0)());
      SearchType searchType = faker.randomGenerator.element([SearchType.photoId, SearchType.albumId]);
      try {
        getQuery(searchType, mockReadLineFunction, mockPrintFunction);
      } on Exception {}
      verify(mockPrintFunction('Invalid input; please try again.\n'));
      verify(mockPrintFunction('Enter a query for $searchType.')).called(2);
    });

    test('Should accept integers as valid input when searchType is SearchType.photoId or SearchType.albumId', () {
      String queryInput = faker.randomGenerator.integer(10000).toString();
      when(mockReadLineFunction()).thenReturn(queryInput);
      String queryResult = getQuery(faker.randomGenerator.element([SearchType.photoId, SearchType.albumId]), mockReadLineFunction, mockPrintFunction);
      expect(queryResult, queryInput);
    });
  });

  group('getResultForQuery', () {
    test('photoId search returns photos for specified photo id', () {
      List<Photo> photos = [1, 2, 3, 4].map(generateRandomPhotoWithId).toList();
      int chosenId = faker.randomGenerator.integer(5, min: 1);
      List<Photo> queryResults = getResultsForQuery(photos, SearchType.photoId, chosenId.toString());
      expect(queryResults.length, 1);
      expect(queryResults.first.photoId, chosenId);
      expect(photos.firstWhere((p) => p.photoId == chosenId), queryResults.first);
    });

    test('photoId search returns empty array when no photo ids match query', () {
      List<Photo> photos = [1, 2, 3, 4].map(generateRandomPhotoWithId).toList();
      int chosenId = faker.randomGenerator.integer(10000, min: 5);
      List<Photo> queryResults = getResultsForQuery(photos, SearchType.photoId, chosenId.toString());
      expect(queryResults.isEmpty, isTrue);
    });

    test('albumId search returns photos for specified album id', () {
      List<Photo> photos = [1, 2, 2, 2, 3, 4].map(generateRandomPhotoWithAlbumId).toList();
      int chosenId = 2;
      List<Photo> queryResults = getResultsForQuery(photos, SearchType.albumId, chosenId.toString());
      expect(queryResults.length, 3);
      expect(queryResults[0].albumId, chosenId);
      expect(queryResults[1].albumId, chosenId);
      expect(queryResults[2].albumId, chosenId);
    });

    test('albumId search returns empty array when no album ids match query', () {
      List<Photo> photos = [1, 2, 2, 2, 3, 4].map(generateRandomPhotoWithAlbumId).toList();
      int chosenId = faker.randomGenerator.integer(10000, min: 5);
      List<Photo> queryResults = getResultsForQuery(photos, SearchType.albumId, chosenId.toString());
      expect(queryResults.isEmpty, isTrue);
    });

    test('title search returns photos for with query string in the title regardless of casing', () {
      String titleWord1 = faker.lorem.word();
      String titleWord2 = faker.lorem.word();
      String titleWord3 = faker.lorem.word();
      String titleWord4 = faker.lorem.word();
      List<Photo> photos = [
        titleWord1,
        titleWord2,
        titleWord2,
        titleWord2,
        titleWord3,
        titleWord4,
      ].map(generateRandomPhotoWithWordInTitle).toList();
      String queryWord = titleWord2;
      List<Photo> queryResults = getResultsForQuery(photos, SearchType.title, queryWord);
      expect(queryResults.length, 3);
      expect(queryResults[0].title.toUpperCase().contains(queryWord.toUpperCase()), isTrue);
      expect(queryResults[1].title.toUpperCase().contains(queryWord.toUpperCase()), isTrue);
      expect(queryResults[2].title.toUpperCase().contains(queryWord.toUpperCase()), isTrue);
    });

    test('title search returns empty array when no photos have the query string in their title', () {
      String titleWord1 = faker.lorem.word();
      String titleWord2 = faker.lorem.word();
      String titleWord3 = faker.lorem.word();
      String titleWord4 = faker.lorem.word();
      List<Photo> photos = [
        titleWord1,
        titleWord2,
        titleWord2,
        titleWord2,
        titleWord3,
        titleWord4,
      ].map(generateRandomPhotoWithWordInTitle).toList();
      String queryWord = faker.lorem.sentence();
      List<Photo> queryResults = getResultsForQuery(photos, SearchType.title, queryWord);
      expect(queryResults.isEmpty, isTrue);
    });
  });
}

Photo generateRandomPhotoWithId(int id) => Photo(
    photoId: id,
    albumId:
    faker.randomGenerator.integer(10000),
    title: faker.lorem.sentence(),
    photoUrl: faker.internet.httpsUrl(),
    thumbnailUrl: faker.internet.httpsUrl(),
);

Photo generateRandomPhotoWithAlbumId(int albumId) => Photo(
  photoId: faker.randomGenerator.integer(10000),
  albumId: albumId,
  title: faker.lorem.sentence(),
  photoUrl: faker.internet.httpsUrl(),
  thumbnailUrl: faker.internet.httpsUrl(),
);

Photo generateRandomPhotoWithWordInTitle(String title) => Photo(
  photoId: faker.randomGenerator.integer(10000),
  albumId: faker.randomGenerator.integer(10000),
  title: '${faker.lorem.sentence()} $title ${faker.lorem.sentence()}',
  photoUrl: faker.internet.httpsUrl(),
  thumbnailUrl: faker.internet.httpsUrl(),
);
