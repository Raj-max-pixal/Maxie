import 'package:maxie_mobile/features/mission_control/domain/models/maxie_phase.dart';

/// Canonical 18-phase MAXie roadmap — single source of truth for Mission Control.
const maxieRoadmapPhases = <MaxiePhase>[
  MaxiePhase(
    number: 1,
    title: 'Core Foundation',
    summary: 'Flutter app, navigation, Riverpod, Hive, core models.',
    status: MaxiePhaseStatus.complete,
  ),
  MaxiePhase(
    number: 2,
    title: 'Generic Character Engine',
    summary: 'Character state, animation hooks, interaction layer.',
    status: MaxiePhaseStatus.complete,
  ),
  MaxiePhase(
    number: 3,
    title: 'Shimeji Screen Pets',
    summary: 'Movement, physics, drag, multi-pet demo, persistence.',
    status: MaxiePhaseStatus.complete,
  ),
  MaxiePhase(
    number: 4,
    title: 'MAXie Character & Intelligence',
    summary: 'Identity, AI chat, memory brain, companion reactions.',
    status: MaxiePhaseStatus.inProgress,
    missionLabel: 'Build AI Companion Intelligence',
  ),
  MaxiePhase(
    number: 5,
    title: 'Multi-Character System',
    summary: 'Multiple companions with separate state and memory.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 6,
    title: 'AI Communication',
    summary: 'Providers, streaming, voice, character-aware replies.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 7,
    title: 'Character-to-Character',
    summary: 'Companions interact with each other on screen.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 8,
    title: 'Advanced Movement',
    summary: 'Flying, climbing, exploration, environment hooks.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 9,
    title: 'Clothing & Customization',
    summary: 'Outfits, inventory, unlock progression.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 10,
    title: 'Character Creator',
    summary: 'User-built companions for the MAXie Universe.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 11,
    title: 'Personality Engine',
    summary: 'Traits drive dialogue, movement, and reactions.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 12,
    title: 'Productivity Companion',
    summary: 'Tasks, focus, study, coding sessions with MAXie.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 13,
    title: 'Gamification & Mini-Games',
    summary: 'XP, achievements, coins, playable loops.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 14,
    title: 'Worlds / Environments',
    summary: 'Bedroom, forest, arcade — places characters live.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 15,
    title: 'PC Companion',
    summary: 'Desktop pet, app awareness, contextual behavior.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 16,
    title: 'Cloud / Cross-Device Sync',
    summary: 'One MAXie identity on phone and desktop.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 17,
    title: 'Social / Community',
    summary: 'Sharing characters, worlds, and user content.',
    status: MaxiePhaseStatus.locked,
  ),
  MaxiePhase(
    number: 18,
    title: 'MAXie Universe',
    summary: 'Full ecosystem: mobile, desktop, cloud, community.',
    status: MaxiePhaseStatus.locked,
  ),
];

MaxiePhase? currentMissionPhase(List<MaxiePhase> phases) {
  for (final phase in phases) {
    if (phase.status == MaxiePhaseStatus.inProgress) {
      return phase;
    }
  }
  for (final phase in phases) {
    if (phase.status == MaxiePhaseStatus.locked) {
      return phase;
    }
  }
  return phases.isEmpty ? null : phases.last;
}

double roadmapProgressPercent(List<MaxiePhase> phases) {
  if (phases.isEmpty) {
    return 0;
  }
  var score = 0.0;
  for (final phase in phases) {
    switch (phase.status) {
      case MaxiePhaseStatus.complete:
        score += 1;
      case MaxiePhaseStatus.inProgress:
        score += 0.55;
      case MaxiePhaseStatus.locked:
        break;
    }
  }
  return (score / phases.length * 100).clamp(0, 100);
}
