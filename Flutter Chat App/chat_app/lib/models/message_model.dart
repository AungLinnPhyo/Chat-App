class MessageModel {
  String message;
  String sentByUser1;

  MessageModel({required this.message, required this.sentByUser1});
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(message: json["message"], sentByUser1: json["sentByUser1"]);
  }
}