class ActivityContext {
  const ActivityContext({
    this.category = 'idle',
    this.app = '',
    this.title = '',
    this.artist = '',
    this.playing = false,
  });
  final String category, app, title, artist;
  final bool playing;
  factory ActivityContext.fromMap(Map data) => ActivityContext(
    category: data['category'] as String? ?? 'idle',
    app: data['app'] as String? ?? '',
    title: data['title'] as String? ?? '',
    artist: data['artist'] as String? ?? '',
    playing: data['playing'] == true,
  );
  bool get supported => ['music', 'video', 'game'].contains(category);
  String get fingerprint => '$category|$app|$title|$artist|$playing';
  String get description => supported
      ? '$category app: $app; playing: $playing; media title: $title; artist: $artist'
      : 'No supported activity detected.';
  String get reaction => switch (category) {
    'music' =>
      title.isEmpty
          ? 'Music is playing in $app. Enjoy your listening time!'
          : 'Now playing: $title${artist.isEmpty ? '' : ' by $artist'}. Enjoy!',
    'video' =>
      title.isEmpty
          ? '$app is open. Ready for a watching break?'
          : 'Watching $title on $app? I’m here if you want to chat.',
    'game' => 'Have fun in $app! You can ask me for game tips.',
    _ => 'I’m here. Tap me to chat, or start some music.',
  };
}
