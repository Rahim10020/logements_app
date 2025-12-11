import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/message_model.dart';
import '../../../core/config/firebase_config.dart';

/// Provider pour gérer les conversations et messages
class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // État
  List<Map<String, dynamic>> _conversations = [];
  final List<MessageModel> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadCount = 0;

  // Getters
  List<Map<String, dynamic>> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  /// Récupérer toutes les conversations de l'utilisateur
  Future<void> fetchConversations(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Récupérer les conversations où l'utilisateur est participant
      final snapshot = await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .get();

      _conversations = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      // Calculer les non lus
      _calculateUnreadCount(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger les conversations.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculer le nombre de messages non lus
  void _calculateUnreadCount(String userId) {
    _unreadCount = 0;
    for (var conv in _conversations) {
      final lastMessage = conv['lastMessage'] as Map<String, dynamic>?;
      if (lastMessage != null &&
          lastMessage['senderId'] != userId &&
          !(lastMessage['isRead'] ?? false)) {
        _unreadCount++;
      }
    }
  }

  /// Stream des conversations (temps réel)
  Stream<List<Map<String, dynamic>>> watchConversations(String userId) {
    return _firestore
        .collection(FirebaseConfig.conversationsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _conversations = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _calculateUnreadCount(userId);
      notifyListeners();

      return _conversations;
    });
  }

  /// Récupérer les messages d'une conversation
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _firestore
        .collection(FirebaseConfig.conversationsCollection)
        .doc(conversationId)
        .collection(FirebaseConfig.messagesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String message,
    String? listingId,
  }) async {
    try {
      final messageData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Ajouter le message
      await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .doc(conversationId)
          .collection(FirebaseConfig.messagesCollection)
          .add(messageData);

      // Mettre à jour la conversation
      await _firestore.collection(FirebaseConfig.conversationsCollection).doc(conversationId).update({
        'lastMessage': {
          ...messageData,
          'createdAt': DateTime.now(),
        },
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible d\'envoyer le message.';
      notifyListeners();
      rethrow;
    }
  }

  /// Créer ou récupérer une conversation
  Future<String> getOrCreateConversation({
    required String userId,
    required String otherUserId,
    required String listingId,
    Map<String, dynamic>? listingData,
    Map<String, dynamic>? otherUserData,
  }) async {
    try {
      // Vérifier si une conversation existe déjà
      final existingConversation = await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .where('participants', arrayContains: userId)
          .where('listingId', isEqualTo: listingId)
          .get();

      // Filtrer pour trouver la conversation avec les deux participants
      final matchingConv = existingConversation.docs.where((doc) {
        final participants = List<String>.from(doc.data()['participants']);
        return participants.contains(otherUserId);
      }).toList();

      if (matchingConv.isNotEmpty) {
        return matchingConv.first.id;
      }

      // Créer nouvelle conversation
      final newConv = await _firestore.collection(FirebaseConfig.conversationsCollection).add({
        'participants': [userId, otherUserId],
        'listingId': listingId,
        'listingData': listingData,
        'participantsData': {
          userId: null,
          otherUserId: otherUserData,
        },
        'lastMessage': null,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return newConv.id;
    } catch (e) {
      _errorMessage = 'Impossible de créer la conversation.';
      notifyListeners();
      rethrow;
    }
  }

  /// Marquer les messages comme lus
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final messages = await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .doc(conversationId)
          .collection(FirebaseConfig.messagesCollection)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Mettre à jour le lastMessage si c'était non lu
      final conv = await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .doc(conversationId)
          .get();

      if (conv.exists) {
        final data = conv.data()!;
        final lastMsg = data['lastMessage'] as Map<String, dynamic>?;
        if (lastMsg != null && lastMsg['receiverId'] == userId) {
          await _firestore
              .collection(FirebaseConfig.conversationsCollection)
              .doc(conversationId)
              .update({
            'lastMessage.isRead': true,
          });
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur marquage lu: $e');
    }
  }

  /// Supprimer une conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Supprimer les messages
      final messages = await _firestore
          .collection(FirebaseConfig.conversationsCollection)
          .doc(conversationId)
          .collection(FirebaseConfig.messagesCollection)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer la conversation
      batch.delete(
        _firestore.collection(FirebaseConfig.conversationsCollection).doc(conversationId),
      );

      await batch.commit();

      _conversations.removeWhere((c) => c['id'] == conversationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de supprimer la conversation.';
      notifyListeners();
      rethrow;
    }
  }
}
