enum MakingChargeType { fixed, percentage }

class CartItem {
  final String sku;
  final String name;
  final double weight;
  final double metalRate;
  final MakingChargeType makingType;
  final double makingValue;

  CartItem({
    required this.sku,
    required this.name,
    required this.weight,
    required this.metalRate,
    required this.makingType,
    required this.makingValue,
  });

  double get metalValue => weight * metalRate;

  double get makingCharge {
    if (makingType == MakingChargeType.fixed) {
      return makingValue;
    } else {
      return metalValue * (makingValue / 100);
    }
  }

  double get total => metalValue + makingCharge;
}

class BillingTab {
  final String id;
  String customerName;
  String customerPhone;
  String customerAddress;
  double defaultMetalRate;
  List<CartItem> cartItems;

  BillingTab({
    required this.id,
    this.customerName = "Walk-in Customer",
    this.customerPhone = "",
    this.customerAddress = "",
    this.defaultMetalRate = 5800.0,
    required this.cartItems,
  });

  double get subTotal => cartItems.fold(0, (sum, item) => sum + item.total);
  double get totalMaking => cartItems.fold(0, (sum, item) => sum + item.makingCharge);
  double get totalMetal => cartItems.fold(0, (sum, item) => sum + item.metalValue);
  double get tax => subTotal * 0.03; // Standard 3% GST for Jewellery
  double get grandTotal => subTotal + tax;
}
