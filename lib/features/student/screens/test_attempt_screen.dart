import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
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
  bool _isSubmitting = false;

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _isSubmitting = value);
  }


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
    return AppColors.success;
  }

  Future<void> _submitTest() async {
    _timer?.cancel();
    _setSubmitting(true);
    
    // Simulate submission delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) {
      _setSubmitting(false);
      return;
    }

    // Calculation for results
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

    _setSubmitting(false);
    context.pushReplacementNamed(AppRoutes.testResultName, pathParameters: {'resultId': result.id}, extra: result);
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
              SizedBox(height: AppSpacing.md),
              Text(
                "Warning: You have un-answered questions!",
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
              ),
            ],
            SizedBox(height: AppSpacing.md),
            const Text("Are you sure you want to finish the test?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () {
              Navigator.pop(context);
              _submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            child: _isSubmitting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("SUBMIT"),
          ),

        ],
      ),
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl))),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
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
            SizedBox(height: AppSpacing.lg),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
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
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isCurrent ? AppColors.navyBlueBase : AppColors.navyBlueSurface,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (index + 1).toString(),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isCurrent ? Colors.white : (isAnswered ? AppColors.success : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
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
        context.goNamed(AppRoutes.roleSelectionName);
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
            style: AppTextStyles.labelLarge.copyWith(overflow: TextOverflow.ellipsis),
          ),
          actions: [
            Container(
              margin: EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: timerColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: timerColor.withAlpha((0.3 * 255).round())),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: timerColor),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatTime(_secondsLeft),
                    style: AppTextStyles.labelMedium.copyWith(color: timerColor, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressHeader(totalCount, answeredCount),

            if (_isSubmitting)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.lg),
                      Text("Submitting your answers...", style: AppTextStyles.labelLarge),
                    ],
                  ),
                ),
              )
            else
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
                            if (mounted && !_isSubmitting) setState(() => _answers[question.id] = optIdx);
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

            if (!_isSubmitting) _buildNavigationFooter(totalCount),

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

  Widget _buildProgressHeader(int totalCount, int answeredCount) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? (_currentIndex + 1) / totalCount : 0,
              backgroundColor: AppColors.navyBlueSurface,
              color: AppColors.navyBlueBase,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter(int totalCount) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha((0.05 * 255).round()),
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
          if (_currentIndex > 0) const SizedBox(width: AppSpacing.lg),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.navyBlueSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              question.subject,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "QN. ${question.questionText}",
            style: AppTextStyles.headingSmall.copyWith(height: 1.5, fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ...List.generate(question.options.length, (index) {
            final isSelected = selectedOption == index;
            final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

            return _OptionTile(
              label: optionLabel,
              optionText: question.options[index],
              isSelected: isSelected,
              onTap: () => onOptionSelected(index),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyBlueSurface : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? Colors.white : AppColors.navyBlueBase,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                optionText,
                style: AppTextStyles.bodyMedium.copyWith(
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
        SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
