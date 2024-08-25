import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crydetect/screens/child_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class PredictVoice extends StatefulWidget {
  final String userId;

  PredictVoice({required this.userId});

  @override
  _PredictVoiceState createState() => _PredictVoiceState();
}

class _PredictVoiceState extends State<PredictVoice> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _nickname = '';
  String _age = '';
  String _gender = 'Female';
  String _selectedChildName = "No child selected";

  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission not granted')),
      );
      return;
    }

    await _recorder!.openRecorder();
  }

  Future<void> _initPlayer() async {
    _player = FlutterSoundPlayer();

    await _player!.openPlayer();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recording started. Please speak now.')),
    );
  }

  Future<void> _stopRecording() async {
    final String? filePath = await _recorder!.stopRecorder();
    final int msgId = messages.length + 1;

    if (filePath != null) {
      setState(() {
        _isRecording = false;
        messages.add(ChatMessage(
          id: msgId,
          isSentByMe: true,
          audioPath: filePath,
        ));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Recording stopped. Your child\'s voice is being processed.')),
      );
      _uploadFile(filePath);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      final int msgId = messages.length + 1;

      setState(() {
        messages.add(ChatMessage(
          id: msgId,
          isSentByMe: true,
          audioPath: filePath,
        ));
      });
      _uploadFile(filePath);
    }
  }

  Future<void> _uploadFile(String filePath) async {
    var uri = Uri.parse('http://192.168.1.11:5000/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
      final prediction = jsonResponse['prediction'];
      print('Response from server: $jsonResponse');
      setState(() {
        messages.add(ChatMessage(
          id: messages.length + 1,
          text: 'Your child ${_getPredictionText(prediction)}',
          isSentByMe: false,
        ));
      });

      // Update Firestore with the new prediction count
      _updatePredictionCount(prediction);
    } else {
      print('File upload failed');
    }
  }

  Future<void> _updatePredictionCount(String prediction) async {
    try {
      // Fetch the document ID of the selected child
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('child')
          .where('parID', isEqualTo: widget.userId)
          .where('name', isEqualTo: _selectedChildName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot childDoc = snapshot.docs.first;
        DocumentReference childRef = childDoc.reference;

        // Increment the prediction count
        await childRef.update({
          'predictions.$prediction': FieldValue.increment(1),
        });

        print('Prediction count updated successfully');
      } else {
        print('Child not found');
      }
    } catch (e) {
      print('Failed to update prediction count: $e');
    }
  }

  String _getPredictionText(String prediction) {
    final Map<String, String> predictionLabels = {
      'belly_pain': 'has belly pain',
      'burping': 'needs to burp',
      'discomfort': 'seems discomforted',
      'hungry': 'is hungry',
      'tired': 'seems tired',
    };

    return predictionLabels[prediction] ?? 'is expressing something';
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      final int msgId = messages.length + 1;
      setState(() {
        messages.add(ChatMessage(id: msgId, text: text, isSentByMe: true));
        _controller.clear();
      });
    }
  }

  Future<List<String>> _fetchChildrenNames() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('child')
        .where('parID', isEqualTo: widget.userId)
        .get();

    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  void _showFormDialog() async {
    List<String> childrenNames = await _fetchChildrenNames();

    final selectedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink, // Header color
                      ),
                    ),
                    SizedBox(height: 20),
                    ...childrenNames.map((name) => ListTile(
                          leading: Icon(Icons.child_care),
                          title: Text(name),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDeleteChild(name);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context, name);
                          },
                        )),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Add Child'),
                      onTap: () {
                        Navigator.pop(context);
                        _showchildrenDialog(); // Close the dialog
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selectedName != null) {
      setState(() {
        // Clear previous messages and result
        messages.clear();
        // Set the selected child's name
        _selectedChildName = selectedName;
      });

      // Display the selected child's name on the screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected child: $_selectedChildName')),
      );
    }
  }

  void _confirmDeleteChild(String childName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete $childName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteChild(childName);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteChild(String childName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('child')
        .where('parID', isEqualTo: widget.userId)
        .where('name', isEqualTo: childName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentReference docRef = snapshot.docs.first.reference;
      await docRef.delete();
      setState(() {
        _selectedChildName = "No child selected";
      });
    }
  }

  void _showchildrenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Child'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nickname'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a nickname';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nickname = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an age';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(labelText: 'Gender'),
                  items: <String>['Female', 'Male'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  _addChild();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addChild() async {
    await FirebaseFirestore.instance.collection('child').add({
      'parID': widget.userId,
      'name': _name,
      'nickname': _nickname,
      'age': _age,
      'gender': _gender,
      'predictions': {
        'belly_pain': 0,
        'burping': 0,
        'discomfort': 0,
        'hungry': 0,
        'tired': 0,
      },
    });

    setState(() {
      _selectedChildName = _name;
    });

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '$_selectedChildName',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: 1.0,
            fontFamily: 'IndieFlower',
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: _showFormDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blue, // Upload button color
            onPressed: _pickFile,
            tooltip: 'Upload',
            child: Icon(Icons.upload),
          ),
          SizedBox(width: 16), // Space between buttons
          FloatingActionButton(
            backgroundColor:
                _isRecording ? Colors.red : Colors.green, // Record button color
            onPressed: _isRecording ? _stopRecording : _startRecording,
            tooltip: 'Record',
            child: Icon(_isRecording ? Icons.stop : Icons.mic),
          ),
          SizedBox(width: 16), // Space between buttons
          FloatingActionButton(
            backgroundColor: Colors.purple, // Color for Child History button
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChildHistory(
                          userId: widget.userId,
                          childName: _selectedChildName,
                        )), // Navigate to ChildHistory page
              );
            },
            tooltip: 'Child History',
            child: Icon(Icons.history),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment:
            message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: message.isSentByMe
                ? const Color.fromARGB(255, 30, 33, 233)
                : Colors.pinkAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: message.audioPath.isNotEmpty
              ? GestureDetector(
                  onTap: () => _playAudio(message.audioPath),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                )
              : Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Increased font size for messages
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _playAudio(String path) async {
    if (_isPlaying) {
      await _player!.stopPlayer();
    } else {
      await _player!.startPlayer(fromURI: path);
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }
}

class ChatMessage {
  final int id;
  final String text;
  final String audioPath;
  final bool isSentByMe;

  ChatMessage({
    required this.id,
    this.text = '',
    this.audioPath = '',
    required this.isSentByMe,
  });
}
