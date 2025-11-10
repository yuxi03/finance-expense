import 'package:flutter/material.dart';
import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/models/category.dart';
import 'package:uuid/uuid.dart';

class AddTransactionSheet extends StatefulWidget {
  final DateTime date;
  final void Function(TransactionItem) onSave;

  const AddTransactionSheet({super.key, required this.date, required this.onSave});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool isIncome = true;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String? selectedCategory;

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _save() {
    final raw = amountController.text.trim();
    final amount = double.tryParse(raw.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入大过0的金额')),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择类别')),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '添加',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('收入'), icon: Icon(Icons.arrow_downward)),
              ButtonSegment(value: false, label: Text('支出'), icon: Icon(Icons.arrow_upward)),
            ],
            selected: {isIncome},
            onSelectionChanged: (s) => setState(() {
              isIncome = s.first;
              selectedCategory = null; // Reset category when switching type
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '金额',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(isIncome),
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              labelText: '类别',
              border: OutlineInputBorder(),
            ),
            items: (isIncome ? incomeCategories : expenseCategories)
                .map((cat) => DropdownMenuItem(
                      value: cat.name,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedCategory = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: '注意事项（没有可以不写）',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('保存'),
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

