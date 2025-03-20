/// utilities for processing json API responses.
library;

import 'dart:convert';

// the api is not consistent with types. For example, sometimes you may get year: 2019 or year: '2019'.
// Calling .toString on either will convert it to '2019', which can then be parsed.
// Extra considerations have been made for null or invalid values.
int? tryToInt(dynamic v) {
  if (v == null) return null;
  return int.tryParse(v.toString());
}

bool? tryToBool(dynamic v, {bool caseSensitive = false}) {
  if (v == null) return null;
  return bool.tryParse(v.toString(), caseSensitive: caseSensitive);
}

// Some API calls respond with an object wrapped in a single item list. This
/// returns the json object, or the first item if the top level is a list.
Map<String, dynamic> unwrapJson(String data) {
  final json = jsonDecode(data);
  if (json is List<dynamic>) {
    return json.first as Map<String, dynamic>;
  }
  return json as Map<String, dynamic>;
}