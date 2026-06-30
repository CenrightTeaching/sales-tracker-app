import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sales_tracker/database/database_helper.dart';
import 'package:sales_tracker/models/sale.dart';
import 'package:sales_tracker/models/item.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> exportToCSV() async {
    try {
      List<Sale> sales = await _dbHelper.getAllSales();
      List<Item> items = await _dbHelper.getAllItems();

      // Create CSV data
      List<List<dynamic>> csvData = [];
      csvData.add(['itemName', 'units', 'value', 'date']);

      for (var sale in sales) {
        csvData.add([
          sale.itemName,
          sale.units,
          sale.value,
          sale.date.toIso8601String(),
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        String fileName =
            'sales_backup_${DateTime.now().toIso8601String().split('T')[0]}.csv';
        File file = File('${downloadsDir.path}/$fileName');
        await file.writeAsString(csv);
      }
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> importFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String csvContent = await file.readAsString();

        List<List<dynamic>> csvData =
            const CsvToListConverter().convert(csvContent);

        // Skip header row
        for (int i = 1; i < csvData.length; i++) {
          try {
            String itemName = csvData[i][0].toString();
            int units = int.parse(csvData[i][1].toString());
            double value = double.parse(csvData[i][2].toString());
            DateTime date = DateTime.parse(csvData[i][3].toString());

            Sale sale = Sale(
              itemName: itemName,
              units: units,
              value: value,
              date: date,
            );

            await _dbHelper.addSale(sale);
          } catch (e) {
            // Skip invalid rows
            continue;
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}