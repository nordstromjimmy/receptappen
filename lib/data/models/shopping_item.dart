import 'package:uuid/uuid.dart';

class ShoppingItem {
  final String id;
  final String name;
  final bool isChecked;
  final String? sourceRecipeId;
  final String? sourceRecipeName;

  ShoppingItem({
    String? id,
    required this.name,
    this.isChecked = false,
    this.sourceRecipeId,
    this.sourceRecipeName,
  }) : id = id ?? const Uuid().v4();

  ShoppingItem copyWith({
    String? name,
    bool? isChecked,
    String? sourceRecipeId,
    String? sourceRecipeName,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      sourceRecipeId: sourceRecipeId ?? this.sourceRecipeId,
      sourceRecipeName: sourceRecipeName ?? this.sourceRecipeName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isChecked': isChecked,
    'sourceRecipeId': sourceRecipeId,
    'sourceRecipeName': sourceRecipeName,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    isChecked: json['isChecked'] as bool? ?? false,
    sourceRecipeId: json['sourceRecipeId'] as String?,
    sourceRecipeName: json['sourceRecipeName'] as String?,
  );
}
