enum StreamEndpoint {
    mobile(value: '1', name: 'Mobile',   desc: '64k Opus'),
  standard(value: '2', name: 'Standard', desc: '128k mp3'),
      high(value: '3', name: 'High',     desc: '256k mp3'),
  lossless(value: '4', name: 'Lossless', desc: 'FLAC'    ),
       hls(value: '5', name: 'HLS',      desc: 'AAC'     );

  final String value;
  final String name;
  final String desc;

  const StreamEndpoint({required this.value, required this.name, required this.desc});

  static StreamEndpoint fromValue(String value) => switch (value) {
    '1' => StreamEndpoint.mobile,
    '2' => StreamEndpoint.standard,
    '3' => StreamEndpoint.high,
    '4' => StreamEndpoint.lossless,
    '5' => StreamEndpoint.hls,
     _  => StreamEndpoint.standard,
  };
}