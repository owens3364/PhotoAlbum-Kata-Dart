import 'dart:core';

class Photo {
  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    photoId: json['id'],
    albumId: json['albumId'],
    title: json['title'],
    photoUrl: json['url'],
    thumbnailUrl: json['thumbnailUrl'],
  );

  const Photo({
    required this.photoId,
    required this.albumId,
    required this.title,
    required this.photoUrl,
    required this.thumbnailUrl,
  });

  final int photoId;
  final int albumId;
  final String title;
  final String photoUrl;
  final String thumbnailUrl;

  @override
  String toString() => 'Photo | $title; ID: $photoId; Album: $albumId; URL: $photoUrl; Thumbnail: $thumbnailUrl';

  @override
  int get hashCode => Object.hash(photoId, albumId, title, photoUrl, thumbnailUrl);

  @override
  bool operator ==(Object other) {
    return other is Photo
        && other.photoId == photoId
        && other.albumId == albumId
        && other.title == title
        && other.photoUrl == photoUrl
        && other.thumbnailUrl == thumbnailUrl;
  }
}