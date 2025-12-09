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

    if (authProvider.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth/login');
      });
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
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUserData?['displayName'] ?? 'Utilisateur',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessage != null)
            Text(
              _formatTime(lastMessage['createdAt']),
              style: TextStyle(
                fontSize: 12,
                color: isUnread ? AppColors.primary : Colors.grey[600],
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (listingData != null) ...[
            const SizedBox(height: 4),
            Text(
              listingData['propertyType'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (lastMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              lastMessage['message'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: isUnread ? AppColors.textDark : Colors.grey[700],
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (value) {
          if (value == 'delete') {
            _showDeleteDialog(conversation['id']);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 12),
                Text('Supprimer', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formater l'heure
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    DateTime date;
    if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(date);
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }

  /// Dialog de confirmation de suppression
  Future<void> _showDeleteDialog(String conversationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Supprimer la conversation ?'),
        content: const Text(
          'Cette action est irréversible. Tous les messages seront supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ChatProvider>().deleteConversation(conversationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation supprimée'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

