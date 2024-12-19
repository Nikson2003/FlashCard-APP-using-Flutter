import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flashcard_provider.dart';
import 'models/flashcard.dart';

class AddEditScreen extends StatefulWidget {
  final int? index;
  final Flashcard? flashcard;

  const AddEditScreen({Key? key, this.index, this.flashcard}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the flashcard data if available
    _questionController = TextEditingController(
      text: widget.flashcard?.question ?? '',
    );
    _answerController = TextEditingController(
      text: widget.flashcard?.answer ?? '',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = Provider.of<FlashcardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null ? 'Add Flashcard' : 'Edit Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a question'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an answer'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.index == null) {
                      // Add a new flashcard with a generated ID
                      flashcardProvider.addFlashcard(
                        _questionController.text,
                        _answerController.text,
                      );
                    } else {
                      // Edit an existing flashcard with its ID
                      flashcardProvider.editFlashcard(
                        widget.index!,
                        _questionController.text,
                        _answerController.text,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.index == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
