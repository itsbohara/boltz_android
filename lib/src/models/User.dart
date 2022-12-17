class User {
  String? id;
  String? name;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? role;
  User(
      {this.name,
      this.email,
      this.createdAt,
      this.updatedAt,
      this.role,
      this.id});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    role = json['role'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['role'] = this.role;
    data['id'] = this.id;
    return data;
  }
}
