// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'dart:convert';

TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
  final String? id;
  final String? taskName;

  TaskModel({
    this.id,
    this.taskName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json["id"],
    taskName: json["taskName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "taskName": taskName,
  };
}
