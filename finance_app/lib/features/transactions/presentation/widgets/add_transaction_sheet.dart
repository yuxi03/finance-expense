import 'package:flutter/material.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart';
import 'package:finance_app/features/transactions/data/models/category.dart';
import 'package:uuid/uuid.dart';

class AddTransactionSheet extends StatefulWidget {
  final DateTime date;
  final void Function(TransactionItem) onSave;

  const AddTransactionSheet({super.key, required this.date, required this.onSave});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> with SingleTickerProviderStateMixin {
  bool isIncome = true;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String? selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _save() {
    final raw = amountController.text.trim();
    final amount = double.tryParse(raw.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入大过0的金额'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请选择类别'),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    const uuid = Uuid();
    final item = TransactionItem(
      id: uuid.v4(),
      date: DateTime(widget.date.year, widget.date.month, widget.date.day),
      amount: amount,
      isIncome: isIncome,
      category: selectedCategory!,
      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      time: TimeOfDay.now(),
    );
    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 400),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '添加交易',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Income/Expense Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      '收入',
                      Icons.trending_up,
                      isIncome,
                      const Color(0xFF4CAF50),
                      () => setState(() {
                        isIncome = true;
                        selectedCategory = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _buildToggleButton(
                      '支出',
                      Icons.trending_down,
                      !isIncome,
                      const Color(0xFFEF5350),
                      () => setState(() {
                        isIncome = false;
                        selectedCategory = null;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: '金额',
                prefixIcon: const Icon(Icons.attach_money, size: 28),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Category Grid
            const Text(
              '类别',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: (isIncome ? incomeCategories : expenseCategories).length,
                itemBuilder: (context, index) {
                  final cat = (isIncome ? incomeCategories : expenseCategories)[index];
                  final isSelected = selectedCategory == cat.name;
                  final color = isIncome ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);

                  return InkWell(
                    onTap: () => setState(() => selectedCategory = cat.name),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat.icon,
                            color: isSelected ? color : Colors.grey[600],
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? color : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Note Input
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                prefixIcon: const Icon(Icons.note_outlined),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool isActive,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
