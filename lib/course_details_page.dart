import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetailsPage extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String? imageUrl;

  const CourseDetailsPage({
    Key? key,
    required this.courseId,
    required this.courseName,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF980E0E),
              Color(0xFF330000),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(courseName),
                  background: imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                backgroundColor: const Color(0xFF980E0E),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Accepted Students'),
                      _buildAcceptedStudentsList(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('New Registration Requests'),
                      _buildRegistrationRequestsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAcceptedStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('registered_accepted')
          .where('course_id', isEqualTo: courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading accepted students'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No students accepted', style: TextStyle(color: Colors.white)));
        }

        final acceptedStudents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: acceptedStudents.length,
          itemBuilder: (context, index) {
            final student = acceptedStudents[index].data() as Map<String, dynamic>;
            return _buildStudentCard(student);
          },
        );
      },
    );
  }

  Widget _buildRegistrationRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('registration_requests')
          .where('course_id', isEqualTo: courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading registration requests'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No new registration requests', style: TextStyle(color: Colors.white)));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            return _buildRequestCard(request, requests[index].id);
          },
        );
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      child: ExpansionTile(
        title: Text(
          'Name: ${student['full_name'] ?? 'No Name'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Email: ${student['email'] ?? 'No Email'}',
          style: const TextStyle(color: Colors.white70),
        ),
        iconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', student['phone'] ?? 'No Phone'),
                _buildInfoRow('Education', student['education'] ?? 'N/A'),
                _buildInfoRow('Has Job', student['has_job'] == true ? 'Yes' : 'No'),
                _buildInfoRow('Has Computer', student['has_computer'] == true ? 'Yes' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String requestId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      child: ExpansionTile(
        title: Text(
          'Name: ${request['full_name'] ?? 'No Name'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Email: ${request['email'] ?? 'No Email'}',
          style: const TextStyle(color: Colors.white70),
        ),
        iconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', request['phone'] ?? 'No Phone'),
                _buildInfoRow('Education', request['education'] ?? 'N/A'),
                _buildInfoRow('Has Job', request['has_job'] == true ? 'Yes' : 'No'),
                _buildInfoRow('Has Computer', request['has_computer'] == true ? 'Yes' : 'No'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _confirmRegistration (request, requestId),
                      child: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _rejectRegistration(requestId),
                      child: const Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRegistration(Map<String, dynamic> registration, String registrationId) async {
    // إضافة المسجل المقبول إلى الكوليكشن الجديد
    await FirebaseFirestore.instance.collection('registered_accepted').doc(registrationId).set(registration);

    // حذف التسجيل من الكوليكشن القديم
    await FirebaseFirestore.instance.collection('registration_requests').doc(registrationId).delete();
  }

  Future<void> _rejectRegistration(String registrationId) async {
    // حذف التسجيل المرفوض من الكوليكشن
    await FirebaseFirestore.instance.collection('registration_requests').doc(registrationId).delete();
  }
}