import 'package:flutter/material.dart';
import 'package:crydetect/models/message_model.dart';
import 'package:flutter_sound/flutter_sound.dart';

class MessageWidget extends StatefulWidget {
  final ChatMessage inputMsg;

  const MessageWidget({super.key, required this.inputMsg});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> playAudio(String path) async {
    await _player.startPlayer(fromURI: path);
  }

  @override
  Widget build(BuildContext context) {
    final isAudioMessage = widget.inputMsg.audioPath != null;

    return GestureDetector(
      onTap:
          isAudioMessage ? () => playAudio(widget.inputMsg.audioPath!) : null,
      child: Container(
        alignment: widget.inputMsg.isSentByMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: EdgeInsets.all(10.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.inputMsg.isSentByMe
                ? Color(0xFF06D6A0)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: isAudioMessage
                ? Icon(Icons.audiotrack)
                : Text(widget.inputMsg.text, style: TextStyle(fontSize: 16.0)),
          ),
        ),
      ),
    );
  }
}
