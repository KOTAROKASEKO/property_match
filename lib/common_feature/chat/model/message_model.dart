import 'package:isar/isar.dart';

part 'message_model.g.dart';

@collection
class MessageModel {
  Id id = Isar.autoIncrement; // ✅ Isar用の内部ID（Webでも動く）

  @Index(unique: true, replace: true)
  late String messageId; // ✅ Firestoreなどで使う文字列ID

  @Index()
  late String chatRoomId;

  late String whoSent;
  late String whoReceived;
  late bool isOutgoing;
  String? messageText;
  late String messageType;
  String operation = 'normal';
  String status = 'sending';
  bool isRead = false;

  @Index()
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
