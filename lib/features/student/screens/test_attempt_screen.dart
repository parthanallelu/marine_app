import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../core/utils/id_generator.dart';

class TestAttemptScreen extends StatefulWidget {
  final String testId;
  const TestAttemptScreen({super.key, required this.testId});

  @override
  State<TestAttemptScreen> createState() => _TestAttemptScreenState();
}

class _TestAttemptScreenState extends State<TestAttemptScreen> {
  late TestModel _test;
  final Map<String, int> _answers = {};
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    // TODO: Replace DummyData with Firestore query:
    // _test = await testRepository.getTestById(widget.testId);
    _test = DummyData.tests.firstWhere((t) => t.id == widget.testId);
    _secondsLeft = _test.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_secondsLeft <= 0) {
        timer.cancel();
        _submitTest();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_secondsLeft < 60) return AppColors.error;
    if (_secondsLeft < 300) return AppColors.warning;
    return const Color(0xFF2E7D32);
  }

  void _submitTest() {
    _timer?.cancel();
    
    // TODO: Replace with backend calculation for anti-cheat
    int correctCount = 0;
    for (var q in _test.questions) {
      if (_answers[q.id] == q.correctOptionIndex) {
        correctCount++;
      }
    }

    final scorePerQuestion = _test.questions.isEmpty ? 0.0 : _test.totalMarks / _test.questions.length;
    final totalScore = correctCount * scorePerQuestion;
    final student = context.read<AuthProvider>().currentUser as StudentModel;

    final result = TestResult(
      id: IdGenerator.generateId(),
      testId: _test.id,
      testTitle: _test.title,
      studentId: student.id,
      answers: _answers,
      score: totalScore,
      totalMarks: _test.totalMarks.toDouble(),
      timeTakenSeconds: (_test.durationMinutes * 60 - _secondsLeft),
      submittedAt: DateTime.now().toUtc(),
      isPassed: (totalScore >= _test.passingMarks),
    );

    // TODO: Save result to Firestore:
    // await studentRepository.saveTestResult(result);

    if (mounted) {
      context.pushReplacementNamed('test_result', pathParameters: {'resultId': result.id}, extra: result);
    }
  }

  Future<void> _showSubmitDialog() async {
    final answeredCount = _answers.length;
    final totalCount = _test.questions.length;
    final isComplete = answeredCount == totalCount;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submit Test?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Answered: $answeredCount / $totalCount"),
            if (!isComplete) ...[
              const SizedBox(height: 12),
              const Text(
                "Warning: You have un-answered questions!",
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 12),
            const Text("Are you sure you want to finish the test?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            child: const Text("SUBMIT"),
          ),
        ],
      ),
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Jump to Question", style: AppTextStyles.labelLarge),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _test.questions.length,
                itemBuilder: (context, index) {
                  final qId = _test.questions[index].id;
                  final isCurrent = index == _currentIndex;
                  final isAnswered = _answers.containsKey(qId);
                  
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent 
                          ? AppColors.navyBlueBase 
                          : (isAnswered ? AppColors.successSurface : AppColors.background),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent ? AppColors.navyBlueBase : AppColors.navyBlueSurface,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: isCurrent ? Colors.white : (isAnswered ? AppColors.success : AppColors.textPrimary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: AppColors.navyBlueBase, label: "Current"),
                _LegendItem(color: AppColors.successSurface, label: "Answered"),
                _LegendItem(color: AppColors.background, label: "Not Visited"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access Control Safety
    final auth = context.watch<AuthProvider>();
    if (!auth.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed('role_selection');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final timerColor = _getTimerColor();
    final answeredCount = _answers.length;
    final totalCount = _test.questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showSubmitDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _showSubmitDialog,
            icon: const Icon(Icons.close),
          ),
          title: Text(
            _test.title,
            style: const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: timerColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: timerColor.withAlpha((0.3 * 255).round())),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: timerColor),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_secondsLeft),
                    style: TextStyle(color: timerColor, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // PROGRESS SECTION
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${_currentIndex + 1} of $totalCount",
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        "$answeredCount answered",
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? (_currentIndex + 1) / totalCount : 0,
                      backgroundColor: Colors.grey[300],
                      color: AppColors.navyBlueBase,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),

            // PAGE VIEW
            Expanded(
              child: totalCount > 0 
                ? PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) {
                      if (mounted) setState(() => _currentIndex = idx);
                    },
                    itemCount: totalCount,
                    itemBuilder: (context, index) {
                      final question = _test.questions[index];
                      return _QuestionPage(
                        question: question,
                        selectedOption: _answers[question.id],
                        onOptionSelected: (optIdx) {
                          if (mounted) setState(() => _answers[question.id] = optIdx);
                        },
                      );
                    },
                  )
                : const EmptyState(
                    icon: Icons.quiz_rounded,
                    title: "No Questions",
                    subtitle: "This test does not contain any questions.",
                  ),
            ),

            // NAVIGATION ROW
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: CustomButton(
                        label: "Previous",
                        isOutlined: true,
                        onPressed: () {
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: (totalCount > 0 && _currentIndex == totalCount - 1)
                        ? CustomButton(
                            label: "Submit Test",
                            color: AppColors.success,
                            onPressed: _showSubmitDialog,
                          )
                        : CustomButton(
                            label: "Next",
                            onPressed: () {
                              if (totalCount > 0) {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: totalCount > 0 ? FloatingActionButton(
          onPressed: _showQuestionNavigator,
          backgroundColor: AppColors.navyBlueBase,
          child: const Icon(Icons.grid_view_rounded, color: Colors.white),
        ) : null,
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final QuestionModel question;
  final int? selectedOption;
  final Function(int) onOptionSelected;

  const _QuestionPage({
    required this.question,
    this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navyBlueSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.subject,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "QN. ${question.questionText}",
            style: AppTextStyles.headingSmall.copyWith(height: 1.5, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            final isSelected = selectedOption == index;
            final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

            return GestureDetector(
                onTap: () => onOptionSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navyBlueSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.navyBlueBase : AppColors.navyBlueSurface,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navyBlueBase : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navyBlueBase),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        optionLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.navyBlueBase,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.navyBlueBase : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: AppColors.navyBlueBase),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
