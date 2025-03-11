import 'package:flutter/material.dart';

extension StringExpand on String {
  /// 判断字符串是否为空白
  bool get isNullOrBlank => trim().isEmpty;

  /// 判断字符串是否不为空白
  bool get isNotNullOrBlank => !isNullOrBlank;

  /// 转换为int类型
  int? toInt() => int.tryParse(this);

  /// 转换为double类型
  double? toDouble() => double.tryParse(this);

  /// 是否是手机号
  bool get isPhoneNumber => RegExp(r'^1[3-9]\d{9}$').hasMatch(this);

  /// 是否是邮箱
  bool get isEmail =>
      RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(this);

  /// 是否是URL
  bool get isUrl =>
      RegExp(r'^https?:\/\/([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?$').hasMatch(this);

  // 将十六进制颜色字符串转换为 Color 对象
  Color fromHex() {
    if (length == 6) {
      return Color(int.parse('FF$this', radix: 16));
    }
    return Colors.blue;
  }
}
