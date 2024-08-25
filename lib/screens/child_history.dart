import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';

class ChildHistory extends StatefulWidget {
  final String userId;
  final String childName;

  ChildHistory({required this.userId, required this.childName});

  @override
  _ChildHistoryState createState() => _ChildHistoryState();
}

class _ChildHistoryState extends State<ChildHistory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _nickname = '';
  String _age = '';
  String _gender = 'Female';
  String _selectedChildName = "No child selected";
  Map<String, dynamic> _predictions = {
    'hungry': 0,
    'tired': 0,
    'discomfort': 0,
    'burping': 0,
    'belly_pain': 0,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeMessage();
    });
  }

  void _showWelcomeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Please choose a child from the menu to see their pie chart.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<List<String>> _fetchChildrenNames() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('child')
        .where('parID', isEqualTo: widget.userId)
        .get();

    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<void> _fetchChildPredictions(String childName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('child')
        .where('parID', isEqualTo: widget.userId)
        .where('name', isEqualTo: childName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _predictions = snapshot.docs.first['predictions'];
      });
    }
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
        _selectedChildName = selectedName;
      });
      await _fetchChildPredictions(selectedName);
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
      await snapshot.docs.first.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$childName deleted successfully')),
      );
      setState(() {
        if (_selectedChildName == childName) {
          _selectedChildName = "No child selected";
          _predictions = {
            'hungry': 0,
            'tired': 0,
            'discomfort': 0,
            'burping': 0,
            'belly_pain': 0,
          };
        }
      });
    }
  }

  void _showchildrenDialog() {
    showDialog(
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
                      'Enter Child Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Name'),
                            onSaved: (value) {
                              _name = value!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Nickname'),
                            onSaved: (value) {
                              _nickname = value!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Age'),
                            onSaved: (value) {
                              _age = value!;
                            },
                          ),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            items: ['Female', 'Male']
                                .map((label) => DropdownMenuItem(
                                      child: Text(label),
                                      value: label,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                            decoration: InputDecoration(labelText: 'Gender'),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _formKey.currentState!.save();
                              _saveChildToFirestore();
                              Navigator.pop(context);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChildToFirestore() async {
    CollectionReference childrenCollection =
        FirebaseFirestore.instance.collection('child');
    String childId = Uuid().v4();

    await childrenCollection.doc(childId).set({
      'name': _name,
      'nickname': _nickname,
      'age': _age,
      'gender': _gender,
      'parID': widget.userId,
      'predictions': {
        'hungry': 0,
        'tired': 0,
        'discomfort': 0,
        'burping': 0,
        'belly_pain': 0,
      },
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Child added successfully')),
    );

    setState(() {
      _selectedChildName = _name;
      _predictions = {
        'hungry': 0,
        'tired': 0,
        'discomfort': 0,
        'burping': 0,
        'belly_pain': 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          _selectedChildName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
            fontFamily: 'IndieFlower',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showchildrenDialog,
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: _showFormDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Child Predictions',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     fontFamily: 'IndieFlower',
            //   ),
            // ),
            SizedBox(height: 20),
            _selectedChildName == "No child selected"
                ? Center(child: Text('Select a child to see their chart.'))
                : Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            _buildLegend(),
          ],  
        ),
      ),
    );
  }

 List<PieChartSectionData> _buildPieChartSections() {
  if (_predictions.isEmpty || _predictions.values.every((value) => value == 0)) {
    return [];
  }

  final total = _predictions.values.reduce((a, b) => a + b);
  return _predictions.entries.map((entry) {
    final value = entry.value;
    final percentage = total == 0 ? 0 : value / total;
    return PieChartSectionData(
      color: _getColor(entry.key),
      value: percentage * 100,
      title: ' (${(percentage * 100).toStringAsFixed(1)}%)',
      titleStyle: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      radius: 80,
    );
  }).toList();
}


  Color _getColor(String key) {
    switch (key) {
      case 'hungry':
        return Colors.blue;
      case 'tired':
        return Colors.red;
      case 'discomfort':
        return Colors.green;
      case 'burping':
        return Colors.purple;
      case 'belly_pain':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _predictions.entries.map((entry) {
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: _getColor(entry.key),
            ),
            SizedBox(width: 8),
            Text(
              '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }).toList(),
    );
  }
}
