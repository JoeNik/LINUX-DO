// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerSettings _$BannerSettingsFromJson(Map<String, dynamic> json) =>
    BannerSettings(
      networkUrl: json['networkUrl'] as String?,
      localPath: json['localPath'] as String?,
      useDefault: json['useDefault'] as bool? ?? true,
    );

Map<String, dynamic> _$BannerSettingsToJson(BannerSettings instance) =>
    <String, dynamic>{
      'networkUrl': instance.networkUrl,
      'localPath': instance.localPath,
      'useDefault': instance.useDefault,
    };
