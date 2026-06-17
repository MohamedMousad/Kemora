class AchievementInfo {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isEarned;

  const AchievementInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.isEarned,
  });
}

final List<AchievementInfo> achievementsData = [
  const AchievementInfo(
    id: 'a1',
    title: 'Explorer',
    description: 'Visit 5 different governorates',
    points: 100,
    isEarned: true,
  ),
  const AchievementInfo(
    id: 'a2',
    title: 'Nile Legend',
    description: 'Complete a Nile cruise itinerary',
    points: 250,
    isEarned: true,
  ),
  const AchievementInfo(
    id: 'a3',
    title: 'Oasis King',
    description: 'Visit 3 desert oases',
    points: 150,
    isEarned: false,
  ),
  const AchievementInfo(
    id: 'a4',
    title: 'Sand Runner',
    description: 'Complete a desert safari trip',
    points: 200,
    isEarned: false,
  ),
  const AchievementInfo(
    id: 'a5',
    title: 'Temple Walker',
    description: 'Visit 10 ancient temples',
    points: 300,
    isEarned: false,
  ),
  const AchievementInfo(
    id: 'a6',
    title: 'Foodie Pharaoh',
    description: 'Review 15 local restaurants',
    points: 175,
    isEarned: false,
  ),
  const AchievementInfo(
    id: 'a7',
    title: 'Sunset Chaser',
    description: 'Visit 5 famous sunset viewpoints',
    points: 125,
    isEarned: false,
  ),
  const AchievementInfo(
    id: 'a8',
    title: 'History Buff',
    description: 'Read all info panels at 3 sites',
    points: 100,
    isEarned: false,
  ),
];
