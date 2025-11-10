enum Animals {
  fox('🦊'),
  rabbit('🐰'),
  cat('🐱'),
  dog('🐶'),
  bear('🐻'),
  panda('🐼'),
  sheep('🐑'),
  koala('🐨'),
  wolf('🐺'),
  chipmunk('🐿️');

  final String emoji;

  const Animals(this.emoji);

  factory Animals.fromName(String name) {
    return switch (name) {
      'fox' => Animals.fox,
      'rabbit' => Animals.rabbit,
      'cat' => Animals.cat,
      'dog' => Animals.dog,
      'bear' => Animals.bear,
      'panda' => Animals.panda,
      'sheep' => Animals.sheep,
      'koala' => Animals.koala,
      'wolf' => Animals.wolf,
      'chipmunk' => Animals.chipmunk,
      _ => Animals.sheep,
    };
  }
}
