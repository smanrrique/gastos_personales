import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_type.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String iconKey;
  final String colorKey;
  final TransactionType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  Category copyWith({
    String? id,
    String? name,
    String? iconKey,
    String? colorKey,
    TransactionType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconKey,
        colorKey,
        type,
        createdAt,
        updatedAt,
        isDefault,
      ];
}
