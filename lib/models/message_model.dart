class ChatMessage {
  final int id;
  final String text;
  final String? audioPath;
  bool isSentByMe;

  ChatMessage({
    required this.id,
    required this.text,
    this.isSentByMe = false,
    this.audioPath,
  });
}