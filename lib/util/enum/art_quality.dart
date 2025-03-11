enum ArtQuality {
  standard(name: 'Standard', value: '500'),
    mobile(name: 'Mobile',   value: '200');

  final String name;
  final String value;

  const ArtQuality({required this.name, required this.value});

  static ArtQuality fromValue(String value) => switch (value) {
    '200' => ArtQuality.mobile,
    '500' => ArtQuality.standard,
      _   => ArtQuality.standard,
  };
}