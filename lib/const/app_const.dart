import 'package:linux_do/net/http_config.dart';

class AppConst {
  /// L 站名称
  static const String siteName = 'LINUX DO';

  /// 我们的口号
  static const String slogan = '真诚、友善、团结、专业，\n共建你我引以为荣之社区。';

  /// 顶部信息
  static const String topInfo = '真诚、友善、团结、专业，共建你我引以为荣之社区。《常见问题解答》';

  /// 通用提示
  static const String commonTip = '提示';
  static const updateSuccess = '更新成功';

  /// 配置成功
  static const configSuccess = '配置成功';

  /// 配置失败
  static const configFailed = '配置失败';

  /// 更新失败
  static const updateFailed = '更新失败';

  /// 取消
  static const cancel = '取消';

  /// 确定
  static const confirm = '确定';

  /// 支持的语言
  static const supportedLanguages = ['en', 'zh'];

  /// 常见问题
  static const faq = 'faq';

  /// 抽屉菜单
  static const drawerMenu = _DrawerMenu();

  /// 各种状态的提示
  static const stateHint = _StateConst();

  /// 标识常量
  static final identifier = _Identifier();

  /// 登录页面相关
  static const login = _LoginConst();

  /// 设置相关
  static const settings = _Settings();

  /// 帖子相关
  static const posts = _Posts();

  /// 发帖相关
  static const createPost = _CreatePost();

  static const chat = _Chat();

  /// 分类主题相关
  static const categoryTopics = _CategoryTopics();

  /// 排行榜相关
  static const leaderboard = _Leaderboard();

  /// 群组相关
  static const group = _Group();

  /// 活动相关
  static const activity = _Activity();

  /// 生日相关
  static const _Birthday birthday = _Birthday();

  /// 用户相关
  static const user = _User();
}

/// 抽屉菜单文本
class _DrawerMenu {
  const _DrawerMenu();

  String get topics => '话题';
  String get myDrafts => '草稿';
  String get externalLinks => '外部链接';
  String get categories => '类别';
  String get tags => '标签';
  String get messages => '消息';
  String get channels => '频道';
  String get inbox => '收件箱';
  String get regularChannel => '常规频道';
  String get telegram => 'Telegram';
  String get telegramChannel => 'Channel';
  String get connect => 'Connect';
  String get status => 'Status';
  String get lottery => 'Lottery';

  // 类别
  String get devOptimization => '开发调优';
  String get docBuilding => '文档共建';
  String get notMine => '非我莫属';
  String get sailAway => '扬帆起航';
  String get benefits => '福利羊毛';
  String get operationFeedback => '运营反馈';
  String get resources => '资源荟萃';
  String get fleaMarket => '跳蚤市场';
  String get readingPoetry => '读书成诗';
  String get frontierNews => '前沿快讯';
  String get pickAndChoose => '摘七拾三';
  String get deepSea => '深海幽域';

  // 标签
  String get essentialPosts => '精华神帖';
  String get ai => '人工智能';
  String get announcements => '公告';
  String get qa => '快问快答';

  String get statusUrl => 'https://status.${HttpConfig.domain}';
  String get connectUrl => 'https://connect.${HttpConfig.domain}';
  String get lotteryUrl => 'https://lottery.${HttpConfig.domain}';
  String get channelUrl => 'https://t.me/linux_do_channel';
  String get jaTGUrl => 'https://t.me/ja_netfilter_group';
}

class _StateConst {
  const _StateConst();

  String get error => '出错啦~';
  String get empty => '暂无数据哦~';
}

/// 标识常量
class _Identifier {
  const _Identifier();

  String get token => 'token';
  String get userInfo => 'userInfo';
  String get theme => 'theme';
  String get language => 'language';
  String get isFirst => 'isFirst';
  String get username => 'username';
  String get name => 'name';
  String get userId => 'userId';
  String get isLogin => 'isLogin';
  String get csrfToken => 'csrfToken';
  String get clientId => 'clientId';

  String get themeColor => 'themeColor';
}

/// 登录页面文本
class _LoginConst {
  const _LoginConst();

  String get title => '登录';
  String get webTitle => '网页授权登录(仅支持账密)';
  String get greetingPhrase => '欢迎来到';
  String get accountHint => '请输入账号';
  String get passwordHint => '请输入密码';
  String get forgotPassword => '我忘记密码了';
  String get noAccount => '还没有账号？';
  String get register => '立即注册';
  String get agreement => '登录即代表同意';
  String get serviceAgreement => '服务协议';
  String get and => '和';
  String get privacyPolicy => '隐私政策';

  // 提示信息
  String get emptyUsername => '请输入账号';
  String get emptyPassword => '请输入密码';
  String get loginFailedTitle => '登录失败';
  String get loginFailedMessage => '请检查网络连接或稍后重试';
  String get networkError => '请检查网络连接或稍后重试';
  String get userInfoError => '用户信息获取失败';
  String get loginSuccessTitle => '登录成功';
  String get welcomeBack => '欢迎回来';
  String get notImplemented => '此功能暂未开发';
  String get registerTip => '请先前往${AppConst.siteName}站点注册';
}

/// 设置相关
class _Settings {
  const _Settings();

  String get title => '设置';
  String get accountAndProfile => '账号与个人资料';
  String get accountSettings => '账号设置';
  String get security => '安全设置';
  String get editProfile => '编辑个人资料';
  String get emailSettings => '邮箱设置';
  String get dataExport => '数据导出';
  String get notificationsAndPrivacy => '通知与隐私';
  String get notifications => '通知设置';
  String get tracking => '跟踪';
  String get doNotDisturb => '免打扰设置';
  String get anonymousMode => '匿名模式';
  String get appearance => '外观';
  String get darkMode => '深色模式';
  String get themeSystem => '跟随系统';
  String get themeLight => '浅色模式';
  String get themeDark => '深色模式';
  String get themeCustom => '自定义主题';
  String get helpAndSupport => '帮助与支持';
  String get about => '关于 ${AppConst.siteName}';
  String get faq => '常见问题';
  String get terms => '服务条款';
  String get privacy => '隐私政策';
  String get logout => '退出登录';
  String get logoutConfirmTitle => '确认退出';
  String get logoutConfirmMessage => '确定要退出登录吗？';
  String get cancel => '取消';
  String get confirm => '确定';
  String get status => '输入你的状态...';
  String get themeColor => '请选择主题颜色';
}

class _Posts {
  const _Posts();

  String get disturbSuccess => '设置免打扰成功';
  String get error => '设置失败,请重试~';
  String get reply => '回复';
  String get replyPlaceholder => "提问、回复请记得：真诚、友善、团结、专业，共建你我引以为荣之社区。";
  String get send => '发送';
  String get replySuccess => '回复成功';
  String get replyFailed => '回复失败';
  String get searchTopic => '搜索话题';
  String get copySuccess => '复制成功';
  String get deleteSuccess => '删除成功';
  String get deleteFailed => '删除失败';
  String get deletePost => '帖子已被作者删除';
  
  // 举报相关
  List<Map<String, String>> get reasons => [
    {
        'title': '偏离话题',
        'desc': '此帖子与标题和第一个帖子定义的当前讨论无关，可能应该移到其他地方。',
        'value': 'off_topic'
      },
      {
        'title': '不当言论',
        'desc': '这个帖子包含的内容会被一个有理性的人认为具有冒犯性、侮辱性、属于仇恨行为或违反我们的社区准则。',
        'value': 'off_topic'
      },
      {
        'title': '垃圾信息',
        'desc': '此帖子是广告或者蓄意破坏讨论。帖子没有价值或者与当前话题无关。',
        'value': 'inappropriate'
      },
      {
        'title': '违规推广',
        'desc': '我确认：此帖子系用户未遵守社区推广规则，进行违规推广。',
        'value': 'spam'
      },
      {
        'title': '非法',
        'desc': '此帖子需要工作人员注意，因为我认为其中包含非法内容。',
        'value': 'notify_moderators'
      },
      {
        'title': '其他内容',
        'desc': '由于上面未列出的另一个原因，此帖子需要管理人员注意。',
        'value': 'notify_moderators'
      },
    ];

  String get reportTitle => '举报内容';
  String get reportButton => '举报帖子';
  String get reportSuccess => '举报开发中';
  String get reportFailed => '举报失败';

  get reportHint => '让我们具体了解您关心的问题，并尽可能提供相关的链接和示例。';
}

/// 发帖相关常量
class _CreatePost {
  const _CreatePost();

  String get title => '发布新主题';
  String get preview => '预览';
  String get previewTitle => '预览主题';
  String get previewEmpty => '暂无预览内容';
  String get previewCategory => '分类';
  String get previewTags => '标签';
  String get dialogTitle => '创建新的话题';
  String get dialogContent => '为了更好的体验创建话题的功能，\n建议前往 Web 网站完成发布操作。';
  String get dialogConfirm => '去创建';
  String get dialogCancel => '取消';
  String get categoryHint => '选择分类';
  String get titleHint => '请输入标题';
  String get addImage => '添加图片';
  String get searchTag => '搜索标签';
  String get publish => '发布';
  String get draft => '保存草稿';
  String get titleRequired => '请输入标题';
  String get contentRequired => '请输入内容';
  String get categoryRequired => '请选择分类';
  String get publishSuccess => '发布成功';
  String get draftSuccess => '草稿保存成功';
  String get publishFailed => '发布失败';
  String get draftFailed => '草稿保存失败';
  String get selectCategory => '请选择分类';
  String get addTags => '添加标签';
  String get inputTips => '请输入内容';
  String get uploadFailed => '图片上传失败';
}

class _Chat {
  const _Chat();

  String get title => '私信';
  String get searchHint => '搜索';
  String get noMessages => '暂无消息';
  String get inputHint => '请输入消息';
}

class _CategoryTopics {
  const _CategoryTopics();

  String get groups => '群组';
  String get ranking => '排行榜';
  String get docs => '文档';
  String get activities => '社区活动';
  String get birthdays => '生日';
  String get myPosts => '我的帖子';
  String get myBookmarks => '我的书签';
  String get loading => '加载中...';
  String get noData => '暂无数据';
}

class _Birthday {
  const _Birthday();

  String get title => '生日';
  String get today => '今天';
  String get tomorrow => '明天';
  String get upcoming => '即将到来';
  String get all => '所有';
  String get noBirthdays => '暂无生日信息';
  String get loading => '加载中...';
  String get error => '获取生日数据失败';
  String get birthdayOn => '生日';
}

class _Activity {
  const _Activity();

  String get title => '社区活动';
  String get noEvents => '暂无活动';
  String get loading => '加载中...';
  String get error => '获取活动数据失败';
  String get startTime => '开始时间';
  String get endTime => '结束时间';
  String get viewDetail => '查看详情';
  String get today => '今天';
}

class _Leaderboard {
  const _Leaderboard();
  final String title = '排行榜';
  final String firstPlace = '第一名';
  final String secondPlace = '第二名';
  final String thirdPlace = '第三名';
  final String points = '积分';
  final String error = '获取排行榜数据失败';
  final String empty = '暂无排行榜数据';

  String get tips =>
      '参与社区活动，如访问、点赞和发帖，都会获得积分。您的积分每几分钟就会更新一次。保持活跃，积极帮助并支持其他人来提高自己的排名！';
  String get tipsTitle => '排行榜说明';
  String get tipsKnow => '知道了';
}

class _Group {
  const _Group();

  String get title => '群组';
  String get members => '成员';
  String get join => '加入';
  String get leave => '退出';
  String get joinSuccess => '加入成功';
  String get leaveSuccess => '退出成功';
  String get joinFailed => '加入失败';
  String get leaveFailed => '退出失败';
  String get noDescription => '暂无描述';
  String get publicGroup => '公开群组';
  String get privateGroup => '私密群组';
  String get loading => '加载中...';
  String get error => '获取群组数据失败';
  String get empty => '暂无群组数据';
  String get search => '搜索群组';
}

class _User {
  const _User();

  String get noDescription => '暂无简介';
  String get admin => '管理员';
  String get joinTime => '加入时间';
  String get postTime => '发布时间';
  String get points => '点数';
  String get follow => '关注';
  String get followers => '关注者';
  String get solutions => '解决方案';
  String get like => '认可';
  String get followUser => '关注';
  String get unfollowUser => '取消关注';
  String get message => '私信';
  String get chat => '聊天';
  String get failed => '失败，请稍后重试~';

  // 用户优点选项
  String get readingPoetry => '读书成诗';
  String get sevenThree => '掐七捏三';
  String get marketInsight => '跳蚤市场';
  String get communityBuilding => '文档共建';
  String get welfareSheep => '福利羊毛';
  String get devOps => '开发调优';
  String get frontierNews => '前沿快讯';
  String get startupNavigation => '扬帆起航';
  String get resourceSharing => '资源荟萃';
  String get nonMainstream => '非我莫属';
  
}
