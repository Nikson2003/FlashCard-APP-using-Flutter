import 'package:flutter/material.dart';
import 'models/flashcard.dart';

class FlashcardProvider with ChangeNotifier {
  final List<Flashcard> _flashcards = [
    Flashcard(
      id: 1,
      question: 'What does the border color represent?',
      answer:
          'If the color is blue, it represents it is an unflipped flashcard. Green represents the answer side, and red represents the question side after it has been flipped once.',
      creationDate: DateTime(2024, 12, 18, 20, 0),
    ),
    Flashcard(
      id: 2,
      question: 'Who is the developer of this Application?',
      answer: 'Nikson Nadar (niknadar92@gmail.com)',
      creationDate: DateTime(2024, 12, 18, 20, 2),
    ),
    Flashcard(
      id: 2,
      question: 'What are the icons for?',
      answer:
          'The blue pencil icon is for editing the question and answer, black calendar icon is for viewing the card creation details and the red bin icon is for deleting the card',
      creationDate: DateTime(2024, 12, 18, 20, 3),
    ),
  ];

  List<Flashcard> get flashcards => _flashcards;

  void addFlashcard(String question, String answer) {
    // Generate a new ID by getting the next available ID
    final newId = _flashcards.isEmpty ? 1 : _flashcards.last.id + 1;
    _flashcards.add(Flashcard(
      id: newId,
      question: question,
      answer: answer,
      creationDate: DateTime.now(),
    ));
    notifyListeners();
  }

  void editFlashcard(int index, String question, String answer) {
    _flashcards[index].question = question;
    _flashcards[index].answer = answer;
    notifyListeners();
  }

  void deleteFlashcard(int index) {
    _flashcards.removeAt(index);
    notifyListeners();
  }
}
