import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/bill_model.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class PaymentForm extends StatefulWidget {
  final Bill bill;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const PaymentForm({
    super.key,
    required this.bill,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String _selectedMethod = 'cash';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'Espèces', 'icon': Icons.money},
    {'value': 'credit_card', 'label': 'Carte bancaire', 'icon': Icons.credit_card},
    {'value': 'bank_transfer', 'label': 'Virement', 'icon': Icons.account_balance},
    {'value': 'check', 'label': 'Chèque', 'icon': Icons.receipt_long},
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.bill.totalRemaining.toStringAsFixed(2),
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      if (amount > widget.bill.totalRemaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Le montant ne peut pas dépasser ${widget.bill.totalRemaining.toStringAsFixed(2)} DA',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      widget.onSubmit({
        'bill_id': widget.bill.id,
        'amount_paid': amount,
        'payment_method': _selectedMethod,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'payment_date': _selectedDate.toIso8601String(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bill Info Card
          Card(
            color: isDark
                ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                : theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Facture: ${widget.bill.billNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Montant total:', style: theme.textTheme.bodyMedium),
                      Text(
                        '${widget.bill.totalAmount.toStringAsFixed(2)} DA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Déjà payé:', style: theme.textTheme.bodyMedium),
                      Text(
                        '${widget.bill.totalPaid.toStringAsFixed(2)} DA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Restant:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.bill.totalRemaining.toStringAsFixed(2)} DA',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Payment Method Selection
          Text(
            'Méthode de paiement *',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _paymentMethods.map((method) {
              final isSelected = _selectedMethod == method['value'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(method['icon'], size: 18),
                    const SizedBox(width: 4),
                    Text(method['label']),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedMethod = method['value']),
                selectedColor: theme.colorScheme.primaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Amount
          CustomTextField(
            label: 'Montant à payer (DA) *',
            controller: _amountController,
            prefixIcon: Icons.payments,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (v) {
              if (v!.isEmpty) return 'Requis';
              final amount = double.tryParse(v);
              if (amount == null || amount <= 0) return 'Montant invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Date Selection
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date du paiement *',
                prefixIcon: const Icon(Icons.calendar_today),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Notes
          CustomTextField(
            label: 'Notes (optionnel)',
            controller: _notesController,
            prefixIcon: Icons.note,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          
          // Submit Button
          CustomButton(
            text: 'Enregistrer le paiement',
            icon: Icons.check,
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}