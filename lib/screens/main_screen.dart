import 'package:flutter/material.dart';
import '../models/web_tab.dart';
import '../services/storage_service.dart';
import '../widgets/web_view_container.dart';
import '../widgets/tab_bar_widget.dart';
import '../widgets/search_screen.dart';
import '../widgets/tech_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  List<WebTab> tabs = [];
  int currentTabIndex = 0;
  bool showSearch = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadTabs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadTabs() {
    final loadedTabs = StorageService.loadTabs();
    final loadedIndex = StorageService.loadCurrentTabIndex();
    
    setState(() {
      if (loadedTabs.isEmpty) {
        // 创建默认标签页
        tabs = [
          WebTab(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '新标签页',
            url: 'https://www.baidu.com',
            sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        ];
      } else {
        tabs = loadedTabs;
      }
      currentTabIndex = loadedIndex.clamp(0, tabs.length - 1);
    });
  }

  void _saveTabs() {
    StorageService.saveTabs(tabs);
    StorageService.saveCurrentTabIndex(currentTabIndex);
  }

  void _addNewTab() {
    final newTab = WebTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '新标签页',
      url: 'https://www.baidu.com',
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    
    setState(() {
      tabs.add(newTab);
      currentTabIndex = tabs.length - 1;
    });
    _saveTabs();
  }

  void _closeTab(int index) {
    if (tabs.length <= 1) return;
    
    setState(() {
      tabs.removeAt(index);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      } else if (currentTabIndex > index) {
        currentTabIndex--;
      }
    });
    _saveTabs();
  }

  void _switchToTab(int index) {
    setState(() {
      currentTabIndex = index;
    });
    _saveTabs();
  }

  void _updateTabInfo(String title, String url) {
    if (currentTabIndex < tabs.length) {
      setState(() {
        tabs[currentTabIndex] = tabs[currentTabIndex].copyWith(
          title: title,
          url: url,
        );
      });
      _saveTabs();
    }
  }

  void _toggleSearch() {
    setState(() {
      showSearch = !showSearch;
    });
    if (showSearch) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _navigateToUrl(String url) {
    setState(() {
      showSearch = false;
      if (currentTabIndex < tabs.length) {
        tabs[currentTabIndex] = tabs[currentTabIndex].copyWith(url: url);
      }
    });
    _animationController.reverse();
    _saveTabs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // 主WebView内容
            Column(
              children: [
                // 标签栏
                TabBarWidget(
                  tabs: tabs,
                  currentIndex: currentTabIndex,
                  onTabSelected: _switchToTab,
                  onTabClosed: _closeTab,
                  onNewTab: _addNewTab,
                  onSearchPressed: _toggleSearch,
                ),
                
                // WebView容器
                Expanded(
                  child: tabs.isNotEmpty
                      ? WebViewContainer(
                          tab: tabs[currentTabIndex],
                          onTitleChanged: (title) => _updateTabInfo(title, tabs[currentTabIndex].url),
                          onUrlChanged: (url) => _updateTabInfo(tabs[currentTabIndex].title, url),
                        )
                      : const Center(
                          child: Text(
                            '暂无标签页',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            
            // 搜索界面
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _animationController.value) * -MediaQuery.of(context).size.height),
                  child: showSearch
                      ? SearchScreen(
                          tabs: tabs,
                          onNavigate: _navigateToUrl,
                          onClose: _toggleSearch,
                          onEditTab: (index, title, url) {
                            setState(() {
                              tabs[index] = tabs[index].copyWith(title: title, url: url);
                            });
                            _saveTabs();
                          },
                          onDeleteTab: _closeTab,
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}