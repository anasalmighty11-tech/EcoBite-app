
import 'package:test_eco/screens/chat/chatListPage.dart';
import 'package:test_eco/screens/food/AddFood.dart';
import 'package:test_eco/screens/locations/Mylocations.dart';
import 'package:test_eco/screens/profile/ProfilePage.dart';
import 'package:test_eco/services/FoodService.dart';
import 'package:flutter/material.dart';

class EcoBiteHomeScreen extends StatefulWidget {
  const EcoBiteHomeScreen({super.key});

  @override
  State<EcoBiteHomeScreen> createState() => _EcoBiteHomeScreenState();
}

class _EcoBiteHomeScreenState extends State<EcoBiteHomeScreen> {
  // Brand Colors
  final Color primaryGreen = const Color(0xFF0A5D11);
  final Color accentOrange = const Color(0xFFF57C00); // Your Orange
  final Color bgColor = const Color(0xFFF9FAFB);
  final Color softGreenBg = const Color(0xFFE8F5E9);

  final FoodService _foodService = FoodService();

  // State for filtering and navigation
  String selectedCategory = "All";
  int selectedIndex = 0; // Tracks which bottom nav icon is active

  // Category Data
  final List<Map<String, dynamic>> categories = [
    {"label": "All", "icon": Icons.grid_view_rounded},
    {"label": "Bakery", "icon": Icons.bakery_dining_outlined},
    {"label": "Meals", "icon": Icons.set_meal_outlined},
    {"label": "Veggies", "icon": Icons.eco_outlined},
    {"label": "Pantry", "icon": Icons.takeout_dining_outlined},
  ];

  // Food Data with fixed image links
  // Food Data with high-reliability links
  final List<Map<String, dynamic>> allOffers = [
    {
      "title": "Fresh Sourdough Loaf",
      "cat": "Bakery",
      "dist": "0.3 km",
      "time": "5 mins ago",
      // Reliable Sourdough link
      "img":
          "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=400",
    },
    {
      "title": "Organic Apple Bag",
      "cat": "Veggies",
      "dist": "0.9 km",
      "time": "12 mins ago",
      // Reliable Apple link
      "img":
          "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=400",
    },
    {
      "title": "Vegetarian Bento Box",
      "cat": "Meals",
      "dist": "1.4 km",
      "time": "20 mins ago",
      // Reliable Bento link
      "img":
          "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400",
    },
  ];

 // Corrected: Use a getter or list that calls the internal build method
  List<Widget> get _pages => [
    _buildHomeContent(), // This calls your Sliver code instead of the Class
    const MyLocationsScreen(),
    const ChatListPage(), // This is your chat list page
    const ProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // IndexedStack preserves the state of each page (scroll position, etc.)
      body: IndexedStack(
        index: selectedIndex,
        children: _pages, // This now calls the getter
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodPage()),
          );
        },
        backgroundColor: accentOrange,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/EcoBiteLogo1.png',
            height: 75,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              "EcoBite",
              style: TextStyle(
                  color: primaryGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildNotificationBtn(),
        ],
      ),
    );
  }

  Widget _buildNotificationBtn() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.notifications_outlined, color: primaryGreen),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search food shares...",
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          bool isSelected = selectedCategory == categories[i]['label'];
          return GestureDetector(
            onTap: () =>
                setState(() => selectedCategory = categories[i]['label']),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? accentOrange : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isSelected ? accentOrange : Colors.black12),
                    ),
                    child: Icon(categories[i]['icon'],
                        color: isSelected ? Colors.white : Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Text(categories[i]['label'],
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? accentOrange : Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodOffersList() {
  return FutureBuilder<List<dynamic>>(
    future: _foodService.getAllOffers(), // Calls your Spring Boot API
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        // Fallback to the local hardcoded data if API fails or returns empty
        return _buildLocalFoodList();
      }

      // Filter logic based on your category selection
      final allItems = snapshot.data!;
      final filtered = selectedCategory == "All"
          ? allItems
          : allItems.where((o) => o['category'] == selectedCategory).toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final item = filtered[i];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.black12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  // Backend provides the image URL
                  item['imageUrl'] ?? 'https://via.placeholder.com/150',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
              title: Text(item['title'] ?? "Untitled",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${item['quantity'] ?? 'N/A'} • ${item['category']}"),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey[400]),
              onTap: () {
                // Future: Navigate to food detail page
              },
            ),
          );
        },
      );
    },
  );
}

Widget _buildLocalFoodList() {
  final filtered = selectedCategory == "All"
      ? allOffers
      : allOffers.where((o) => o['cat'] == selectedCategory).toList();

  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filtered.length,
    itemBuilder: (context, i) {
      final item = filtered[i];
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.black12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item['img'] ?? 'https://via.placeholder.com/150',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          title: Text(item['title'] ?? "Untitled",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${item['dist'] ?? 'N/A'} • ${item['cat']}"),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey[400]),
          onTap: () {
            // Future: Navigate to food detail page
          },
        ),
      );
    },
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // --- UPDATED BOTTOM NAV WITH INTERACTIVE COLOR ---
  Widget _buildBottomNav() {
    return BottomAppBar(
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_filled, "Home", 0),
            _navItem(Icons.map_outlined, "Map", 1),
            const SizedBox(width: 40),
            _navItem(Icons.chat_bubble_outline, "Chat", 2),
            _navItem(Icons.person_outline, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? accentOrange : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? accentOrange : Colors.grey,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PersistentSearchBarDelegate(
              child: _buildSearchBar(),
              bgColor: bgColor,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Surplus Categories"),
                _buildCategories(),
                _buildSectionHeader("Nearby Shares"),
                _buildFoodOffersList(),
                const SizedBox(
                    height: 120), // Extra space for the floating button
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersistentSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color bgColor;
  _PersistentSearchBarDelegate({required this.child, required this.bgColor});
  @override
  Widget build(context, shrink, overlaps) => Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child);
  @override
  double get maxExtent => 66.0;
  @override
  double get minExtent => 66.0;
  @override
  bool shouldRebuild(covariant oldDelegate) => false;
}
