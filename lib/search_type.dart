enum SearchType {
  photoId,
  albumId,
  title;

  static SearchType? of(String s) {
    if (s.toUpperCase() == 'I') return photoId;
    if (s.toUpperCase() == 'A') return albumId;
    if (s.toUpperCase() == 'T') return title;
    return null;
  }

  @override
  String toString() {
    switch (this) {
      case photoId: return 'photo id';
      case albumId: return 'album id';
      case title: return 'title';
    }
  }
}