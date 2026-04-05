import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminFeesScreen extends StatefulWidget {
  const AdminFeesScreen({super.key});

  @override
  State<AdminFeesScreen> createState() => _AdminFeesScreenState();
}

class _AdminFeesScreenState extends State<AdminFeesScreen> {
  late List<FeeRecord> _allFeeRecords;
  String _selectedBranch = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _allFeeRecords = List.from(DummyData.feeRecords);
  }

  @override
  Widget build(BuildContext context) {
    // Filter records by branch and search (name/roll)
    final filteredRecords = _allFeeRecords.where((f) {
      final matchesBranch = _selectedBranch == "All" || f.batchId.toLowerCase().contains(_selectedBranch.toLowerCase());
      final matchesSearch = f.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            f.studentId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesBranch && matchesSearch;
    }).toList();

    // Financial calculations
    final totalCollected = filteredRecords.fold<double>(0, (sum, f) => sum + f.paidAmount);
    final totalPlanned = filteredRecords.fold<double>(0, (sum, f) => sum + f.totalFees);
    final totalPending = totalPlanned - totalCollected;
    final collectionPercent = totalPlanned > 0 ? totalCollected / totalPlanned : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Financial Portal", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // SEARCH & BRANCH SELECTOR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Colors.white,
            child: Column(
              children: [
                CustomTextField(
                  hintText: "Search student name...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _Chip(
                        label: "Global Records",
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
              ],
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
                          Text("Collection Performance", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            "₹${totalCollected.toInt()}",
                            style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 32),
                          ),
                        ],
                      ),
                      CircularPercentIndicator(
                        radius: 35.0,
                        lineWidth: 6.0,
                        percent: collectionPercent.clamp(0.0, 1.0),
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
                      const SizedBox(width: 32),
                      _CompactStat(label: "Total Target", value: "₹${totalPlanned.toInt()}", color: AppColors.gold),
                      const Spacer(),
                      _CompactStat(label: "Records", value: filteredRecords.length.toString(), color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // RECORDS LIST
          Expanded(
            child: filteredRecords.isEmpty
                ? const EmptyState(
                    icon: Icons.payments_outlined,
                    title: "No Invoices Found",
                    subtitle: "Try adjusting filters or search criteria.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return _AdminFeeTile(
                        record: record,
                        onTap: () => _showFeeDetailSheet(record),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFeeDetailSheet(FeeRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final pending = record.totalFees - record.paidAmount;
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.navyBlueSurface,
                        child: Text(record.studentName[0], style: const TextStyle(color: AppColors.navyBlueBase, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record.studentName, style: AppTextStyles.headingSmall),
                            Text("ID: ${record.studentId}", style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.subtle),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SheetStat(label: "Total Fee", value: "₹${record.totalFees.toInt()}"),
                      _SheetStat(label: "Paid", value: "₹${record.paidAmount.toInt()}", color: AppColors.success),
                      _SheetStat(label: "Pending", value: "₹${pending.toInt()}", color: AppColors.error),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 18, color: AppColors.navyBlueBase),
                      const SizedBox(width: 8),
                      Text("Payment Installments", style: AppTextStyles.labelLarge),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: record.installments.length,
                    itemBuilder: (context, idx) {
                      final inst = record.installments[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Installment ${idx + 1}", style: AppTextStyles.labelMedium),
                                Text("${inst.dueDate.day}/${inst.dueDate.month}/${inst.dueDate.year}", style: AppTextStyles.caption),
                              ],
                            ),
                            const Spacer(),
                            Text("₹${inst.amount.toInt()}", style: AppTextStyles.labelLarge),
                            const SizedBox(width: 16),
                            if (inst.isPaid)
                              const Icon(Icons.check_circle_rounded, color: AppColors.success)
                            else
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.navyBlueSurface,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    inst.isPaid = true;
                                    record.paidAmount += inst.amount;
                                  });
                                  setModalState(() {});
                                },
                                child: const Text("Pay Now", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlueBase)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: CustomButton(
                    label: "Close Detail View",
                    width: double.infinity,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 11,
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _SheetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SheetStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.labelLarge.copyWith(color: color, fontSize: 16)),
      ],
    );
  }
}

class _AdminFeeTile extends StatelessWidget {
  final FeeRecord record;
  final VoidCallback onTap;
  const _AdminFeeTile({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pending = record.totalFees - record.paidAmount;
    final isFullyPaid = pending <= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isFullyPaid ? AppColors.success : AppColors.warning).withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFullyPaid ? Icons.verified_rounded : Icons.hourglass_top_rounded,
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
                    isFullyPaid ? "Fully Cleared" : "₹${pending.toInt()} outstanding",
                    style: AppTextStyles.caption.copyWith(
                      color: isFullyPaid ? AppColors.success : AppColors.error,
                      fontWeight: isFullyPaid ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${record.totalFees.toInt()}", style: AppTextStyles.labelMedium),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
