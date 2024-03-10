import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color purple = const Color(0xFF6c5ce7);
  Color black = const Color(0xFF191919);

  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    // connectToServer();
    socket = IO.io(
        'http://localhost: 4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  connectToServer() {
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Connected User ${chatController.connectedUser}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                  itemBuilder: (context, index) {
                    var currentItem = chatController.chatMessage[index];
                    return MessageItem(
                      sentByUser1: currentItem.sentByUser1 == socket.id,
                      message: currentItem.message,
                    );
                  },
                  itemCount: chatController.chatMessage.length,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: purple,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: msgInputController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white)),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: purple,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            sendMesssage(msgInputController.text);
                            msgInputController.text = "";
                          },
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void sendMesssage(String text) {
    var messageJson = {"message": text, "sentByUser1": socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessage.add(MessageModel.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receice', (msg) {
      print(msg);
      chatController.chatMessage.add(MessageModel.fromJson(msg));
    });
    socket.on('connected-user', (data) {
      print(data);
      chatController.connectedUser.value = data;
    });
  }
}

class MessageItem extends StatelessWidget {
  final bool sentByUser1;
  final String message;
  const MessageItem(
      {super.key, required this.sentByUser1, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentByUser1 ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sentByUser1 ? Colors.purple : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(
                color: sentByUser1 ? Colors.white : Colors.purple,
                // fontSize: 15
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '10:55 PM',
              style: TextStyle(
                color: (sentByUser1 ? Colors.white : Colors.purple)
                    .withOpacity(0.7),
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
