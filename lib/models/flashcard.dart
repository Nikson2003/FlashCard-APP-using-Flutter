class Flashcard {
  static int _idCounter = 2;
  int id;
  String question;
  String answer;
  DateTime creationDate;

  Flashcard({
    int? id,
    required this.question,
    required this.answer,
    DateTime? creationDate,
  })  : id = _generateId(),
        creationDate = creationDate ?? DateTime.now();

  // Helper method to increment and return the counter
  static int _generateId() {
    _idCounter++;
    return _idCounter;
  }
}
