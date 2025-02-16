class UpdatePostRequest {
  final String raw;
  final String? editReason;
  final String? originalText;
  final String topicId;

  UpdatePostRequest({
    required this.raw,
    this.editReason,
    this.originalText,
    required this.topicId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['post[raw]'] = raw;
    if (editReason != null) {
      data['post[edit_reason]'] = editReason;
    }
    if (originalText != null) {
      data['post[original_text]'] = originalText;
    }
    data['post[topic_id]'] = topicId;
    return data;
  }
}
