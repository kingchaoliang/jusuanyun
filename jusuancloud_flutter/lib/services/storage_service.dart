import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/web_tab.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const String _tabsKey = 'web_tabs';
  static const String _currentTabKey = 'current_tab_index';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 保存标签页列表
  static Future<void> saveTabs(List<WebTab> tabs) async {
    final List<Map<String, dynamic>> tabsJson = 
        tabs.map((tab) => tab.toJson()).toList();
    await _prefs?.setString(_tabsKey, jsonEncode(tabsJson));
  }

  // 加载标签页列表
  static List<WebTab> loadTabs() {
    final String? tabsJson = _prefs?.getString(_tabsKey);
    if (tabsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(tabsJson);
    return decoded.map((json) => WebTab.fromJson(json)).toList();
  }

  // 保存当前标签页索引
  static Future<void> saveCurrentTabIndex(int index) async {
    await _prefs?.setInt(_currentTabKey, index);
  }

  // 加载当前标签页索引
  static int loadCurrentTabIndex() {
    return _prefs?.getInt(_currentTabKey) ?? 0;
  }

  // 清除所有数据
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // 保存特定标签的自动填充信息
  static Future<void> saveAutoFillCredentials(
      String tabId, String username, String password) async {
    await _prefs?.setString('autofill_username_$tabId', username);
    await _prefs?.setString('autofill_password_$tabId', password);
  }

  // 获取特定标签的自动填充信息
  static Map<String, String> getAutoFillCredentials(String tabId) {
    final username = _prefs?.getString('autofill_username_$tabId') ?? '';
    final password = _prefs?.getString('autofill_password_$tabId') ?? '';
    return {'username': username, 'password': password};
  }
}