import 'package:json_annotation/json_annotation.dart';
import 'package:linux_do/net/http_config.dart';

part 'follow.g.dart';

class FollowResponse {
  final List<Follow> items;

  FollowResponse(this.items);

  factory FollowResponse.fromJson(List<dynamic> jsonArray) {
    final items = jsonArray
        .map((json) => Follow.fromJson(json as Map<String, dynamic>))
        .toList();
    return FollowResponse(items);
  }

  List<Follow> get follows => items;
  
  operator [](int index) => items[index];
  int get length => items.length;
}

@JsonSerializable()
class Follow {
  @JsonKey(name: 'id')
  final int? id;
  
  @JsonKey(name: 'username')
  final String? username;
  
  @JsonKey(name: 'name')
  final String? name;
  
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  Follow({
    this.id,
    this.username,
    this.name,
    this.avatarTemplate,
    this.animatedAvatar,
  });

  // 获取指定尺寸的头像URL
  String getAvatarUrl({int size = 100}) {
    if (avatarTemplate == null) return '';
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll('{size}', size.toString())}';
  }

  bool hasAnimatedAvatar() {
    return animatedAvatar != null && animatedAvatar!.isNotEmpty;
  }

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
  Map<String, dynamic> toJson() => _$FollowToJson(this);
}
