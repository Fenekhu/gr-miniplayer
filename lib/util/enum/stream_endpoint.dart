enum StreamEndpoint {
    mobile(value: '2', name: 'Mobile',   desc: '64k Opus'),
  standard(value: '1', name: 'Standard', desc: '128k mp3'),
      high(value: '3', name: 'High',     desc: '256k mp3'),
  lossless(value: '4', name: 'Lossless', desc: 'FLAC'    ),
  //   hls(value: '5', name: 'HLS',      desc: 'AAC'     )
  ;

  final String value;
  final String name;
  final String desc;

  Uri get uri => Uri.parse('https://stream.gensokyoradio.net/$value/');

  const StreamEndpoint({required this.value, required this.name, required this.desc});

  static StreamEndpoint fromValue(String value) => switch (value) {
    '2' => StreamEndpoint.mobile,
    '1' => StreamEndpoint.standard,
    '3' => StreamEndpoint.high,
    '4' => StreamEndpoint.lossless,
//  '5' => StreamEndpoint.hls,
     _  => StreamEndpoint.standard,
  };
}