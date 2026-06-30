import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sales_tracker/database/database_helper.dart';
import 'package:sales_tracker/models/sale.dart';
import 'package:sales_tracker/widgets/add_sale_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime _selectedDate = DateTime.now();
  List<Sale> _selectedDaySales = [];
  Set<DateTime> _daysWithSales = {};

  @override
  void initState() {
    super.initState();
    _loadDaysWithSales();
    _loadSalesForDate(_selectedDate);
  }

  void _loadDaysWithSales() async {
    List<Sale> allSales = await _dbHelper.getAllSales();
    Set<DateTime> days = {};
    for (var sale in allSales) {
      days.add(DateTime(sale.date.year, sale.date.month, sale.date.day));
    }
    setState(() {
      _daysWithSales = days;
    });
  }

  void _loadSalesForDate(DateTime date) async {
    List<Sale> sales = await _dbHelper.getSalesByDate(date);
    setState(() {
      _selectedDaySales = sales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              _loadSalesForDate(selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                bool hasData = _daysWithSales.any((d) => isSameDay(d, day));
                if (hasData) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${day.day}')),
                  );
                }
                return null;
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales for ${_selectedDate.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSalesForDay(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSaleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSalesForDay() {
    if (_selectedDaySales.isEmpty) {
      return const Center(
        child: Text('No sales for this day'),
      );
    }

    Map<String, List<Sale>> groupedByItem = {};
    for (var sale in _selectedDaySales) {
      groupedByItem.putIfAbsent(sale.itemName, () => []);
      groupedByItem[sale.itemName]!.add(sale);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedByItem.entries.map((entry) {
        double totalRevenue =
            entry.value.fold(0, (sum, sale) => sum + sale.totalRevenue);
        int totalUnits =
            entry.value.fold(0, (sum, sale) => sum + sale.units);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Total Units: $totalUnits'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      Sale sale = entry.value[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${sale.units} units × \$${sale.value.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () =>
                                      _showEditSaleDialog(sale),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  onPressed: () => _deleteSale(sale.id!),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddSaleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSaleDialog(
        onSaleAdded: () {
          _loadDaysWithSales();
          _loadSalesForDate(_selectedDate);
        },
      ),
    );
  }

  void _showEditSaleDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AddSaleDialog(
        saleToEdit: sale,
        onSaleAdded: () {
          _loadDaysWithSales();
          _loadSalesForDate(_selectedDate);
        },
      ),
    );
  }

  void _deleteSale(int id) async {
    await _dbHelper.deleteSale(id);
    _loadDaysWithSales();
    _loadSalesForDate(_selectedDate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale deleted')),
    );
  }
}