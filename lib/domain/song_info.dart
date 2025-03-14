class SongInfo {
  final String songID;
  final String title;
  final String artist;
  final String albumID;
  final String album;
  final String circle;
  final int    year;
  final String albumArt;
  final int    duration;
  final int    played;
  final int    remaining;
  final bool   hideArt;

  const SongInfo({
    required this.songID, 
    required this.title, 
    required this.artist, 
    required this.albumID, 
    required this.album, 
    required this.circle, 
    required this.year, 
    required this.albumArt, 
    required this.duration, 
    required this.played, 
    required this.remaining,
    required this.hideArt,
  });
}