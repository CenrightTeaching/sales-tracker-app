import 'package:flutter/material.dart';
import 'package:sales_tracker/database/database_helper.dart';
import 'package:sales_tracker/models/sale.dart';
import 'package:sales_tracker/models/item.dart';

class AddSaleDialog extends StatefulWidget {
  final VoidCallback onSaleAdded;
  final Sale? saleToEdit;

  const AddSaleDialog({
    Key? key,
    required this.onSaleAdded,
    this.saleToEdit,
  }) : super(key: key);

  @override
  State<AddSaleDialog> createState() => _AddSaleDialogState();
}

class _AddSaleDialogState extends State<AddSaleDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TextEditingController _unitsController;
  late TextEditingController _valueController;
  String? _selectedItem;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _unitsController =
        TextEditingController(text: widget.saleToEdit?.units.toString() ?? '');
    _valueController =
        TextEditingController(text: widget.saleToEdit?.value.toString() ?? '');
    _selectedItem = widget.saleToEdit?.itemName;
    _loadItems();
  }

  void _loadItems() async {
    List<Item> items = await _dbHelper.getAllItems();
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.saleToEdit == null ? 'Add Sale' : 'Edit Sale'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedItem,
              hint: const Text('Select Item'),
              items: _items.map((item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Text(item.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Units',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Value per Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_selectedItem != null &&
                _unitsController.text.isNotEmpty &&
                _valueController.text.isNotEmpty) {
              try {
                int units = int.parse(_unitsController.text);
                double value = double.parse(_valueController.text);

                Sale sale = Sale(
                  id: widget.saleToEdit?.id,
                  itemName: _selectedItem!,
                  units: units,
                  value: value,
                  date: widget.saleToEdit?.date ?? DateTime.now(),
                );

                if (widget.saleToEdit == null) {
                  await _dbHelper.addSale(sale);
                } else {
                  await _dbHelper.updateSale(sale);
                }

                widget.onSaleAdded();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}