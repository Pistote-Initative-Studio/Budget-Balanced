import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/utils/currency.dart';
import 'package:intl/intl.dart';
import 'add_transaction_sheet.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: transactions.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No transactions yet'));
          }
          final dateFormat = DateFormat('yyyy-MM-dd');
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final tx = items[index];
              return ListTile(
                title: Text(tx.merchant),
                subtitle: Text(dateFormat.format(tx.dateUtc.toLocal())),
                trailing: Text(formatCents(tx.amountCents)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTransactionSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
