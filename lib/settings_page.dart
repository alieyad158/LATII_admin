import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isArabic = false; // حالة اللغة
  bool _isDarkMode = false; // حالة الوضع الداكن

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_isArabic ? 'الإعدادات' : 'Settings'),
          backgroundColor: const Color(0xffb71111c),
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
              _buildProfileSection(), // Profile section
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: Color(0xffb71111c)),
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
                      leading: const Icon(Icons.dark_mode, color: Color(0xffb71111c)),
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
                      leading: const Icon(Icons.notifications, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'الإشعارات' : 'Notifications'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Implement notifications settings functionality
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'سياسة الخصوصية' : 'Privacy Policy'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Implement privacy policy functionality
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info, color: Color(0xffb71111c)),
                      title: Text(_isArabic ? 'حول' : 'About'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Implement about functionality
                      },
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
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual image URL
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Name', // Replace with actual admin name
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'LATI@Libya.com', // Replace with actual email
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}