class OnboardingPageModel {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  static const List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: 'التمريض العملي بقى أسهل!',
      description:
          'هتلاقي شرح مبسط وواضح لكل البروسيدجرات اللي محتاجها، عشان تراجع وتفهم وتطبق بثقة.',
      imagePath: 'assets/images/onboarding1.png',
    ),
    OnboardingPageModel(
      title: 'خطوة بخطوة',
      description:
          'كل بروسيدجر مقسم لخطوات واضحة، مع شرح السبب ورا كل خطوة عشان تفهم ليه بنعملها.',
      imagePath: 'assets/images/onboarding2.png',
    ),
    OnboardingPageModel(
      title: 'احفظ وراجع في أي وقت',
      description:
          'احفظ البروسيدجرات المهمة وارجعلها بسهولة وقت ما تحتاج، حتى من غير نت.',
      imagePath: 'assets/images/onboarding3.png',
    ),
  ];
}
