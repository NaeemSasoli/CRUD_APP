import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(CRUDApp());

class CRUDApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD with JSONPlaceholder',
      home: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List users = [];
  List posts = [];
  bool showPosts = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchPosts();
  }

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  Future<void> fetchPosts() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    }
  }

  Future<void> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title": title, "body": body, "userId": 1}),
    );
    if (response.statusCode == 201) {
      setState(() {
        posts.insert(0, json.decode(response.body));
      });
    }
  }

  Future<void> updatePost(int id, String newTitle, String newBody) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title": newTitle, "body": newBody}),
    );
    if (response.statusCode == 200) {
      setState(() {
        int index = posts.indexWhere((post) => post['id'] == id);
        if (index != -1) {
          posts[index] = json.decode(response.body);
        }
      });
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
    );
    if (response.statusCode == 200) {
      setState(() {
        posts.removeWhere((post) => post['id'] == id);
      });
    }
  }

  void showCreateDialog() {
    String title = '';
    String body = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) => title = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Body'),
              onChanged: (value) => body = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Create'),
            onPressed: () {
              Navigator.pop(context);
              createPost(title, body);
            },
          ),
        ],
      ),
    );
  }

  void showEditDialog(int id, String currentTitle, String currentBody) {
    String title = currentTitle;
    String body = currentBody;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: title),
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) => title = value,
            ),
            TextField(
              controller: TextEditingController(text: body),
              decoration: InputDecoration(labelText: 'Body'),
              onChanged: (value) => body = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Update'),
            onPressed: () {
              Navigator.pop(context);
              updatePost(id, title, body);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showPosts ? 'Posts' : 'Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                showPosts = !showPosts;
              });
            },
          )
        ],
      ),
      body: showPosts
          ? ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title']),
                  subtitle: Text(post['body']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showEditDialog(
                            post['id'], post['title'], post['body']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deletePost(post['id']),
                      ),
                    ],
                  ),
                );
              },
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                );
              },
            ),
      floatingActionButton: showPosts
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: showCreateDialog,
            )
          : null,
    );
  }
}