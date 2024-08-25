import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> children = [
    {'name': 'Fatima', 'image': 'assets/child1.png'},
    {'name': 'Fatima', 'image': 'assets/child2.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Children',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
            fontFamily: 'IndieFlower',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
        actions: [
          IconButton(
            icon: Icon(Icons.manage_accounts),
            onPressed: () {
              //account management screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        children[index]['image']!,
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 10),
                      Text(
                        children[index]['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IndieFlower',
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          //child's detail page
                        },
                        child: Text(
                          'View',
                          style: TextStyle(
                            fontFamily: 'IndieFlower',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //add child screen
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
