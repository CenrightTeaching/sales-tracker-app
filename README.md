# Sales Tracker App

A Flutter application to track daily sales with items, units, and values. Features include a calendar view, local data storage, CSV export/import, and daily revenue summaries.

## Features

- 📅 **Calendar View**: View all sales organized by date with visual indicators for days with sales
- ➕ **Add Sales**: Record sales with item name, units sold, and value per unit
- 🛍️ **Item Management**: Create and manage a list of predefined items to track
- 💰 **Revenue Tracking**: Automatic calculation of total revenue by item and date
- 📊 **Daily Summary**: Quick overview of today's sales on the home screen
- 💾 **Local Storage**: All data stored locally on your device using SQLite
- 📥 **CSV Export**: Export your sales data for backup or analysis
- 📤 **CSV Import**: Import previously exported data or data from other sources
- ✏️ **Edit/Delete**: Modify or remove sales entries as needed

## Installation

1. Ensure you have Flutter installed: [Flutter Documentation](https://flutter.dev/docs/get-started)

2. Clone this repository:
```bash
git clone https://github.com/CenrightTeaching/sales-tracker-app.git
cd sales-tracker-app
```

3. Get dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Building APK (Android)

To build an APK for Android:

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-app/release/app-release.apk`

## Building for iOS

To build for iOS (requires macOS):

```bash
flutter build ios --release
```

Then open the Xcode project and archive for submission to the App Store.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── sale.dart            # Sale data model
│   └── item.dart            # Item data model
├── database/
│   └── database_helper.dart  # SQLite database operations
├── screens/
│   ├── home_screen.dart      # Home/dashboard screen
│   ├── calendar_screen.dart  # Calendar with daily view
│   ├── items_screen.dart     # Item management
│   └── backup_screen.dart    # Backup/restore operations
├── services/
│   └── backup_service.dart   # CSV export/import logic
└── widgets/
    └── add_sale_dialog.dart  # Add/edit sale dialog
```

## Usage

### Adding a Sale
1. Tap the "Add Sale" button on the home screen or calendar
2. Select an item from the dropdown
3. Enter the number of units sold
4. Enter the value per unit
5. Tap "Save"

### Managing Items
1. Navigate to the "Items" section from the home screen
2. Tap the "+" button to add a new item
3. Enter the item name and confirm
4. To delete an item, tap the trash icon

### Viewing Sales by Date
1. Navigate to the "Calendar" section
2. Days with sales are highlighted in light blue
3. Tap any date to view sales for that day
4. Tap the pencil icon to edit a sale
5. Tap the trash icon to delete a sale

### Backing Up Data
1. Navigate to the "Backup" section
2. Tap "Export to CSV" to save all your data
3. The file will be saved to your Downloads folder

### Restoring Data
1. Navigate to the "Backup" section
2. Tap "Import from CSV"
3. Select a CSV file from your device
4. Your data will be imported and merged with existing data

## CSV Format

When exporting or importing data, the CSV file should have the following format:

```
itemName,units,value,date
Green,5,10.50,2024-01-15T08:30:00.000Z
Blue,3,15.00,2024-01-15T09:00:00.000Z
White,10,5.25,2024-01-16T10:15:00.000Z
```

## Dependencies

- **sqflite**: Local SQLite database
- **table_calendar**: Calendar widget
- **csv**: CSV parsing and generation
- **file_picker**: File selection for imports
- **fl_chart**: Data visualization
- **intl**: Internationalization
- **path**: File path utilities
- **path_provider**: Access to app directories

## Platform Support

- ✅ Android
- ✅ iOS

## Future Enhancements

- Charts and graphs for sales trends
- Monthly/yearly reports
- Multiple user support
- Cloud sync option
- Custom item colors and icons
- Recurring items

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or suggestions, please create an issue on GitHub.