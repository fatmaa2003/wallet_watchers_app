class Category {
  final String id;
  final String categoryName;

  Category({
    required this.id,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
    };
  }

  @override
  String toString() => categoryName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && 
           other.id == id && 
           other.categoryName.toLowerCase() == categoryName.toLowerCase();
  }

  @override
  int get hashCode => id.hashCode ^ categoryName.toLowerCase().hashCode;
} 