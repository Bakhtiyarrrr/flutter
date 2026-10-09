import 'package:hive_ce/hive.dart';
import 'dart:typed_data';

part 'activity.g.dart';

// class Activity {
//   String title;
//   String priority;
//   bool iscompleted = false;
//   Activity({
//     required this.title,
//     required this.priority,
//     this.iscompleted = false,
//   });
// }

@HiveType(typeId: 0)
class Activity extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String priority;

  @HiveField(2)
  bool iscompleted;

  @HiveField(3)
  DateTime? createdAt;

  Activity({
    required this.title,
    required this.priority,
    this.iscompleted = false,
    this.createdAt,
    this.imageBytes,
  });

  @HiveField(4)
  Uint8List? imageBytes;
}
