import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/gpa_calculation.dart';

class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  Map<String, dynamic>? gpaData;
  String? selectedSem;
  String? selectedScheme;
  List<String> grades = ['O', 'E', 'A', 'B', 'C', 'D', 'F'];
  List<String> selectedGrades = [];

  @override
  void initState() {
    super.initState();
    loadGpaData();
  }

  Future<void> loadGpaData() async {
    final String jsonString = await rootBundle.loadString(
      "assets/gpa_short.json",
    );
    setState(() {
      gpaData = json.decode(jsonString);
    });
  }

  List<DropdownMenuItem<String>> getSemesterDropdownItems() {
    if (gpaData == null) return [];
    return gpaData!.keys
        .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
        .toList();
  }

  List<DropdownMenuItem<String>> getSchemeDropdownItems() {
    if (selectedSem == null) return [];
    final schemes =
        (gpaData![selectedSem!].keys as Iterable).toList().cast<String>();
    return schemes
        .map((scheme) => DropdownMenuItem(value: scheme, child: Text(scheme)))
        .toList();
  }

  List<Map<String, dynamic>> getCourses() {
    if (selectedSem == null) return [];
    final semData = gpaData![selectedSem!];
    if (semData is Map<String, dynamic>) {
      if (semData.length == 1 && semData.containsKey("Default")) {
        final courses = semData['Default']['courses'];
        if (courses is List) {
          return courses.cast<Map<String, dynamic>>();
        }
      } else if (selectedScheme != null &&
          semData.containsKey(selectedScheme)) {
        final courses = semData[selectedScheme]['courses'];
        if (courses is List) {
          return courses.cast<Map<String, dynamic>>();
        }
      }
    }
    return [];
  }

  void updateSelectedGrades(int courseCount) {
    // Ensure selectedGrades has the same length as courses, default to empty string
    if (selectedGrades.length != courseCount) {
      selectedGrades = List<String>.filled(courseCount, '');
    }
  }

  double? getCalculatedGPA(List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) return null;
    if (selectedGrades.any((g) => g.isEmpty)) return null;
    List<int> credits = courses.map((c) => c['credits'] as int).toList();
    return CalculateGPA(selectedGrades, credits);
  }

  @override
  Widget build(BuildContext context) {
    final courses = getCourses();
    updateSelectedGrades(courses.length);
    final gpa = getCalculatedGPA(courses);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cooked GPA",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        elevation: 4,
      ),
      body:
          gpaData == null
              ? Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Centered Semester Selection Card
                      Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.indigo[50],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Select Semester",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                SizedBox(height: 6),
                                DropdownButton<String>(
                                  value: selectedSem,
                                  hint: Text("Semester"),
                                  items: getSemesterDropdownItems(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSem = value;
                                      selectedScheme = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.indigo[900],
                                  ),
                                  dropdownColor: Colors.white,
                                ),
                                if (selectedSem != null &&
                                    gpaData![selectedSem!]
                                        is Map<String, dynamic> &&
                                    gpaData![selectedSem!].length > 1)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        "Select Scheme",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.indigo[900],
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      DropdownButton<String>(
                                        value: selectedScheme,
                                        hint: Text("Scheme"),
                                        items: getSchemeDropdownItems(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedScheme = value;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.indigo[900],
                                        ),
                                        dropdownColor: Colors.white,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ...courses.asMap().entries.map(
                        (entry) => CourseCard(
                          name: entry.value['title'],
                          credits: entry.value['credits'],
                          grades: grades,
                          selectedGrade: selectedGrades[entry.key],
                          onGradeChanged: (String? newGrade) {
                            setState(() {
                              selectedGrades[entry.key] = newGrade ?? '';
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 18),
                      if (courses.isNotEmpty)
                        Center(
                          child: Text(
                            gpa == null
                                ? "Select all grades to calculate GPA"
                                : "GPA: ${gpa.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  gpa == null
                                      ? Colors.red[700]
                                      : Colors.green[800],
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String name;
  final int credits;
  final List<String> grades;
  final String selectedGrade;
  final ValueChanged<String?> onGradeChanged;

  const CourseCard({
    super.key,
    required this.name,
    required this.credits,
    required this.grades,
    required this.selectedGrade,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  credits.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedGrade.isEmpty ? null : selectedGrade,
                hint: Text("Grade"),
                items:
                    grades
                        .map(
                          (grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(
                              grade,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: onGradeChanged,
                borderRadius: BorderRadius.circular(10),
                style: TextStyle(fontSize: 13, color: Colors.indigo[900]),
                dropdownColor: Colors.indigo[50],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
