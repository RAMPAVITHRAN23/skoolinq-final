import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';

class ChatUI extends StatefulWidget {
  final String groupName;
  final String name;

  const ChatUI({required this.name, required this.groupName, super.key});

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  DBService dbService = DBService();
  TextEditingController chatTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomInstantly();
    });
  }

  void _scrollToBottomInstantly() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToBottomSmoothly() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User?>(context);

    return StreamBuilder(
      stream: dbService.chatUsers(widget.groupName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();

        QuerySnapshot querySnapshot = snapshot.data;
        List<DocumentSnapshot> chatDocuments = querySnapshot.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottomSmoothly();
        });

        return Scaffold(
          backgroundColor: Colors.blue[100],  // Background color updated
          appBar: AppBar(
            backgroundColor: Colors.teal,
            title: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfile(userId: widget.name), // Replace with your profile screen
                  ),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.teal),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: chatDocuments.length,
                  itemBuilder: (context, index) {
                    if (chatDocuments[index].id == "1") return const SizedBox();

                    Map<String, dynamic> chats =
                    chatDocuments[index].data() as Map<String, dynamic>;
                    bool isSentByMe = chats["uid"].toString() == user!.uid;

                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.03,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.teal : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          chats["chat"],
                          style: TextStyle(
                            color: isSentByMe ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatTextController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[700],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: screenWidth * 0.03,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          if (chatTextController.text.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection(widget.groupName)
                                .add({
                              "chat": chatTextController.text,
                              "uid": user!.uid,
                              "timeStamp": FieldValue.serverTimestamp(),
                            });
                            chatTextController.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottomSmoothly();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserProfile extends StatelessWidget {
  final String userId;

  const UserProfile({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with actual profile implementation
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Center(
        child: Text("Profile for User ID: $userId"),
      ),
    );
  }
}
