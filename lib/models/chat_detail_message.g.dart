// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_detail_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatDetailMessage _$ChatDetailMessageFromJson(Map<String, dynamic> json) =>
    ChatDetailMessage(
      id: (json['id'] as num?)?.toInt(),
      message: json['message'] as String?,
      cooked: json['cooked'] as String?,
      createdAt: json['created_at'] as String?,
      excerpt: json['excerpt'] as String?,
      deletedAt: json['deleted_at'] as String?,
      deletedById: (json['deleted_by_id'] as num?)?.toInt(),
      threadId: (json['thread_id'] as num?)?.toInt(),
      channelId: (json['chat_channel_id'] as num?)?.toInt(),
      streaming: json['streaming'] as bool,
      user: json['user'] == null
          ? null
          : ChatMessageUser.fromJson(json['user'] as Map<String, dynamic>),
      mentionedUsers: (json['mentioned_users'] as List<dynamic>?)
          ?.map((e) => ChatMessageUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableFlags: (json['available_flags'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      blocks: json['blocks'] as List<dynamic>?,
      chatWebhookEvent: json['chat_webhook_event'],
      uploads: json['uploads'] as List<dynamic>?,
    );

Map<String, dynamic> _$ChatDetailMessageToJson(ChatDetailMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'cooked': instance.cooked,
      'created_at': instance.createdAt,
      'excerpt': instance.excerpt,
      'deleted_at': instance.deletedAt,
      'deleted_by_id': instance.deletedById,
      'thread_id': instance.threadId,
      'chat_channel_id': instance.channelId,
      'streaming': instance.streaming,
      'user': instance.user,
      'mentioned_users': instance.mentionedUsers,
      'available_flags': instance.availableFlags,
      'blocks': instance.blocks,
      'chat_webhook_event': instance.chatWebhookEvent,
      'uploads': instance.uploads,
    };

ChatMessageUser _$ChatMessageUserFromJson(Map<String, dynamic> json) =>
    ChatMessageUser(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String?,
      avatarTemplate: json['avatar_template'] as String?,
      canChat: json['can_chat'] as bool?,
      hasChatEnabled: json['has_chat_enabled'] as bool?,
      moderator: json['moderator'] as bool?,
      admin: json['admin'] as bool?,
      staff: json['staff'] as bool?,
      newUser: json['new_user'] as bool?,
      primaryGroupName: json['primary_group_name'] as String?,
      animatedAvatar: json['animated_avatar'] as String?,
    );

Map<String, dynamic> _$ChatMessageUserToJson(ChatMessageUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar_template': instance.avatarTemplate,
      'can_chat': instance.canChat,
      'has_chat_enabled': instance.hasChatEnabled,
      'moderator': instance.moderator,
      'admin': instance.admin,
      'staff': instance.staff,
      'new_user': instance.newUser,
      'primary_group_name': instance.primaryGroupName,
      'animated_avatar': instance.animatedAvatar,
    };
