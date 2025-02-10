import 'package:json_annotation/json_annotation.dart';

import '../net/http_config.dart';

part 'topic_detail.g.dart';

@JsonSerializable()
class TopicDetail {
  final int id;
  final String? title;
  @JsonKey(name: 'fancy_title')
  final String? fancyTitle;
  @JsonKey(name: 'posts_count')
  final int? postsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final int? views;
  @JsonKey(name: 'reply_count')
  final int? replyCount;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'last_posted_at')
  final String? lastPostedAt;
  final bool? visible;
  final bool? closed;
  final bool? archived;
  final String? archetype;
  final String? slug;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'word_count')
  final int? wordCount;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'current_post_number')
  final int? currentPostNumber;
  @JsonKey(name: 'highest_post_number')
  final int? highestPostNumber;
  @JsonKey(name: 'last_read_post_number')
  final int? lastReadPostNumber;
  @JsonKey(name: 'last_read_post_id')
  final int? lastReadPostId;
  @JsonKey(name: 'chunk_size')
  final int? chunkSize;
  @JsonKey(name: 'post_stream')
  final PostStream? postStream;
  final List<String>? tags;
  final String? categoryName;
  @JsonKey(name: 'details') 
  final Detail? details;
  @JsonKey(name: 'participants_count')
  final int? participantsCount;
  @JsonKey(name: 'bookmarks')
  final List<Bookmarks>? bookmarks;
  final bool? bookmarked;



  TopicDetail({
    required this.id,
    this.title,
    this.fancyTitle,
    this.postsCount,
    this.createdAt,
    this.views,
    this.replyCount,
    this.likeCount,
    this.lastPostedAt,
    this.visible,
    this.closed,
    this.archived,
    this.archetype,
    this.slug,
    this.categoryId,
    this.wordCount,
    this.userId,
    this.currentPostNumber,
    this.highestPostNumber,
    this.lastReadPostNumber,
    this.lastReadPostId,
    this.chunkSize,
    this.postStream,
    this.tags,
    this.categoryName,
    this.details,
    this.participantsCount,
    this.bookmarks,
    this.bookmarked,
  });
  



  factory TopicDetail.fromJson(Map<String, dynamic> json) =>
      _$TopicDetailFromJson(json);
  Map<String, dynamic> toJson() => _$TopicDetailToJson(this);
}

@JsonSerializable()
class PostStream {
  List<Post>? posts;
  List<int>? stream;

  PostStream({
    this.posts,
    this.stream,
  });

  factory PostStream.fromJson(Map<String, dynamic> json) =>
      _$PostStreamFromJson(json);
  Map<String, dynamic> toJson() => _$PostStreamToJson(this);
}

@JsonSerializable()
class Post {
  final int? id;
  final String? name;
  final String? username;
  final String? avatarTemplate;
  final String? createdAt;
  String? cooked;
  final int? postNumber;
  final int? postType;
  final int? postsCount;
  final String? updatedAt;
  final int? replyCount;
  final int? replyToPostNumber;
  final int? quoteCount;
  final int? incomingLinkCount;
  final int? reads;
  final int? readersCount;
  final double? score;
  final bool? yours;
  final int? topicId;
  final String? topicSlug;
  final String? displayUsername;
  final String? primaryGroupName;
  final String? flairName;
  final String? flairUrl;
  final String? flairBgColor;
  final String? flairColor;
  final int? flairGroupId;
  final List<dynamic>? badgesGranted;
  final int? version;
  final bool? canEdit;
  final bool? canDelete;
  final bool? canRecover;
  final bool? canSeeHiddenPost;
  final bool? canWiki;
  final String? userTitle;
  final bool? titleIsGroup;
  bool? bookmarked;
  final List<dynamic>? actionsSummary;
  final bool? moderator;
  final bool? admin;
  final bool? staff;
  final int? userId;
  final bool? hidden;
  final int? trustLevel;
  final String? deletedAt;
  final bool? userDeleted;
  final String? editReason;
  final bool? canViewEditHistory;
  final bool? wiki;
  final Map<String, dynamic>? userStatus;
  final List<dynamic>? mentionedUsers;
  final String? postUrl;
  final String? animatedAvatar;
  final String? userCakedate;
  final String? userBirthdate;
  final Map<String, dynamic>? event;
  final List<dynamic>? calendarDetails;
  final String? categoryExpertApprovedGroup;
  final bool? needsCategoryExpertApproval;
  final bool? canManageCategoryExpertPosts;
  final String? postFoldingStatus;
  final List<dynamic>? reactions;
  final Map<String, dynamic>? currentUserReaction;
  final int reactionUsersCount;
  final String? userSignature;
  final bool? canAcceptAnswer;
  final bool? canUnacceptAnswer;
  final bool? acceptedAnswer;
  final bool? topicAcceptedAnswer;
  final bool? canVote;
  final int? bookmarkAutoDeletePreference;
  final int? bookmarkId;
  final String? bookmarkableType;
  final String? bookmarkReminderAt;
  final String? bookmarkName;





  Post({
    this.id,
    this.name,
    this.username,
    this.avatarTemplate,
    this.createdAt,
    this.cooked,
    this.postNumber,
    this.postType,
    this.postsCount,
    this.updatedAt,
    this.replyCount,
    this.replyToPostNumber,
    this.quoteCount,
    this.incomingLinkCount,
    this.reads,
    this.readersCount,
    this.score,
    this.yours,
    this.topicId,
    this.topicSlug,
    this.displayUsername,
    this.primaryGroupName,
    this.flairName,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.flairGroupId,
    this.badgesGranted,
    this.version,
    this.canEdit,
    this.canDelete,
    this.canRecover,
    this.canSeeHiddenPost,
    this.canWiki,
    this.userTitle,
    this.titleIsGroup,
    this.bookmarked,
    this.actionsSummary,
    this.moderator,
    this.admin,
    this.staff,
    this.userId,
    this.hidden,
    this.trustLevel,
    this.deletedAt,
    this.userDeleted,
    this.editReason,
    this.canViewEditHistory,
    this.wiki,
    this.userStatus,
    this.mentionedUsers,
    this.postUrl,
    this.animatedAvatar,
    this.userCakedate,
    this.userBirthdate,
    this.event,
    this.calendarDetails,
    this.categoryExpertApprovedGroup,
    this.needsCategoryExpertApproval,
    this.canManageCategoryExpertPosts,
    this.postFoldingStatus,
    this.reactions,
    this.currentUserReaction,
    this.reactionUsersCount = 0,
    this.userSignature,
    this.canAcceptAnswer,
    this.canUnacceptAnswer,
    this.acceptedAnswer,
    this.topicAcceptedAnswer,
    this.canVote,
    this.bookmarkAutoDeletePreference,
    this.bookmarkId,
    this.bookmarkableType,
    this.bookmarkReminderAt,
    this.bookmarkName,
  });


  String getAvatarUrl() {
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll("{size}", "62")}';
  }

  bool isWebMaster() {
    return userId == 1;
  }

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int?,
    name: json['name'] as String?,
    username: json['username'] as String?,
    avatarTemplate: json['avatar_template'] as String?,
    createdAt: json['created_at'] as String?,
    cooked: json['cooked'] as String?,
    postNumber: json['post_number'] as int?,
    postType: json['post_type'] as int?,
    postsCount: json['posts_count'] as int?,
    updatedAt: json['updated_at'] as String?,
    replyCount: json['reply_count'] as int?,
    replyToPostNumber: json['reply_to_post_number'] as int?,
    quoteCount: json['quote_count'] as int?,
    incomingLinkCount: json['incoming_link_count'] as int?,
    reads: json['reads'] as int?,
    readersCount: json['readers_count'] as int?,
    score: (json['score'] as num?)?.toDouble(),
    yours: json['yours'] as bool?,
    topicId: json['topic_id'] as int?,
    topicSlug: json['topic_slug'] as String?,
    displayUsername: json['display_username'] as String?,
    primaryGroupName: json['primary_group_name'] as String?,
    flairName: json['flair_name'] as String?,
    flairUrl: json['flair_url'] as String?,
    flairBgColor: json['flair_bg_color'] as String?,
    flairColor: json['flair_color'] as String?,
    flairGroupId: json['flair_group_id'] as int?,
    badgesGranted: json['badges_granted'] as List<dynamic>?,
    version: json['version'] as int?,
    canEdit: json['can_edit'] as bool?,
    canDelete: json['can_delete'] as bool?,
    canRecover: json['can_recover'] as bool?,
    canSeeHiddenPost: json['can_see_hidden_post'] as bool?,
    canWiki: json['can_wiki'] as bool?,
    userTitle: json['user_title'] as String?,
    titleIsGroup: json['title_is_group'] as bool?,
    bookmarked: json['bookmarked'] as bool?,
    actionsSummary: json['actions_summary'] as List<dynamic>?,
    moderator: json['moderator'] as bool?,
    admin: json['admin'] as bool?,
    staff: json['staff'] as bool?,
    userId: json['user_id'] as int?,
    hidden: json['hidden'] as bool?,
    trustLevel: json['trust_level'] as int?,
    deletedAt: json['deleted_at'] as String?,
    userDeleted: json['user_deleted'] as bool?,
    editReason: json['edit_reason'] as String?,
    canViewEditHistory: json['can_view_edit_history'] as bool?,
    wiki: json['wiki'] as bool?,
    userStatus: json['user_status'] as Map<String, dynamic>?,
    mentionedUsers: json['mentioned_users'] as List<dynamic>?,
    postUrl: json['post_url'] as String?,
    animatedAvatar: json['animated_avatar'] as String?,
    userCakedate: json['user_cakedate'] as String?,
    userBirthdate: json['user_birthdate'] as String?,
    event: json['event'] as Map<String, dynamic>?,
    calendarDetails: json['calendar_details'] as List<dynamic>?,
    categoryExpertApprovedGroup: json['category_expert_approved_group'] as String?,
    needsCategoryExpertApproval: json['needs_category_expert_approval'] as bool?,
    canManageCategoryExpertPosts: json['can_manage_category_expert_posts'] as bool?,
    postFoldingStatus: json['post_folding_status'] as String?,
    reactions: json['reactions'] as List<dynamic>?,
    currentUserReaction: json['current_user_reaction'] as Map<String, dynamic>?,
    reactionUsersCount: (json['reaction_users_count'] as num?)?.toInt() ?? 0,
    userSignature: json['user_signature'] as String?,
    canAcceptAnswer: json['can_accept_answer'] as bool?,
    canUnacceptAnswer: json['can_unaccept_answer'] as bool?,
    acceptedAnswer: json['accepted_answer'] as bool?,
    topicAcceptedAnswer: json['topic_accepted_answer'] as bool?,
    canVote: json['can_vote'] as bool?,
    bookmarkAutoDeletePreference: json['bookmark_auto_delete_preference'] as int?,
    bookmarkId: json['bookmark_id'] as int?,
    bookmarkableType: json['bookmarkable_type'] as String?,
    bookmarkReminderAt: json['bookmark_reminder_at'] as String?,
    bookmarkName: json['bookmark_name'] as String?,
  );


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'user_id': userId,
      'avatar_template': avatarTemplate,
      'created_at': createdAt,
      'cooked': cooked,
      'post_number': postNumber,
      'post_type': postType,
      'updated_at': updatedAt,
      'reply_count': replyCount,
      'quote_count': quoteCount,
      'incoming_link_count': incomingLinkCount,
      'reads': reads,
      'score': score,
      'yours': yours,
      'topic_id': topicId,
      'topic_slug': topicSlug,
      'display_username': displayUsername,
      'primary_group_name': primaryGroupName,
      'hidden': hidden,
      'trust_level': trustLevel,
      'user_title': userTitle,
      'bookmarked': bookmarked,
      'actions_summary': actionsSummary?.map((x) => x.toJson()).toList(),
      'reply_to_post_number': replyToPostNumber,
      'reaction_users_count': reactionUsersCount,
      'posts_count': postsCount,
      'readers_count': readersCount,
      'moderator': moderator,
      'bookmark_auto_delete_preference': bookmarkAutoDeletePreference,
      'bookmark_id': bookmarkId,
      'bookmarkable_type': bookmarkableType,
      'bookmark_reminder_at': bookmarkReminderAt,
    };
  }
}


@JsonSerializable()
class ActionSummary {
  final int id;
  final int? count;
  final bool? hidden;
  @JsonKey(name: 'can_act')
  final bool? canAct;

  ActionSummary({
    required this.id,
    this.count,
    this.hidden,
    this.canAct,
  });

  factory ActionSummary.fromJson(Map<String, dynamic> json) =>
      _$ActionSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ActionSummaryToJson(this);
}

@JsonSerializable()
class Detail {
  @JsonKey(name: 'created_by')
  final CreateBy? createdBy;


  Detail({
    this.createdBy,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => _$DetailFromJson(json);
  Map<String, dynamic> toJson() => _$DetailToJson(this);
}

@JsonSerializable()
class CreateBy {
  final int? id;
  final String? name;
  final String? username;
  @JsonKey(name: 'avatar_template')
  final String? avatarTemplate;
  @JsonKey(name: 'animated_avatar')
  final String? animatedAvatar;

  CreateBy({
    this.id,
    this.name,
    this.username,
    this.avatarTemplate,
    this.animatedAvatar,
  });

    String getAvatarUrl() {
    return '${HttpConfig.baseUrl}${avatarTemplate!.replaceAll("{size}", "62")}';
  }

  bool isWebMaster() {
    return id == 1;
  }

  factory CreateBy.fromJson(Map<String, dynamic> json) =>
      _$CreateByFromJson(json);
  Map<String, dynamic> toJson() => _$CreateByToJson(this);
}


@JsonSerializable()
class Bookmarks {
  @JsonKey(name: 'auto_delete_preference')
  final int? autoDeletePreference;
  @JsonKey(name: 'bookmarkable_id')
  final int? bookmarkableId;
  @JsonKey(name: 'bookmarkable_type')
  final String? bookmarkableType;
  final int? id;
  final String? name;
  @JsonKey(name: 'reminder_at')
  final String? reminderAt;



  Bookmarks(this.id, this.name, this.reminderAt, 
     this.autoDeletePreference,
     this.bookmarkableId,
     this.bookmarkableType,
  );

  factory Bookmarks.fromJson(Map<String, dynamic> json) => _$BookmarksFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarksToJson(this);
}