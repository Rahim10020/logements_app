import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

/// Écran de la liste des conversations
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (authProvider.currentUser != null) {
      await chatProvider.fetchConversations(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Si non connecté, on affiche un loader (le redirect global gère la redirection vers /auth/login)
    if (authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Chargement des conversations...',
            );
          }

          if (chatProvider.conversations.isEmpty) {
            return EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'Aucun message',
              message: 'Vos conversations apparaîtront ici.\nContactez un propriétaire pour commencer.',
              buttonText: 'Découvrir des annonces',
              onButtonPressed: () => context.go('/home'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => chatProvider.fetchConversations(
              authProvider.currentUser!.uid,
            ),
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatProvider.conversations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 88,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final conversation = chatProvider.conversations[index];
                return _buildConversationItem(
                  conversation,
                  authProvider.currentUser!.uid,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Item de conversation
  Widget _buildConversationItem(
    Map<String, dynamic> conversation,
    String currentUserId,
  ) {
    final participants = List<String>.from(conversation['participants']);
    final otherUserId = participants.firstWhere((id) => id != currentUserId);
    
    final participantsData = conversation['participantsData'] as Map<String, dynamic>?;
    final otherUserData = participantsData?[otherUserId] as Map<String, dynamic>?;
    
    final listingData = conversation['listingData'] as Map<String, dynamic>?;
    final lastMessage = conversation['lastMessage'] as Map<String, dynamic>?;
    
    final isUnread = lastMessage != null &&
        lastMessage['receiverId'] == currentUserId &&
        !(lastMessage['isRead'] ?? false);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () {
        context.push(
          '/chat/${conversation['id']}',
          extra: {
            'otherUserId': otherUserId,
            'otherUserData': otherUserData,
            'listingData': listingData,
          },
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: otherUserData?['photoURL'] != null
                ? CachedNetworkImageProvider(otherUserData!['photoURL'])
                : null,
            child: otherUserData?['photoURL'] == null
                ? Text(
                    (otherUserData?['displayName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          if (isUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherUserData?['displayName'] ?? 'Utilisateur',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        lastMessage != null ? (lastMessage['text'] ?? '') : 'Nouvelle conversation',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        lastMessage != null && lastMessage['createdAt'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(lastMessage['createdAt']))
            : '',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }
}
