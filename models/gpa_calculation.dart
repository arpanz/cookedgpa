List<String> grades = ['O', 'E', 'A', 'B', 'C', 'D', 'F'];

String markstoGrade(double marks) {
  if (marks >= 90 && marks <= 100) {
    return 'O';
  } else if (marks >= 80 && marks < 90) {
    return 'E';
  } else if (marks >= 70 && marks < 80) {
    return 'A';
  } else if (marks >= 60 && marks < 70) {
    return 'B';
  } else if (marks >= 50 && marks < 60) {
    return 'C';
  } else if (marks >= 40 && marks < 50) {
    return 'D';
  } else {
    return 'F';
  }
}

int gradeToPoints(String grade) {
  switch (grade.toUpperCase()) {
    case 'O':
      return 10;
    case 'E':
      return 9;
    case 'A':
      return 8;
    case 'B':
      return 7;
    case 'C':
      return 6;
    case 'D':
      return 5;
    default:
      return 0;
  }
}

double calculateGPA(List<String> grades, List<int> credits) {
  int totalCredits = 0;
  int totalPoints = 0;
  for (int i = 0; i < grades.length; i++) {
    int points = gradeToPoints(grades[i]);
    totalPoints += points * credits[i];
    totalCredits += credits[i];
  }
  if (totalCredits == 0) return 0;
  return totalPoints / totalCredits;
}
