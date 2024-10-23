import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final snapshot = await _firestore
          .collection('job_seekers') // استيراد الطلبات من مجموعة job_seekers
          .orderBy('timestamp', descending: true) // تأكد من وجود حقل timestamp
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No notifications found.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _notifications = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching notifications: $e';
      });
    }
  }

  Future<void> _acceptNotification(String notificationId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestDoc =
      await _firestore.collection('job_seekers').doc(notificationId).get();

      if (requestDoc.exists) {
        await _firestore.collection('job_seekers_accepted').add({
          'name': requestDoc['name'],
          'courseId': requestDoc['courseId'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('job_seekers').doc(notificationId).delete(); // نقل الطلب

        _fetchNotifications(); // تحديث قائمة الإشعارات
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting notification: $e'),
        ),
      );
    }
  }

  Future<void> _rejectNotification(String notificationId) async {
    try {
      await _firestore.collection('job_seekers').doc(notificationId).delete(); // حذف الطلب

      _fetchNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification rejected successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting notification: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _notificationItem(
            context,
            notification['name'] as String?,
            notification['courseId'] as String?,
            notification['timestamp']?.toDate().toString() ?? 'No time',
            notification.id,
          );
        },
      ),
    );
  }

  Widget _notificationItem(
      BuildContext context,
      String? studentName,
      String? courseId,
      String? time,
      String notificationId) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.notifications, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$studentName has requested to register for $courseId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time ?? 'No time',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    _acceptNotification(notificationId);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _rejectNotification(notificationId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JobSeekersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Seekers')),
      body: Center(child: Text('Job Seekers List')),
    );
  }
}