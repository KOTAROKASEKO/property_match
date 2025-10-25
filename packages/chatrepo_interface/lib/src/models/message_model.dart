import 'package:isar/isar.dart';


class MessageModel {
  Id id = Isar.autoIncrement;
  late String messageId;
  late String chatRoomId;
  late String whoSent;
  late String whoReceived;
  late bool isOutgoing;
  String? messageText;
  late String messageType;
  String operation = 'normal';
  String status = 'sending';
  bool isRead = false;
  late DateTime timestamp;
  DateTime? editedAt;
  String? localPath;
  String? remoteUrl;
  String? thumbnailPath;
  int? replyToMessageId;
  String? repliedToMessageText;
  String? repliedToWhoSent;
  String? repliedToMessageId;
}
