import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/utils/currency.dart';
import '../../data/models/transaction.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _merchantController,
            decoration: const InputDecoration(labelText: 'Merchant'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final amount = parseCurrency(_amountController.text);
              final tx = Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                amountCents: amount,
                dateUtc: DateTime.now().toUtc(),
                merchant: _merchantController.text,
              );
              ref.read(transactionRepoProvider).add(tx);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
