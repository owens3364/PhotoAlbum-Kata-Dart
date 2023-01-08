import 'package:photo_album/photo.dart';
import 'package:photo_album/search_type.dart';

void runApplicationRound(List<Photo> photos, String? Function() readLine, [Function(dynamic) print = print]) {
  SearchType searchType = getSearchType(readLine, print);
  String query = getQuery(searchType, readLine, print);
  List<Photo> resultsForQuery = getResultsForQuery(photos, searchType, query);
  if (resultsForQuery.isEmpty) {
    print('No results.\n');
  } else {
    print('Results');
    print('--------------------------------');
    resultsForQuery.forEach(print);
    print('--------------------------------');
  }
}

SearchType getSearchType(String? Function() readLine, Function(dynamic) print) {
  while (true) {
    print('Enter "a" to find all photos in an specific album, "i" to show a photo with a specific ID, "t" to search for photos by title, or "q" to quit.');
    String input = readLine() ?? '';
    if (input.toUpperCase() == 'Q') throw 'Exit';
    SearchType? searchType = SearchType.of(input);
    if (searchType != null) return searchType;
    print('Invalid input; please try again.\n');
  }
}

String getQuery(SearchType searchType, String? Function() readLine, Function(dynamic) print) {
  while (true) {
    print('Enter a query for $searchType.');
    String? query = readLine();
    if (query != null && query != '') {
      if (searchType == SearchType.title) return query;
      if (int.tryParse(query) != null) return query;
    }
    print('Invalid input; please try again.\n');
  }
}

List<Photo> getResultsForQuery(List<Photo> photos, SearchType searchType, String query) {
  switch (searchType) {
    case SearchType.photoId: return photos.where((p) => p.photoId == int.parse(query)).toList();
    case SearchType.albumId: return photos.where((p) => p.albumId == int.parse(query)).toList();
    case SearchType.title: return photos.where((p) => p.title.toUpperCase().contains(query.toUpperCase())).toList();
  }
}