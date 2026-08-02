import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatFirestoreDataSource {
  final FirebaseFirestore _firestore;

  ChatFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  Stream<List<ConversationModel>> watchConversations(String myUid) {
    return _conversations
        .where('participantIds', arrayContains: myUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ConversationModel.fromDoc(d, myUid)).toList());
  }

  Stream<List<ChatMessageModel>> watchMessages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessageModel.fromDoc).toList());
  }

  Future<void> ensureConversation({
    required String conversationId,
    required String myUid,
    required Map<String, dynamic> myInfo,
    required String otherUid,
    required Map<String, dynamic> otherInfo,
  }) async {
    final docRef = _conversations.doc(conversationId);
    final snap = await docRef.get();
    if (snap.exists) return;
    await docRef.set({
      'participantIds': [myUid, otherUid],
      'participants': {myUid: myInfo, otherUid: otherInfo},
      'unreadCount': {myUid: 0, otherUid: 0},
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String recipientUid,
    required ChatMessageType type,
    String? text,
    String? mediaUrl,
    int? mediaDurationSeconds,
  }) async {
    final convoRef = _conversations.doc(conversationId);
    final messageRef = convoRef.collection('messages').doc();
    final previewText = type == ChatMessageType.text
        ? text
        : (type == ChatMessageType.image ? '📷 صورة' : '🎤 رسالة صوتية');

    final batch = _firestore.batch();
    batch.set(messageRef, {
      'senderId': senderId,
      'type': type.name,
      if (text != null) 'text': text,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (mediaDurationSeconds != null) 'mediaDurationSeconds': mediaDurationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [senderId],
      'isBroadcast': false,
    });
    batch.update(convoRef, {
      'lastMessage': {
        'text': previewText,
        'type': type.name,
        'senderId': senderId,
      },
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCount.$recipientUid': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> markConversationRead(String conversationId, String myUid) async {
    final convoRef = _conversations.doc(conversationId);
    final unreadSnap =
        await convoRef.collection('messages').where('senderId', isNotEqualTo: myUid).get();

    final batch = _firestore.batch();
    for (final doc in unreadSnap.docs) {
      final readBy = List<String>.from(doc.data()['readBy'] as List? ?? []);
      if (!readBy.contains(myUid)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([myUid]),
        });
      }
    }
    batch.update(convoRef, {'unreadCount.$myUid': 0});
    await batch.commit();
  }
}
