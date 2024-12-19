import 'package:flashcard_app/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'flashcard_provider.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Map<int, AnimationController> _animationControllers = {};
  final Map<int, Animation<double>> _flippingAnimations = {};
  final Map<int, int> _tapCount = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // Dispose all animation controllers
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimation(int index) {
    if (_animationControllers[index] == null) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 900), // Smooth animation
        vsync: this,
      );
      final animation = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
      _animationControllers[index] = controller;
      _flippingAnimations[index] = animation;
    }
  }

  void _flipCard(int index, Flashcard flashcard) {
    setState(() {
      _tapCount[flashcard.id] = (_tapCount[flashcard.id] ?? 0) + 1;
    });

    final controller = _animationControllers[index]!;
    if (controller.isCompleted || controller.velocity > 0) {
      controller.reverse(); // Flip back
    } else {
      controller.forward(); // Flip forward
    }
  }

  Color _getShadowColor(int index) {
    final count = _tapCount[index] ?? 0;
    if (count == 0) return Colors.blue;
    return count % 2 == 0 ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = Provider.of<FlashcardProvider>(context);
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards'),
      ),
      body: flashcardProvider.flashcards.isEmpty
          ? const Center(
              child: Text('No flashcards available. Add some!'),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: flashcardProvider.flashcards.length,
              reverse: true,
              padding: EdgeInsets.only(top: 30, bottom: 50),
              itemBuilder: (context, index) {
                final flashcard = flashcardProvider.flashcards[index];

                _initializeAnimation(index);
                final animation = _flippingAnimations[index]!;
                final shadowColor = _getShadowColor(flashcard.id);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 100,
                      height: MediaQuery.of(context).size.width - 100,
                      child: GestureDetector(
                        onTap: () => _flipCard(index, flashcard),
                        child: AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final isFront = animation.value < pi / 2;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(animation.value),
                              child: isFront
                                  ? _buildFrontCard(
                                      flashcard, shadowColor, index)
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: _buildBackCard(
                                          flashcard, shadowColor),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditScreen(),
            ),
          ).then((_) {
            double deviceHeight = MediaQuery.of(context).size.height;
            final scrollToPosition = deviceHeight;
            _scrollController.animateTo(
              scrollToPosition,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }

  Widget _buildFrontCard(flashcard, Color shadowColor, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 12,
      shadowColor: shadowColor,
      color: Colors.grey[50],
      child: Column(
        children: [
          Expanded(
            flex: 83,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Question : ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          flashcard.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The bottom 17% for the icons
          Expanded(
            flex: 17,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditScreen(index: index, flashcard: flashcard),
                      ),
                    ),
                    child: const Icon(Icons.edit, color: Colors.blue),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Flashcard'),
                        content: const Text('Are you sure?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Provider.of<FlashcardProvider>(context,
                                      listen: false)
                                  .deleteFlashcard(index);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () {
                      final creationDate = flashcard.creationDate;
                      final formattedDate =
                          "${creationDate.day.toString().padLeft(2, '0')}/"
                          "${creationDate.month.toString().padLeft(2, '0')}/"
                          "${creationDate.year}";
                      final formattedTime =
                          "${creationDate.hour.toString().padLeft(2, '0')}:"
                          "${creationDate.minute.toString().padLeft(2, '0')}";

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Created On'),
                          content: Text(
                              'Date: $formattedDate\nTime: $formattedTime IST'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.date_range, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(flashcard, Color shadowColor) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 12,
      shadowColor: shadowColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            // Added to allow scrolling
            child: Column(
              children: [
                Text(
                  flashcard.answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 24, 213, 81),
                  ),
                ),
                const SizedBox(
                    height: 20), // Added space between text and bottom part
              ],
            ),
          ),
        ),
      ),
    );
  }
}
