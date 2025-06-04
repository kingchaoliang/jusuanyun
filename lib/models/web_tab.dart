class WebTab {
  final String id;
  String title;
  String url;
  String iconUrl;
  bool isLoading;
  String? sessionId; // 用于独立存储

  WebTab({
    required this.id,
    required this.title,
    required this.url,
    this.iconUrl = '',
    this.isLoading = false,
    this.sessionId,
  });

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'iconUrl': iconUrl,
      'isLoading': isLoading,
      'sessionId': sessionId,
    };
  }

  // 从JSON创建
  factory WebTab.fromJson(Map<String, dynamic> json) {
    return WebTab(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      iconUrl: json['iconUrl'] ?? '',
      isLoading: json['isLoading'] ?? false,
      sessionId: json['sessionId'],
    );
  }

  // 复制并修改
  WebTab copyWith({
    String? title,
    String? url,
    String? iconUrl,
    bool? isLoading,
    String? sessionId,
  }) {
    return WebTab(
      id: id,
      title: title ?? this.title,
      url: url ?? this.url,
      iconUrl: iconUrl ?? this.iconUrl,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}