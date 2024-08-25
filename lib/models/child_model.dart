import 'dart:ffi';

class Child{
  final int id;
  final int age;
  final bool Gender;
  final String Name;
  final String NickName;
   List<int> Result = List<int>.filled(5, 0); 
  final int userId;

  Child({
    required this.id,
    required this.age,
    required this.Gender,
    required this.Name,
    required this.NickName,
    required this.Result,
    required this.userId,
    
  });
}