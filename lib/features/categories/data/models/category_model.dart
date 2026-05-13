import 'package:hive_ce/hive.dart';

import '../../../transactions/domain/entities/transaction_type.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  CategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.typeIndex,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconKey;

  @HiveField(3)
  String colorKey;

  @HiveField(4)
  int typeIndex;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isDefault;

  TransactionType get type => TransactionType.values[typeIndex];

  Category toEntity() => Category(
        id: id,
        name: name,
        iconKey: iconKey,
        colorKey: colorKey,
        type: type,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDefault: isDefault,
      );

  factory CategoryModel.fromEntity(Category c) => CategoryModel(
        id: c.id,
        name: c.name,
        iconKey: c.iconKey,
        colorKey: c.colorKey,
        typeIndex: c.type.index,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        isDefault: c.isDefault,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorKey': colorKey,
        'typeIndex': typeIndex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDefault': isDefault,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        iconKey: json['iconKey'] as String,
        colorKey: json['colorKey'] as String,
        typeIndex: json['typeIndex'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isDefault: json['isDefault'] as bool? ?? false,
      );
}
