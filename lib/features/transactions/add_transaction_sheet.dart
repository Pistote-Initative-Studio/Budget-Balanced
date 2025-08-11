import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/providers.dart';
import '../../core/utils/currency.dart';
import '../../data/models/transaction.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();

  String _category = 'General';
  String _paymentType = 'Card';
  DateTime _date = DateTime.now().toUtc();

  final _uuid = const Uuid();
  final _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('amount'),
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => parseCurrency(value ?? '') == null ? 'Enter a valid amount' : null,
              ),
              TextFormField(
                key: const Key('merchant'),
                controller: _merchantController,
                decoration: const InputDecoration(labelText: 'Merchant'),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Food', child: Text('Food')),
                  DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                  DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'General'),
              ),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: const InputDecoration(labelText: 'Payment Type'),
                items: const [
                  DropdownMenuItem(value: 'Card', child: Text('Card')),
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'Online', child: Text('Online')),
                ],
                onChanged: (v) => setState(() => _paymentType = v ?? 'Card'),
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: _dateFormat.format(_date.toLocal()),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date.toLocal(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _date = picked.toUtc());
                  }
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final amount = parseCurrency(_amountController.text)!;
                    final tx = BBTransaction(
                      id: _uuid.v4(),
                      amountCents: amount,
                      dateUtc: _date,
                      merchant: _merchantController.text,
                      category: _category,
                      paymentType: _paymentType,
                      note: _noteController.text,
                    );
                    await ref.read(transactionRepoProvider).add(tx);
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
