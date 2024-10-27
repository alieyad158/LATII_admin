import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _continueLearningSection(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildWorkshopCard(
                    context,
                    title: 'Workshop on Flutter Development',
                    date: 'October 25, 2024',
                    time: '3:00 PM - 5:00 PM',
                    description: 'Join us for an exciting workshop on Flutter development where you will learn to build beautiful apps.',
                  ),
                  const SizedBox(height: 16),
                  _buildWorkshopCard(
                    context,
                    title: 'UI/UX Design Principles',
                    date: 'November 1, 2024',
                    time: '10:00 AM - 1:00 PM',
                    description: 'Explore the fundamentals of UI/UX design and how to create user-friendly interfaces.',
                  ),
                  const SizedBox(height: 16),
                  _buildWorkshopCard(
                    context,
                    title: 'Backend Development with Node.js',
                    date: 'November 8, 2024',
                    time: '2:00 PM - 4:00 PM',
                    description: 'Learn how to create scalable backend services using Node.js and Express.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddContentPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF980E0E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add Content'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(
      BuildContext context, {
        required String title,
        required String date,
        required String time,
        required String description,
      }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF980E0E),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registered for the workshop!')),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF980E0E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Register Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _continueLearningSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset('images/im1.png', height: 60, width: 60, fit: BoxFit.cover),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('APP', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text(
                    'Bootcamp of Mobile App From Scratch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                    value: 0.75,
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC02626)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '23 of 33 Lessons • 75% completed',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddContentPage extends StatefulWidget {
  const AddContentPage({Key? key}) : super(key: key);

  @override
  _AddContentPageState createState() => _AddContentPageState();
}

class _AddContentPageState extends State<AddContentPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String? selectedType = 'Workshop'; // Default to Workshop
  DateTime? startDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> contentTypes = ['Workshop', 'Announcement'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF980E0E), Color(0xFF330000)],
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
                    'Add New Content',
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              label: 'Content Title',
                              onChanged: (value) {
                                title = value;
                              },
                              icon: Icons.title,
                            ),
                            const SizedBox(height: 16),
                            // Dropdown for selecting content type
                            DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: InputDecoration(
                                labelText: 'Type',
                                labelStyle: const TextStyle(color: Color(0xFF860F06)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF860F06)),
                                ),
                              ),
                              items: contentTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedType = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Conditional fields based on type
                            if (selectedType == 'Workshop') ...[
                              _buildDateField(context),
                              const SizedBox(height: 16),
                              _buildTimeField(context, isStart: true),
                              const SizedBox(height: 16),
                              _buildTimeField(context, isStart: false),
                            ],
                            if (selectedType == 'Announcement') ...[
                              _buildTextField(
                                label: 'Content Description',
                                onChanged: (value) {
                                  description = value;
                                },
                                icon: Icons.description,
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // هنا يمكنك إضافة كود لحفظ المحتوى
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Content added successfully!')),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide.none,
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF980E0E), Color(0xFF330000)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 88.0,
                                    minHeight: 48.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Add Content',
                                    style: TextStyle(
                                      color: Colors.white,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF860F06)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        prefixIcon: Icon(icon, color: Color(0xFF860F06)),
      ),
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Workshop Date',
        labelStyle: const TextStyle(color: Color(0xFF860F06)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                startDate = pickedDate;
              });
            }
          },
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: startDate != null ? "${startDate!.toLocal()}".split(' ')[0] : '',
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, {required bool isStart}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: isStart ? 'Start Time' : 'End Time',
        labelStyle: const TextStyle(color: Color(0xFF860F06)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: isStart ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
            );
            if (pickedTime != null) {
              setState(() {
                if (isStart) {
                  startTime = pickedTime;
                } else {
                  endTime = pickedTime;
                }
              });
            }
          },
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: isStart
            ? (startTime != null ? startTime!.format(context) : '')
            : (endTime != null ? endTime!.format(context) : ''),
      ),
    );
  }
}