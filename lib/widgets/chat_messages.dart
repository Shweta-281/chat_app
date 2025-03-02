import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }


        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final messageDoc = loadedMessages[index];
            final chatMessage = messageDoc.data() as Map<String, dynamic>? ?? {};
            final nextMessageDoc = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1]
                : null;
            final nextChatMessage = nextMessageDoc?.data() as Map<String, dynamic>?;

            final currentUserId = chatMessage['userId']?.toString() ?? '';
            final nextUserId =
                nextChatMessage?['userId']?.toString();
            final nextUserIsSame = nextUserId == currentUserId;

            final userImage = chatMessage['userImage']?.toString() ?? 
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
            final username = chatMessage['username']?.toString() ?? 'Anonymous';
            final messageText = chatMessage['text']?.toString() ?? 'Empty message';

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentUserId,
              );
            }
          },
        );
      },
    );
  }
}