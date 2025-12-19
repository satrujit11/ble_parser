/// Personal info model
///
/// ```dart
/// final info = PersonalInfo(
///   sex: 1, // 1 = Male, 0 = Female
///   age: 30, // in years
///   height: 175, // in cm
///   weight: 70, // in kg
/// );
/// ```

class PersonalInfo {
  /// Sex: 1 = Male, 0 = Female
  final int sex;

  /// Age in years
  final int age;

  /// Height in cm
  final int height;

  /// Weight in kg
  final int weight;

  const PersonalInfo({
    required this.sex,
    required this.age,
    required this.height,
    required this.weight,
  });

  int get getStepLenth => (sex == 1 ? height * 0.415 : height * 0.413).round();
}
