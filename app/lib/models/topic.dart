class Topic {
  final String id;
  final String label;
  final String icon;
  final String prompt;

  const Topic({
    required this.id,
    required this.label,
    required this.icon,
    required this.prompt,
  });

  factory Topic.fromJson(Map<String, dynamic> j) => Topic(
    id: j['id'] as String,
    label: j['label'] as String,
    icon: j['icon'] as String,
    prompt: j['prompt'] as String,
  );
}

class Faq {
  final int id;
  final String question;

  const Faq({required this.id, required this.question});

  factory Faq.fromJson(Map<String, dynamic> j) => Faq(
    id: j['id'] as int,
    question: j['question'] as String,
  );
}
