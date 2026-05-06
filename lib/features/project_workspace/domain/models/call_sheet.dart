class CallSheet {
  const CallSheet({
    required this.id,
    required this.title,
    required this.sectionSummaries,
  });

  final String id;
  final String title;
  final List<String> sectionSummaries;
}
