import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'customer_ui.dart';
import 'pages/admin_menu_tab.dart';

void main() {
  runApp(HotpotApp(adminBuilder: (_) => const AdminLoginPage()));
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoggingIn = false;
  final String baseUrl = "http://127.0.0.1:8000";

  Future<void> login() async {
    if (isLoggingIn) return;
    setState(() => isLoggingIn = true);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/admin/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": usernameController.text.trim(),
              "password": passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data["access_token"] as String?;
        if (token != null && token.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrdersPage(token: token),
            ),
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid admin username or password")),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not connect to the server.")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                "THE NEW HOTPOT",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Owner Login",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                onSubmitted: (_) => login(),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoggingIn ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminOrdersPage(token: "demo-token"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.dashboard_outlined),
                  label: const Text(
                    "Preview Orders Dashboard (Demo / Offline)",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Customer Menu"),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  children: [
                    Text(
                      "Backend: http://127.0.0.1:8000",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "To bypass or test UI without backend, click 'Preview Orders Dashboard'",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class AdminOrdersPage extends StatefulWidget {
  final String token;

  const AdminOrdersPage({super.key, required this.token});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = false;
  bool isDemoMode = false;
  String? errorMessage;
  int _selectedTabIndex = 0;
  final GlobalKey<AdminMenuTabState> _menuTabKey =
      GlobalKey<AdminMenuTabState>();
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  final String baseUrl = "http://127.0.0.1:8000";

  static final List<Map<String, dynamic>> sampleOrders = [
    {
      "id": "172927391001",
      "name": "Arun Kumar",
      "phone": "9876543210",
      "address": "Flat 4B, Emerald Heights, MG Road",
      "total": 490,
      "status": "pending",
      "items": [
        {"food_name": "Chicken Biryani", "quantity": 2},
        {"food_name": "Chicken 65", "quantity": 1},
        {"food_name": "Gulab Jamun", "quantity": 1},
      ],
    },
    {
      "id": "172927391002",
      "name": "Priya Sharma",
      "phone": "9845012345",
      "address": "12, 5th Cross, Indiranagar",
      "total": 330,
      "status": "preparing",
      "items": [
        {"food_name": "Mutton Biryani", "quantity": 1},
        {"food_name": "Chicken Fried Rice", "quantity": 1},
      ],
    },
    {
      "id": "172927391003",
      "name": "Vikram Seth",
      "phone": "9900112233",
      "address": "77 Palm Grove, Koramangala",
      "total": 160,
      "status": "ready",
      "items": [
        {"food_name": "Chicken Biryani", "quantity": 1},
      ],
    },
    {
      "id": "172927391004",
      "name": "Deepa Rao",
      "phone": "9123456780",
      "address": "203 Silicon Residency, HSR Layout",
      "total": 270,
      "status": "delivered",
      "items": [
        {"food_name": "Chicken Fried Rice", "quantity": 1},
        {"food_name": "Chicken 65", "quantity": 1},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    isDemoMode = widget.token == "demo-token";
    fetchOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredOrders {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return orders;
    return orders.where((order) {
      return order['id'].toString().toLowerCase().contains(query) ||
          order['phone'].toString().toLowerCase().contains(query);
    }).toList();
  }

  int countForStatus(String status) =>
      orders.where((order) => order['status']?.toString() == status).length;

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        orders = List<Map<String, dynamic>>.from(
          sampleOrders.map((item) => Map<String, dynamic>.from(item)),
        );
        isLoading = false;
        errorMessage = null;
      });
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/orders"),
            headers: {"Authorization": "Bearer ${widget.token}"},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          orders = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not connect to the server (port 8000).";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    if (isDemoMode) {
      setState(() {
        final idx = orders.indexWhere((o) => o['id'].toString() == orderId);
        if (idx != -1) {
          orders[idx]['status'] = newStatus;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Demo: Order status changed to ${newStatus.toUpperCase()}",
            ),
          ),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(
        "$baseUrl/orders/$orderId/status",
      ).replace(queryParameters: {"status": newStatus});

      final response = await http
          .patch(uri, headers: {"Authorization": "Bearer ${widget.token}"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == newStatus) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Order status changed to ${newStatus.toUpperCase()}",
              ),
            ),
          );

          fetchOrders();
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update order status")),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "preparing":
        return Colors.blue;
      case "ready":
        return Colors.green;
      case "delivered":
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  void logout() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              HotpotApp(adminBuilder: (_) => const AdminLoginPage()),
        ),
        (route) => false,
      );
    }
  }

  Future<void> showOrderDetails(Map<String, dynamic> order) async {
    final status = order['status']?.toString() ?? 'pending';
    final items = List<dynamic>.from(order['items'] ?? const []);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Order details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _StatusBadge(status: status, color: getStatusColor(status)),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Order ID', value: order['id'].toString()),
                _DetailRow(
                  label: 'Customer',
                  value: order['name']?.toString() ?? '—',
                ),
                _DetailRow(
                  label: 'Phone',
                  value: order['phone']?.toString() ?? '—',
                ),
                _DetailRow(
                  label: 'Address',
                  value: order['address']?.toString() ?? '—',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(item['food_name']?.toString() ?? 'Item'),
                        ),
                        Text(
                          '× ${item['quantity'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 28),
                Text(
                  'Total  ₹${order['total']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _orderStatuses.contains(status)
                      ? status
                      : 'pending',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _orderStatuses
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (newStatus) async {
                    if (newStatus == null || newStatus == status) return;
                    Navigator.of(sheetContext).pop();
                    await updateStatus(order['id'].toString(), newStatus);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedOrders = filteredOrders;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedTabIndex == 0 ? "Hotpot Orders" : "Menu Management",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (isDemoMode)
              const Text(
                "Offline / Demo Mode",
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              if (_selectedTabIndex == 0) {
                fetchOrders();
              } else {
                _menuTabKey.currentState?.fetchMenu();
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: _selectedTabIndex == 0 ? "Refresh orders" : "Refresh menu",
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildOrdersTab(displayedOrders),
          AdminMenuTab(
            key: _menuTabKey,
            token: widget.token,
            isDemoMode: isDemoMode,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: "Menu",
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(List<Map<String, dynamic>> displayedOrders) {
    if (isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null && orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.red),
              const SizedBox(height: 14),
              Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "To see live data, run the FastAPI backend on port 8000.\nOr click below to load sample orders and explore the dashboard.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: fetchOrders,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        isDemoMode = true;
                        errorMessage = null;
                        orders = List<Map<String, dynamic>>.from(
                          sampleOrders.map(
                            (item) => Map<String, dynamic>.from(item),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text("Load Sample Orders"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: fetchOrders,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          _SummarySection(
            pending: countForStatus('pending'),
            preparing: countForStatus('preparing'),
            ready: countForStatus('ready'),
            delivered: countForStatus('delivered'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by order ID or phone',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() => searchQuery = '');
                      },
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search',
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Orders (${displayedOrders.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 36),
              child: Center(
                child: Text('No orders yet.', style: TextStyle(fontSize: 18)),
              ),
            )
          else if (displayedOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 36),
              child: Center(child: Text('No matching orders found.')),
            )
          else
            ...displayedOrders.map(_buildOrderCard),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'pending';
    final itemCount = List<dynamic>.from(order['items'] ?? const []).fold<int>(
      0,
      (total, item) => total + ((item['quantity'] as num?)?.toInt() ?? 0),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        title: Text(
          order['name']?.toString() ?? 'Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'ID: ${order['id']}\n${order['phone']}  •  $itemCount item${itemCount == 1 ? '' : 's'}  •  ₹${order['total']}',
          ),
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 86,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusBadge(status: status, color: getStatusColor(status)),
            ],
          ),
        ),
        onTap: () => showOrderDetails(order),
      ),
    );
  }
}

const _orderStatuses = ['pending', 'preparing', 'ready', 'delivered'];

class _SummarySection extends StatelessWidget {
  final int pending;
  final int preparing;
  final int ready;
  final int delivered;
  const _SummarySection({
    required this.pending,
    required this.preparing,
    required this.ready,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        label: 'Pending',
        count: pending,
        color: Colors.orange,
        icon: Icons.schedule,
      ),
      _SummaryCard(
        label: 'Preparing',
        count: preparing,
        color: Colors.blue,
        icon: Icons.restaurant,
      ),
      _SummaryCard(
        label: 'Ready',
        count: ready,
        color: Colors.green,
        icon: Icons.check_circle,
      ),
      _SummaryCard(
        label: 'Delivered',
        count: delivered,
        color: Colors.grey,
        icon: Icons.delivery_dining,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Card(
    color: color.withValues(alpha: 0.10),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      status.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        SelectableText(value),
      ],
    ),
  );
}
