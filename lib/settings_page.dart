import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isArabic = false;
  bool _isDarkMode = false;
  File? _profileImage;
  String? _adminName;
  String? _adminEmail;
  String? _adminProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    final adminProfileDoc = await FirebaseFirestore.instance.collection('admin_profile').doc('admin').get();
    if (adminProfileDoc.exists) {
      setState(() {
        _adminName = adminProfileDoc.data()!['name'];
        _adminEmail = adminProfileDoc.data()!['email'];
        _adminProfileImageUrl = adminProfileDoc.data()!['profileImageUrl'];
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('admin_profile_image.jpg');
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      setState(() {
        _profileImage = file;
        _adminProfileImageUrl = imageUrl;
      });
      await FirebaseFirestore.instance.collection('admin_profile').doc('admin').set({
        'name': _adminName,
        'email': _adminEmail,
        'profileImageUrl': imageUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            _isArabic ? 'الإعدادات' : 'Settings',
            style: const TextStyle(
              color: Colors.white, // Set the app bar title to white
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF9b1a1a),
                  const Color(0xFFb71111c),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isArabic ? 'الإعدادات' : 'Settings',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailsPage(
                        adminName: _adminName,
                        adminEmail: _adminEmail,
                        adminProfileImageUrl: _adminProfileImageUrl,
                        profileImage: _profileImage,
                      ),
                    ),
                  );
                },
                child: _buildProfileSection(),
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : _adminProfileImageUrl != null
                ? NetworkImage(_adminProfileImageUrl!)
                : const NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _adminName ?? 'LATI',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _adminEmail ?? 'LATI@Libyan.org',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF9b1a1a)),
            title: Text(_isArabic ? 'تغيير اللغة' : 'Change Language'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('العربية'),
                Checkbox(
                  value: _isArabic,
                  onChanged: (bool? value) {
                    setState(() {
                      _isArabic = value ?? false;
                    });
                  },
                ),
              ],
            ),
            onTap: () {
              // Implement language change functionality if needed
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Color(0xFF9b1a1a)),
            title: Text(_isArabic ? 'الوضع الداكن' : 'Dark Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            onTap: () {
              // Implement dark mode toggle if needed
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF9b1a1a)),
            title: Text(_isArabic ? 'الإشعارات' : 'Notifications'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Implement notifications settings functionality
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF9b1a1a)),
            title: Text(_isArabic ? 'سياسة الخصوصية' : 'Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Implement privacy policy functionality
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF9b1a1a)),
            title: Text(_isArabic ? 'حول' : 'About'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Implement about functionality
            },
          ),
        ],
      ),
    );
  }
}

class ProfileDetailsPage extends StatelessWidget {
  final String? adminName;
  final String? adminEmail;
  final String? adminProfileImageUrl;
  final File? profileImage;

  const ProfileDetailsPage({
    Key? key,
    required this.adminName,
    required this.adminEmail,
    required this.adminProfileImageUrl,
    required this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF9b1a1a),
                const Color(0xFFb71111c),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : adminProfileImageUrl != null
                      ? NetworkImage(adminProfileImageUrl!)
                      : const NetworkImage('https://via.placeholder.com/150'),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9b1a1a), // Updated container color
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              adminName ?? 'LATI',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              adminEmail ?? 'LATI@Libyan.org',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF9b1a1a),
                      const Color(0xFFb71111c),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi. Donec vel magna ut magna efficitur efficitur. Praesent vel efficitur magna.',
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}