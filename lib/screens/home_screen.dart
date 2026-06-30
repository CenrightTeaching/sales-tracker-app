import 'package:flutter/material.dart';
import 'package:sales_tracker/database/database_helper.dart';
import 'package:sales_tracker/models/sale.dart';
import 'package:sales_tracker/screens/calendar_screen.dart';
import 'package:sales_tracker/screens/items_screen.dart';
import 'package:sales_tracker/screens/backup_screen.dart';
import 'package:sales_tracker/widgets/add_sale_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Sale> _todaySales = [];

  @override
  void initState() {
    super.initState();
    _loadTodaySales();
  }

  void _loadTodaySales() async {
    List<Sale> sales = await _dbHelper.getSalesByDate(DateTime.now());
    setState(() {
      _todaySales = sales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Tracker'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTodaySales();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Summary Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTodaysSummary(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildActionButton(
                      icon: Icons.add_circle,
                      label: 'Add Sale',
                      color: Colors.blue,
                      onTap: () => _showAddSaleDialog(),
                    ),
                    _buildActionButton(
                      icon: Icons.calendar_month,
                      label: 'Calendar',
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      ),
                    ),
                    _buildActionButton(
                      icon: Icons.shopping_bag,
                      label: 'Items',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ItemsScreen()),
                      ),
                    ),
                    _buildActionButton(
                      icon: Icons.backup,
                      label: 'Backup',
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BackupScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysSummary() {
    if (_todaySales.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No sales recorded today'),
      );
    }

    Map<String, double> totals = {};
    for (var sale in _todaySales) {
      totals[sale.itemName] =
          (totals[sale.itemName] ?? 0) + sale.totalRevenue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: totals.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 14)),
              Text(
                '\$${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSaleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSaleDialog(
        onSaleAdded: _loadTodaySales,
      ),
    );
  }
}