// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_auth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAuthToken _$UserAuthTokenFromJson(Map<String, dynamic> json) =>
    UserAuthToken(
      id: (json['id'] as num).toInt(),
      clientIp: json['client_ip'] as String?,
      location: json['location'] as String?,
      browser: json['browser'] as String?,
      device: json['device'] as String?,
      os: json['os'] as String?,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] as String?,
      seenAt: json['seen_at'] as String?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$UserAuthTokenToJson(UserAuthToken instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_ip': instance.clientIp,
      'location': instance.location,
      'browser': instance.browser,
      'device': instance.device,
      'os': instance.os,
      'icon': instance.icon,
      'created_at': instance.createdAt,
      'seen_at': instance.seenAt,
      'is_active': instance.isActive,
    };
