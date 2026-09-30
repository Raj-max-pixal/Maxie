enum MaxiePhaseStatus {
  complete,
  inProgress,
  locked,
}

class MaxiePhase {
  const MaxiePhase({
    required this.number,
    required this.title,
    required this.summary,
    required this.status,
    this.missionLabel,
  });

  final int number;
  final String title;
  final String summary;
  final MaxiePhaseStatus status;
  final String? missionLabel;

  String get statusEmoji {
    switch (status) {
      case MaxiePhaseStatus.complete:
        return '✅';
      case MaxiePhaseStatus.inProgress:
        return '🔄';
      case MaxiePhaseStatus.locked:
        return '🔒';
    }
  }

  String get paddedNumber => number.toString().padLeft(2, '0');
}
