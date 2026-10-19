import 'package:flutter/material.dart';
import 'order.dart';

class OrderHistoryPage extends StatelessWidget {
  final List<Order> orders;

  const OrderHistoryPage({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order History")),
      body: orders.isEmpty
          ? Center(child: Text("No orders yet", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: ${order.id}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Name: ${order.name}"),
                        Text("Items: ${order.items.join(", ")}"),
                        Text("Total: ₹${order.total}"),
                        Text("Status: ${order.status}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
