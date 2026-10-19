/// Food item model for THE NEW HOTPOT restaurant menu management system.
class Food {
  final int id;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final String description;
  final bool available;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFeatured;

  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.available = true,
    this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final int parsedPrice;
    if (rawPrice is num) {
      parsedPrice = rawPrice.round();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice)?.round() ?? 0;
    } else {
      parsedPrice = 0;
    }

    final rawId = json['id'];
    final int parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is num) {
      parsedId = rawId.toInt();
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else {
      parsedId = 0;
    }

    DateTime? parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return Food(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: parsedPrice,
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      description:
          json['description']?.toString() ?? json['note']?.toString() ?? '',
      available:
          json['available'] == true ||
          json['available'] == 1 ||
          json['available'] == 'true',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      isFeatured: json['is_featured'] == true || json['isFeatured'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'available': available,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'is_featured': isFeatured,
    };
  }

  Food copyWith({
    int? id,
    String? name,
    String? category,
    int? price,
    String? imageUrl,
    String? description,
    bool? available,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
