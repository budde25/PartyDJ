class Song {
  final String name;
  final String artist;
  final String uri;
  final String albumUrl;
  int id;

  Song(this.name, this.artist, this.uri, this.albumUrl);

  bool operator ==(o) => o is Song && o.name == name && o.uri == uri;

  int get hashCode => uri.hashCode;
}
