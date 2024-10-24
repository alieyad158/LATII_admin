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
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('job_seekers').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          _notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return _notificationItem(
                context,
                notification.data()?['name'] as String?,
                notification.data()?['courseId'] as String?,
                notification.data()?['timestamp']?.toDate().toString() ?? 'No time',
                notification.id,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptNotification(String notificationId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestDoc =
      await _firestore.collection('job_seekers').doc(notificationId).get();

      if (requestDoc.exists) {
        await _firestore.collection('job_seekers_accepted').add({
          'name': requestDoc.data()?['name'],
          'courseId': requestDoc.data()?['courseId'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('job_seekers').doc(notificationId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification accepted successfully.'),
          ),
        );
      } else {
        print('Request document does not exist: $notificationId'); // Debugging line
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting notification: $e'),
        ),
      );
      print('Error accepting notification: $e'); // Debugging line
    }
  }

  Future<void> _rejectNotification(String notificationId) async {
    try {
      await _firestore.collection('job_seekers').doc(notificationId).delete();

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
      print('Error rejecting notification: $e'); // Debugging line
    }
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
                    '$studentName طلب التسجيل في $courseId',
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
                  icon: const Icon(Icons.check, color: Colors .green),
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