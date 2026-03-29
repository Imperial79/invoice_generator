class InventoryItem {
  final String sku;
  final String name;
  final String category;
  final String purity;
  double weight;
  int stock;

  InventoryItem({
    required this.sku,
    required this.name,
    required this.category,
    required this.purity,
    required this.weight,
    required this.stock,
  });

  String get status {
    if (stock > 5) return "In Stock";
    if (stock > 0) return "Low Stock";
    return "Out of Stock";
  }

  void sell(double sellWeight) {
    if (stock > 0) stock--;
    // Weight adjustment can be complex, for now we subtract the sold weight from total stock weight if tracked
    // but usually in jewellery, one item has one weight.
    // If it's a bulk item, weight decreases. If it's a unique item, stock becomes 0.
    // Let's assume unique items for now for simplicity of Stock logic.
  }

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'category': category,
      'purity': purity,
      'weight': weight,
      'stock': stock,
    };
  }
}
