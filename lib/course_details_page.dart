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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Course Details and Enrolled Students',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              courseName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          imageUrl != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageUrl!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Text('No image available', style: TextStyle(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 16),

                          // عرض الطلاب المقبولين
                          const Text(
                            'Accepted Students',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAcceptedStudentsList(),

                          const SizedBox(height: 16),
                          // عرض الطلبات الجديدة
                          const Text(
                            'New Registration Requests',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRegistrationRequestsList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('registered_accepted').where('course_id', isEqualTo: courseId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading accepted students'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No students accepted'));
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
      stream: FirebaseFirestore.instance.collection('registration_requests').where('course_id', isEqualTo: courseId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading registration requests'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No new registration requests'));
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF980E0E), Color(0xFF330000)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Text(
            'Name: ${student['full_name'] ?? 'No Name'}',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Email: ${student['email'] ?? 'No Email'}',
            style: const TextStyle(color: Colors.white),
          ),
          iconColor: Colors.white, // تغيير لون السهم إلى الأبيض
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${student['phone'] ?? 'No Phone'}', style: const TextStyle(color: Colors.white)),
                  Text('Education: ${student['education'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                  Text('Has Job: ${student['has_job'] == true ? 'Yes' : 'No'}', style: const TextStyle(color: Colors.white)),
                  Text('Has Computer: ${student['has_computer'] == true ? 'Yes' : 'No'}', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF980E0E), Color(0xFF330000)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Text(
            'Name: ${request['full_name'] ?? 'No Name'}',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Email: ${request['email'] ?? 'No Email'}',
            style: const TextStyle(color: Colors.white),
          ),
          iconColor: Colors.white, // تغيير لون السهم إلى الأبيض
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${request['phone'] ?? 'No Phone'}', style: const TextStyle(color: Colors.white)),
                  Text('Education: ${request['education'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                  Text('Has Job: ${request['has_job'] == true ? 'Yes' : 'No'}', style: const TextStyle(color: Colors.white)),
                  Text('Has Computer: ${request['has_computer'] == true ? 'Yes' : 'No'}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextButton(
                          onPressed: () => _confirmRegistration(request, requestId),
                          child: const Text('Confirm', style: TextStyle(color: Colors.green)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextButton(
                          onPressed: () => _rejectRegistration(requestId),
                          child: const Text('Reject', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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