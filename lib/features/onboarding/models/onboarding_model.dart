class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

// List data untuk onboarding
final List<OnboardingItem> onboardingContents = [
  OnboardingItem(
    image: 'assets/onboarding1.png',
    title: 'Pantau Tanamanmu',
    description:
        'Catat kemajuan dan siram tanamanmu tepat waktu dengan pengingat otomatis.',
  ),
  OnboardingItem(
    image: 'assets/onboarding2.png',
    title: 'Komunitas Hijau',
    description:
        'Berbagi tips dan pengalaman berkebun dengan sesama pencinta tanaman.',
  ),
];
