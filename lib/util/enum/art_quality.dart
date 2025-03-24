// the station is able to provide album images at two different resolutions
enum ArtQuality {
   standard(name: 'Standard',  value: '500'),
     mobile(name: 'Mobile',    value: '200'),
        low(name: 'Low',       value: '100'),
  thumbnail(name: 'Thumbnail', value:  '40'),

  ;

  final String name;
  final String value;

  const ArtQuality({required this.name, required this.value});

  static ArtQuality fromValue(String value) => switch (value) {
     '40' => ArtQuality.thumbnail,
    '100' => ArtQuality.low,
    '200' => ArtQuality.mobile,
    '500' => ArtQuality.standard,
      _   => ArtQuality.standard,
  };
}