import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JobSeekerDetailPage.dart';

class JobSeekersPage extends StatefulWidget {
  const JobSeekersPage({super.key});

  @override
  _JobSeekersPageState createState() => _JobSeekersPageState();
}

class _JobSeekersPageState extends State<JobSeekersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> jobSeekers = [];
  bool _isLoading = true;
  List<String> selectedCourses = [];
  bool isGraduate = false;
  String selectedCity = 'All Cities';

  @override
  void initState() {
    super.initState();
    _fetchJobSeekers();
  }

  Future<void> _fetchJobSeekers() async {
    try {
      final snapshot = await _firestore.collection('job_seekers_accepted').get();
      setState(() {
        jobSeekers = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching job seekers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Seekers',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildCityFilters(),
          _buildFilters(),
          Expanded(child: _buildJobSeekersList()),
        ],
      ),
    );
  }

  Widget _buildCityFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All Cities', 'Misrata', 'Tripoli', 'Benghazi'].map((city) {
            final isSelected = selectedCity == city;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCity = city;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF980E0E) : Colors.white,
                  border: Border.all(color: isSelected ? Colors.white : const Color(0xFF980E0E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(right: 10),
                child: Text(
                  city,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF980E0E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildCourseFilters(),
          _buildGraduateCheckbox(),
        ],
      ),
    );
  }

  Widget _buildCourseFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['App Development', 'Cyber Security', 'Cloud Computing'].map((course) {
          final isSelected = selectedCourses.contains(course);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? selectedCourses.remove(course) : selectedCourses.add(course);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF980E0E) : Colors.white,
                border: Border.all(color: isSelected ? Colors.white : const Color(0xFF980E0E)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.only(right: 10),
              child: Text(
                course,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF980E0E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraduateCheckbox() {
    return CheckboxListTile(
      title: const Text("Graduate"),
      value: isGraduate,
      onChanged: (bool? value) {
        setState(() {
          isGraduate = value ?? false;
        });
      },
    );
  }

  Widget _buildJobSeekersList() {
    final filteredJobSeekers = jobSeekers.where((seeker) {
      bool cityMatches = selectedCity == 'All Cities' ||
          (seeker.data().containsKey('city') && seeker.get('city') == selectedCity);
      bool matchesCourses = selectedCourses.isEmpty ||
          (seeker.data().containsKey('courses') &&
              seeker.get('courses').any((course) => selectedCourses.contains(course)));
      bool matchesGraduate = isGraduate ? (seeker.data().containsKey('category') && seeker.get('category') == 'Graduate') : true;

      return cityMatches && matchesCourses && matchesGraduate;
    }).toList();

    return ListView.builder(
      itemCount: filteredJobSeekers.length,
      itemBuilder: (context, index) {
        final seeker = filteredJobSeekers[index];
        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF980E0E),
                  const Color(0xFF330000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (seeker.data().containsKey('city'))
                        Text(
                          seeker.get('city'),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      if (seeker.data().containsKey('category') && seeker.get('category') == 'Graduate') ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.school,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            seeker.data().containsKey('image') ? seeker.get('image') : 'images/default.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seeker.data().containsKey('name') ? seeker.get('name') : "غير متوفر",
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'University: ${seeker.data().containsKey('university') ? seeker.get('university') : "غير متوفر"}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Age: ${seeker.data().containsKey('age') ? seeker.get('age') : "غير متوفر"}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              children: seeker.data().containsKey('courses')
                                  ? seeker.get('courses').map<Widget>((course) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    course,
                                    style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList()
                                  : [],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobSeekerDetailPage(
                              name: seeker.data().containsKey('name') ? seeker.get('name') : 'غير متوفر',
                              email: seeker.data().containsKey('email') ? seeker.get('email') : 'غير متوفر',
                              phone: seeker.data().containsKey('phone') ? seeker.get('phone') : 'غير متوفر',
                              cv: seeker.data().containsKey('cv') ? seeker.get('cv') : 'غير متوفر',
                              image: seeker.data().containsKey('image') ? seeker.get('image') : 'غير متوفر',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFA500),
                              const Color(0xFF980E0E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'View More',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }
}