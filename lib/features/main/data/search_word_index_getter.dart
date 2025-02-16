List<String> getStringPortions(String query, String source) {
  int startIndex = source.indexOf(query);
  bool notFound = startIndex == -1;
  if (notFound) {
    return ['', source, ''];
  }
  int endIndex = startIndex + query.length - 1;
  String beforeMatch = source.substring(0, startIndex);
  String matchPortion = source.substring(startIndex, endIndex + 1);
  String afterMatch = source.substring(endIndex + 1, source.length);
  return [beforeMatch, matchPortion, afterMatch];
}
