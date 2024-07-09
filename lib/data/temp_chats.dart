import 'package:convo_connect_chat_app/models/chat.dart';

class TempChats {
  List<ChatData> get Chats {
    return [..._chats];
  }

  List<ChatData> _chats = [
    ChatData(
        name: 'Mehar',
        message: 'Hello',
        avatarUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_VTsTN947wxfPvR6azPju20BotT7BNvh_VZLnjduuNQ&s',
        isRead: false),
    ChatData(
        name: 'Ali',
        message: 'Hi',
        avatarUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_VTsTN947wxfPvR6azPju20BotT7BNvh_VZLnjduuNQ&s',
        isRead: true),
    ChatData(
        name: 'Sami',
        message: 'ok',
        avatarUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_VTsTN947wxfPvR6azPju20BotT7BNvh_VZLnjduuNQ&s',
        isRead: true),
    ChatData(
        name: 'Saim',
        message: 'Got it',
        avatarUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_VTsTN947wxfPvR6azPju20BotT7BNvh_VZLnjduuNQ&s',
        isRead: false),
  ];
}
