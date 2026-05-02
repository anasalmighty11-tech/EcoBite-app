import 'package:test_eco/screens/authentication/login.dart';
import 'package:test_eco/services/ProfileUserService.dart';

import 'package:flutter/material.dart';
// Make sure to import your service and model here
// import 'package:eco_bite/services/user_service.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryGreen = const Color(0xFF084D0B);
  final Color accentOrange = const Color(0xFFF57C00);
  
  // Instance of the service you already added
  final UserService _userService = UserService();
  
  // Placeholder ID - will be replaced by your Auth logic later
  final String currentUserId = "123"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "Profile", 
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<UserProfile?>(
        future: _userService.getUserProfile(currentUserId),
        builder: (context, snapshot) {
          // 1. Show loading spinner while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle data or fallback to defaults if error occurs
          final user = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Profile Header with dynamic Name and Email
                _buildProfileHeader(
                  user?.name ?? "User Name", 
                  user?.email ?? "user@example.com"
                ),
                
                const SizedBox(height: 24),
                
                // Stats Row with dynamic counts
                _buildStatsRow(
                  user?.postsCount.toString() ?? "0", 
                  user?.sharedCount.toString() ?? "0"
                ),
                
                const SizedBox(height: 24),
                
                // Content Sections
                _buildSectionTitle("Personal Information"),
                _buildProfileItem(Icons.person_outline, "Name", user?.name ?? "N/A"),
                _buildProfileItem(Icons.email_outlined, "Email", user?.email ?? "N/A"),
                _buildProfileItem(Icons.location_on_outlined, "Location", user?.location ?? "Sétif, Algeria"),
                
                const SizedBox(height: 16),
                _buildSectionTitle("My Activity"),
                _buildMenuCard(Icons.fastfood_outlined, "My Food Posts", "Manage your shared items", onTap: () {
                  // Navigate to user's specific posts
                }),
                _buildMenuCard(Icons.history, "History", "Past shares and claims"),
                _buildMenuCard(Icons.favorite_border, "Favorites", "Items you saved"),
                
                const SizedBox(height: 16),
                _buildSectionTitle("App Settings"),
                _buildMenuCard(Icons.settings_outlined, "Settings", "Notifications & Privacy"),
                _buildMenuCard(
                  Icons.logout, 
                  "Logout", 
                  "Sign out of your account", 
                  isLogout: true,
                  onTap: () => _handleLogout(context),
                ),
                
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: primaryGreen.withOpacity(0.1),
              child: Icon(Icons.person, size: 60, color: primaryGreen),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: accentOrange, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatsRow(String posts, String shared) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem(posts, "Posts"),
        _statItem(shared, "Shared"),
        _statItem("5", "Badges"),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentOrange, size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String subtitle, {bool isLogout = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : primaryGreen),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isLogout ? Colors.red : Colors.black87)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await _userService.logout();
    // Clear the screen history so user can't go back to profile
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }
}