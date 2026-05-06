class PlanAssignment {
  const PlanAssignment({
    required this.shotId,
    required this.sectionId,
    required this.orderIndex,
  });

  final String shotId;
  final String sectionId;
  final int orderIndex;
}

class PlanSection {
  const PlanSection({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.shotIds,
  });

  final String id;
  final String name;
  final int orderIndex;
  final List<String> shotIds;
}

class PlanBoard {
  const PlanBoard({
    required this.unassignedShotIds,
    required this.sections,
  });

  final List<String> unassignedShotIds;
  final List<PlanSection> sections;
}
