import 'package:flutter/material.dart';

class ReceiptFlow extends StatefulWidget {
  const ReceiptFlow({super.key});

  @override
  State<ReceiptFlow> createState() => _ReceiptFlowState();
}

class _ReceiptFlowState extends State<ReceiptFlow> {
  bool _captured = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: Center(
        child: _captured
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Dummy receipt preview'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Attach to Transaction'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _captured = true;
                  });
                },
                child: const Text('Simulate Capture'),
              ),
      ),
    );
  }
}
