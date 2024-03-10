import 'package:chat_app/models/message_model.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var chatMessage = <MessageModel>[].obs;
  var connectedUser = 0.obs;
}