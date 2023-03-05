class RECIPEModel {
  int? id;
  String? task;
  String? name;
  int? status;

  RECIPEModel(this.id, this.task, this.name, this.status);

  Map<String, dynamic> toJson() => {
        'id': id,
        'task': task,
        'name': name,
        'status': status,
      };

  factory RECIPEModel.fromJson(Map<String, dynamic> json) => RECIPEModel(
        json['id'],
        json['task'],
        json['name'],
        json['status'],
      );

  void add(Map map) {}
}
