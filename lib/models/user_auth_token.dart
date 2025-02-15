import 'package:json_annotation/json_annotation.dart';

part 'user_auth_token.g.dart';

@JsonSerializable()
class UserAuthToken {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'client_ip')
  final String? clientIp;
  @JsonKey(name: 'location')
  final String? location;
  @JsonKey(name: 'browser')
  final String? browser;
  @JsonKey(name: 'device')
  final String? device;
  @JsonKey(name: 'os')
  final String? os;
  @JsonKey(name: 'icon')
  final String? icon;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'seen_at')
  final String? seenAt;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  UserAuthToken({
    required this.id,
    this.clientIp,
    this.location,
    this.browser,
    this.device,
    this.os,
    this.icon,
    this.createdAt,
    this.seenAt,
    this.isActive,
  });

  factory UserAuthToken.fromJson(Map<String, dynamic> json) =>
      _$UserAuthTokenFromJson(json);
  Map<String, dynamic> toJson() => _$UserAuthTokenToJson(this);
}
