import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminFeesScreen extends StatefulWidget {
  const AdminFeesScreen({super.key});

  @override
  State<AdminFeesScreen> createState() => _AdminFeesScreenState();
}

class _AdminFeesScreenState extends State<AdminFeesScreen> {
  String _selectedBranch = "All";

  @override
  Widget build(BuildContext context) {
    // Filter records by branch
    final filteredRecords = DummyData.feeRecords.where((f) {
      final matchesBranch = _selectedBranch == "All" || f.batchId.contains(_selectedBranch.toLowerCase()); // Dummy logic
      return matchesBranch;
    }).toList();

    // Financial calculations
    final totalCollected = filteredRecords.fold<double>(0, (sum, f) => sum + f.paidAmount);
    final totalPending = filteredRecords.fold<double>(0, (sum, f) => sum + (f.totalFees - f.paidAmount));
    final collectionPercent = (totalCollected + totalPending) > 0 
        ? totalCollected / (totalCollected + totalPending)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Financial Dashboard", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // BRANCH SELECTOR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _Chip(
                    label: "All Branches",
                    isSelected: _selectedBranch == "All",
                    onTap: () => setState(() => _selectedBranch = "All"),
                  ),
                  ...AppConstants.branches.map((branch) => _Chip(
                        label: branch,
                        isSelected: _selectedBranch == branch,
                        onTap: () => setState(() => _selectedBranch = branch),
                      )),
                ],
              ),
            ),
          ),

          // FINANCIAL OVERVIEW CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyBlueDark, AppColors.navyBlueBase],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.cardRadius,
                boxShadow: AppShadows.elevated,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Revenue", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                          Text(
                            "₹${totalCollected.toInt()}",
                            style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 32),
                          ),
                        ],
                      ),
                      CircularPercentIndicator(
                        radius: 35.0,
                        lineWidth: 6.0,
                        percent: collectionPercent,
                        center: Text(
                          "${(collectionPercent * 100).toInt()}%",
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        progressColor: AppColors.gold,
                        backgroundColor: Colors.white12,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _CompactStat(label: "Pending", value: "₹${totalPending.toInt()}", color: AppColors.error),
                      const SizedBox(width: 24),
                      _CompactStat(label: "Invoices", value: filteredRecords.length.toString(), color: AppColors.gold),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // PENDING RECORDS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return _AdminFeeTile(record: record);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _AdminFeeTile extends StatelessWidget {
  final FeeRecord record;
  const _AdminFeeTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final pending = record.totalFees - record.paidAmount;
    final isFullyPaid = pending <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isFullyPaid ? AppColors.success : AppColors.warning).withAlpha((0.15 * 255).round()),
            child: Icon(
              isFullyPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isFullyPaid ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.studentName, style: AppTextStyles.labelLarge),
                Text(
                  isFullyPaid ? "Fully Paid" : "₹${pending.toInt()} outstanding",
                  style: AppTextStyles.caption.copyWith(
                    color: isFullyPaid ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${record.totalFees.toInt()}", style: AppTextStyles.labelMedium),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
