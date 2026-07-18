import 'dart:ffi';

class Profiles{
  final int user_id;
  final String first_name;
  final String last_name;
  final String user_name;
  final DateTime created_at;
  final DateTime updated_at;
  final String profile_photo;

  Profiles({
    required this.user_id,
    required this.first_name,
    required this.last_name,
    required this.user_name,
    required this.profile_photo,
    required this.created_at,
    required this.updated_at
  });

  factory Profiles.fromJson(Map<String, dynamic> json){
    return Profiles(
      user_id: json['user_id'] as int,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      user_name: json['user_name'] as String,
      profile_photo: json['profile_photo'] as String,
      created_at: json['created_at'] as DateTime,
      updated_at: json['updated_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'user_id' : user_id,
      'first_name' : first_name,
      'last_name' : last_name,
      'user_name' : user_id,
      'profile_date' : profile_photo,
      'created_at' : created_at,
      'updated_at' : updated_at
    };
  }

}