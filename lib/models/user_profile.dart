class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;

  UserProfile({
    required this.uid,
    required this.name,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] as String;
    name = json['name'] as String;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    data['uid'] = uid;
    return data;
  }
}
