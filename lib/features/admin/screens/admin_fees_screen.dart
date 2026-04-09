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
  bool _isSubmitting = false;

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _isSubmitting = value);
  }



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
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            color: Colors.white,
            child: Column(
              children: [
                CustomTextField(
                  hintText: "Search student name...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                SizedBox(height: AppSpacing.md),
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
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xl),
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
                          Text("Collection Performance", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha((0.7 * 255).round()))),
                          SizedBox(height: AppSpacing.xs),
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
                  SizedBox(height: AppSpacing.xl),
                  Divider(color: Colors.white.withAlpha((0.24 * 255).round()), height: 1),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _CompactStat(label: "Pending", value: "₹${totalPending.toInt()}", color: AppColors.error),
                      SizedBox(width: AppSpacing.xxl * 1.5),
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
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return FeeCard(
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

  void _showFeeDetailSheet(FeeRecord initialRecord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final record = _allFeeRecords.firstWhere((r) => r.id == initialRecord.id, orElse: () => initialRecord);
          final pending = record.totalFees - record.paidAmount;
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.xs)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.navyBlueSurface,
                        child: Text(record.studentName[0], style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyBlueBase)),
                      ),
                      SizedBox(width: AppSpacing.lg),
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
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppShadows.subtle),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SheetStat(label: "Total Fee", value: "₹${record.totalFees.toInt()}"),
                      _SheetStat(label: "Paid", value: "₹${record.paidAmount.toInt()}", color: AppColors.success),
                      _SheetStat(label: "Pending", value: "₹${pending.toInt()}", color: AppColors.error),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 18, color: AppColors.navyBlueBase),
                      SizedBox(width: AppSpacing.sm),
                      Text("Payment Installments", style: AppTextStyles.labelLarge),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: record.installments.length,
                    itemBuilder: (context, idx) {
                      final inst = record.installments[idx];
                      return Container(
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.divider)),
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
                            SizedBox(width: AppSpacing.lg),
                            if (inst.status == FeeStatus.paid)
                              const Icon(Icons.check_circle_rounded, color: AppColors.success)
                            else
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.navyBlueSurface,
                                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                ),
                                onPressed: _isSubmitting ? null : () async {
                                  _setSubmitting(true);
                                  
                                  // Simulate payment processing
                                  await Future.delayed(const Duration(milliseconds: 1200));
                                  
                                  if (!mounted) {
                                    _setSubmitting(false);
                                    return;
                                  }

                                  setState(() {
                                    final listIndex = record.installments.indexWhere((i) => i.id == inst.id);
                                    if (listIndex != -1) {
                                      final newInst = inst.copyWith(status: FeeStatus.paid, paidDate: DateTime.now());
                                      final newInstallments = List<FeeInstallment>.from(record.installments);
                                      newInstallments[listIndex] = newInst;
                                      
                                      final newRecord = record.copyWith(
                                        paidAmount: record.paidAmount + inst.amount,
                                        installments: newInstallments,
                                      );
                                      
                                      final recordIndex = _allFeeRecords.indexWhere((r) => r.id == record.id);
                                      if (recordIndex != -1) {
                                        _allFeeRecords[recordIndex] = newRecord;
                                      }
                                    }
                                  });
                                  
                                  _setSubmitting(false);
                                  setModalState(() {});
                                  if (!context.mounted) return;
                                  AppSnackBar.showSuccess(context, "Payment of ₹${inst.amount.toInt()} recorded");
                                },
                                child: _isSubmitting 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyBlueBase))
                                  : Text("Pay Now", style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
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
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
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

