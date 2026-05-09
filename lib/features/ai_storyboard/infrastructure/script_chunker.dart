class ScriptChunker {
  const ScriptChunker();

  List<String> chunk(String rawScript) {
    final paragraphChunks = rawScript
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n\s*\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (paragraphChunks.isNotEmpty) {
      return paragraphChunks;
    }

    return rawScript
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
