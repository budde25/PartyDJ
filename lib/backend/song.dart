class Song {
  String name;
  String artist;
  String uri;
  int id;
  String imageUri;

  Song(String name, String artist, String track) {
    this.name = name;
    this.artist = artist;
    this.uri = track;
  }

  bool operator ==(o) => o is Song && o.name == name && o.uri == uri;
  int get hashCode => uri.hashCode;
}