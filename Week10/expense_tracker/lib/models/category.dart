import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum Category {
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  other,
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 0;

  @override
  Category read(BinaryReader reader) {
    final value = reader.readByte();
    return Category.values[value];
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeByte(obj.index);
  }
}

extension CategoryX on Category {
  String get label {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.transport:
        return 'Transport';
      case Category.shopping:
        return 'Shopping';
      case Category.bills:
        return 'Bills';
      case Category.entertainment:
        return 'Entertainment';
      case Category.health:
        return 'Health';
      case Category.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_bus;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.bills:
        return Icons.receipt_long;
      case Category.entertainment:
        return Icons.movie;
      case Category.health:
        return Icons.favorite;
      case Category.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case Category.food:
        return Colors.orange;
      case Category.transport:
        return Colors.blue;
      case Category.shopping:
        return Colors.purple;
      case Category.bills:
        return Colors.teal;
      case Category.entertainment:
        return Colors.indigo;
      case Category.health:
        return Colors.redAccent;
      case Category.other:
        return Colors.grey;
    }
  }
}
