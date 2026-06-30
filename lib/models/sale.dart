class Sale {
  int? id;
  String itemName;
  int units;
  double value;
  DateTime date;

  Sale({
    this.id,
    required this.itemName,
    required this.units,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'units': units,
      'value': value,
      'date': date.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      itemName: map['itemName'],
      units: map['units'],
      value: map['value'],
      date: DateTime.parse(map['date']),
    );
  }

  double get totalRevenue => units * value;
}