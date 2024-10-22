import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Edit_course.dart'; // تأكد من أن اسم الملف صحيح
import 'course_details_page.dart';
import 'add_course_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? selectedCategory;
  final List<Map<String, dynamic>> courses = [];
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();
      setState(() {
        courses.clear();
        for (var doc in snapshot.docs) {
          courses.add({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }
      });
    } catch (e) {
      print("Error fetching courses: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(
          courseId: course['id'],
          courseName: course['title'],
          imageUrl: course['image'],
        ),
      ),
    );
  }

  Widget _filterButtonsWithImages() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton('All', Icons.list),
          const SizedBox(width: 8),
          _filterButton('Programming', 'images/cod.png'),
          const SizedBox(width: 8),
          _filterButton('Design', 'images/dis.png'),
          const SizedBox(width: 8),
          _filterButton('Cybersecurity', 'images/sy.png'),
          const SizedBox(width: 8),
          _filterButton('App Development', 'images/app.png'),
        ],
      ),
    );
  }

  Widget _filterButton(String title, dynamic icon) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = (isSelected && title == 'All') ? null : title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.red[100] : Colors.white,
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 8),
            icon is IconData
                ? Icon(icon, size: 40)
                : SizedBox(
              width: 40,
              height: 40,
              child: ClipOval(
                child: Image.asset(
                  icon,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coursesList() {
    final filteredCourses = selectedCategory == null || selectedCategory == 'All'
        ? courses
        : courses.where((course) => course['category'] == selectedCategory).toList();

    return Column(
      children: filteredCourses.map<Widget>((course) {
        return _courseCard(course);
      }).toList(),
    );
  }

  Widget _courseCard(Map<String, dynamic> course) {
    Timestamp? publishedDate = course['published_date'];

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          _navigateToCourseDetails(course);
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // استخدام رابط الصورة من Firebase Storage
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    course['image'] != null && course['image'].isNotEmpty
                        ? course['image']
                        : 'https://via.placeholder.com/100', // رابط افتراضي للصورة
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error, size: 40));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'] ?? 'No Title',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(course['description'] ?? 'No Description'),
                      const SizedBox(height: 8),
                      Text('Duration: ${course['duration'] ?? 'Not Specified'}'),
                      const SizedBox(height: 8),
                      Text('Location: ${course['location'] ?? 'Not Specified'}'),
                      const SizedBox(height: 8),
                      Text(
                        _formatPublishedDate(publishedDate),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _actionButtonWithIcon(Icons.delete, () {
                      _showDeleteConfirmationDialog(course['id']);
                    }),
                    const SizedBox(height: 8),
                    _editIconButton(course),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editIconButton(Map<String, dynamic> course) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
          _editCourse(course);
        },
      ),
    );
  }

  Widget _actionButtonWithIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _showDeleteConfirmationDialog(String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذه الدورة؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () {
                _deleteCourse(courseId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatPublishedDate(Timestamp? publishedDate) {
    if (publishedDate == null) return 'Unknown Date';

    final Duration difference = DateTime.now().difference(publishedDate.toDate());

    if (difference.inDays < 7) {
      if (difference.inHours > 0) {
        return 'تم نشره منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'تم نشره منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'تم نشره منذ ثوانٍ';
      }
    } else {
      return '${publishedDate.toDate().day}/${publishedDate.toDate().month}/${publishedDate.toDate().year}';
    }
  }

  void _deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      _fetchCourses();
    } catch (e) {
      print("Error deleting course: $e");
    }
  }

  void _editCourse(Map<String, dynamic> course) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCoursePage(course: course)),
    );
    if (result == true) {
      _fetchCourses();
    }
  }

  Widget _addCourseButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCoursePage()),
        );
        if (result == true) {
          _fetchCourses(); // تحديث القائمة بعد إضافة الدورة
        }
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF980E0E),
              Color(0xFF330000),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Add New Course',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Courses', style: TextStyle(color: Colors.white)),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _filterButtonsWithImages(),
          Expanded(child: _coursesList()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _addCourseButton(),
          ),
        ],
      ),
    );
  }
}