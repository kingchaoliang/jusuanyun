import 'package:flutter/material.dart';
import '../models/web_tab.dart';
import 'tech_theme.dart';

class TabBarWidget extends StatelessWidget {
  final List<WebTab> tabs;
  final int currentIndex;
  final Function(int) onTabSelected;
  final Function(int) onTabClosed;
  final VoidCallback onNewTab;
  final VoidCallback onSearchPressed;

  const TabBarWidget({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: TechTheme.cardGradient,
        border: Border(
          bottom: BorderSide(color: TechTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 搜索按钮
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: onSearchPressed,
              child: Container(
                width: 40,
                height: 40,
                decoration: TechTheme.buttonDecoration,
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // 标签页列表
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = index == currentIndex;
                
                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? TechTheme.primaryGradient 
                          : TechTheme.cardGradient,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? TechTheme.primaryBlue 
                            : TechTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 标签内容
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tab.title.length > 15 
                                    ? '${tab.title.substring(0, 15)}...'
                                    : tab.title,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : TechTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDisplayUrl(tab.url),
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white70 
                                      : TechTheme.textSecondary,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // 关闭按钮
                        if (tabs.length > 1)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => onTabClosed(index),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 新建标签按钮
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: onNewTab,
              child: Container(
                width: 40,
                height: 40,
                decoration: TechTheme.buttonDecoration,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url.length > 20 ? '${url.substring(0, 20)}...' : url;
    }
  }
}