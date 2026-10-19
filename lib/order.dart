class Order {
  final String name;
  final String phone;
  final String address;
  final int total;
  final String status;
  final List<String> items;
  final String id;
  Order({
    required this.name,
    required this.phone,
    required this.address,
    required this.total,
    required this.status,
    required this.items,
    required this.id,
  });
}
