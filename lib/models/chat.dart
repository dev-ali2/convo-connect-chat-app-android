class ChatData {
  String name;
  String message;
  String avatarUrl;
  bool isRead;
  String? userId;
  String? email;

  ChatData(
      {required this.name,
      required this.message,
      required this.avatarUrl,
      required this.isRead,
      this.userId,
      this.email});
}
