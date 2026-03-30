class HomeModel {
  const HomeModel({
    this.title = 'WolfChat',
    this.subtitle = 'Bem-vindo ao WolfChat',
    this.featureCards = const [
      FeatureCard(
        title: 'Chat em tempo real',
        subtitle: 'Converse com seus amigos instantaneamente',
      ),
      FeatureCard(
        title: 'Criptografia ponta a ponta',
        subtitle: 'Suas mensagens sempre seguras e privadas',
      ),
      FeatureCard(
        title: 'Design expressivo',
        subtitle: 'Interface moderna com Material Design 3',
      ),
    ],
  });

  final String title;
  final String subtitle;
  final List<FeatureCard> featureCards;
}

class FeatureCard {
  const FeatureCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
