class FAQModel {
  String? id;
  String? question;
  String? answer;
  String? createdAt;
  String? updatedAt;

  FAQModel({
    this.id,
    this.question,
    this.answer,
    this.createdAt,
    this.updatedAt,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['_id'],
      question: json['question'],
      answer: json['answer'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'answer': answer,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
