class Definition {
  final List<String> videoLinks;
  final List<String> keywords;
  final Map<String, List<String>> definitions;
  final List<int> regions;

  Definition({
    required this.videoLinks,
    required this.keywords,
    required this.definitions,
    required this.regions,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      videoLinks: (json['video_links'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e.toString()).toList(),
      definitions: (json['definitions'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      ),
      regions: (json['regions'] as List<dynamic>)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Video Links: ${videoLinks.join(', ')}\n'
        'Keywords: ${keywords.join(', ')}\n'
        'Definitions: ${definitions.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('\n')}\n'
        'Regions: ${regions.join(', ')}';
  }
}

class SearchResult {
  final Map<String, List<Definition>> results;

  SearchResult({required this.results});
}
