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
  bool isDark = true; // dark mode is now default
  bool isToppr = false; // toppr toggle state

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
    // Ensure selectedGrades has the same length as courses, default to blank or "O" based on toppr
    String defaultGrade = isToppr ? 'O' : '';
    if (selectedGrades.length != courseCount ||
        selectedGrades.any((g) => g != defaultGrade && g != 'O' && g != '')) {
      selectedGrades = List<String>.filled(courseCount, defaultGrade);
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

    final cardColor = isDark ? Colors.grey[900] : Colors.indigo[50];
    final cardTextColor = isDark ? Colors.white : Colors.indigo[900];
    final dropdownColor = isDark ? Colors.grey[850] : Colors.white;
    final dropdownItemColor = isDark ? Colors.white : Colors.indigo[900];
    final indicatorColor =
        isDark ? Colors.tealAccent : Theme.of(context).colorScheme.primary;

    return Theme(
      data:
          isDark
              ? ThemeData.dark(useMaterial3: true).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.teal,
                  brightness: Brightness.dark,
                ),
                cardColor: Colors.grey[900],
                scaffoldBackgroundColor: Colors.black,
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.grey[950],
                  iconTheme: IconThemeData(color: Colors.tealAccent),
                  titleTextStyle: TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontFamily: "Playpen Sans",
                  ),
                ),
                textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: "Playpen Sans",
                  bodyColor: Colors.white,
                  displayColor: Colors.tealAccent,
                ),
              )
              : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Cooked GPA",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          backgroundColor: isDark ? Colors.grey[950] : Colors.blue.shade600,
          elevation: 4,
          actions: [
            // Toppr toggle button
            Row(
              children: [
                Text(
                  "toppr",
                  style: TextStyle(
                    color: isDark ? Colors.tealAccent : Colors.indigo[900],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 4),
                Switch(
                  value: isToppr,
                  onChanged: (val) {
                    setState(() {
                      isToppr = val;
                      // Instantly update all grades to blank or "O"
                      selectedGrades = List<String>.filled(
                        getCourses().length,
                        isToppr ? 'O' : '',
                      );
                    });
                  },
                  activeColor: Colors.tealAccent,
                  inactiveThumbColor: Colors.grey,
                ),
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip:
                      isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
                  color: isDark ? Colors.tealAccent : null,
                  onPressed: () {
                    setState(() {
                      isDark = !isDark;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        body:
            gpaData == null
                ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: indicatorColor,
                  ),
                )
                : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Centered Semester Selection Card
                        Center(
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 24.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Select Semester",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: cardTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  DropdownButton<String>(
                                    value: selectedSem,
                                    hint: Text(
                                      "Semester",
                                      style: TextStyle(
                                        color: dropdownItemColor,
                                      ),
                                    ),
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
                                      color: dropdownItemColor,
                                    ),
                                    dropdownColor: dropdownColor,
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
                                            color: cardTextColor,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        DropdownButton<String>(
                                          value: selectedScheme,
                                          hint: Text(
                                            "Scheme",
                                            style: TextStyle(
                                              color: dropdownItemColor,
                                            ),
                                          ),
                                          items: getSchemeDropdownItems(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedScheme = value;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: dropdownItemColor,
                                          ),
                                          dropdownColor: dropdownColor,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        ...courses
                            .asMap()
                            .entries
                            .map(
                              (entry) => CourseCard(
                                name: entry.value['title'],
                                credits: entry.value['credits'],
                                grades: grades,
                                selectedGrade: selectedGrades[entry.key],
                                onGradeChanged: (String? newGrade) {
                                  setState(() {
                                    selectedGrades[entry.key] =
                                        newGrade ?? (isToppr ? 'O' : '');
                                  });
                                },
                                isDark: isDark,
                              ),
                            )
                            .toList(),
                        SizedBox(height: 18),
                        if (courses.isNotEmpty) ...[
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
                                        ? (isDark
                                            ? Colors.red[300]
                                            : Colors.red[700])
                                        : (isDark
                                            ? Colors.tealAccent
                                            : Colors.green[800]),
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
  final bool isDark;

  const CourseCard({
    super.key,
    required this.name,
    required this.credits,
    required this.grades,
    required this.selectedGrade,
    required this.onGradeChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.indigo[900];
    final creditColor = isDark ? Colors.tealAccent : Colors.indigo[700];
    final dropdownColor = isDark ? Colors.grey[850] : Colors.indigo[50];
    final dropdownTextColor = isDark ? Colors.white : Colors.indigo[900];

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: cardColor,
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
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.indigo[50],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  credits.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: creditColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedGrade.isEmpty ? null : selectedGrade,
                hint: Text("Grade", style: TextStyle(color: dropdownTextColor)),
                items:
                    grades
                        .map(
                          (grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(
                              grade,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: dropdownTextColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: onGradeChanged,
                borderRadius: BorderRadius.circular(10),
                style: TextStyle(fontSize: 13, color: dropdownTextColor),
                dropdownColor: dropdownColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
