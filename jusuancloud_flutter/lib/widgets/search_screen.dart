import 'package:flutter/material.dart';
import '../models/web_tab.dart';
import 'tech_theme.dart';

class SearchScreen extends StatefulWidget {
  final List<WebTab> tabs;
  final Function(String) onNavigate;
  final VoidCallback onClose;
  final Function(int, String, String) onEditTab;
  final Function(int) onDeleteTab;

  const SearchScreen({
    Key? key,
    required this.tabs,
    required this.onNavigate,
    required this.onClose,
    required this.onEditTab,
    required this.onDeleteTab,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<WebTab> _filteredTabs = [];

  @override
  void initState() {
    super.initState();
    _filteredTabs = widget.tabs;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTabs = widget.tabs;
      } else {
        _filteredTabs = widget.tabs.where((tab) {
          return tab.title.toLowerCase().contains(query.toLowerCase()) ||
              tab.url.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      String url = query;
      if (!query.startsWith('http://') && !query.startsWith('https://')) {
        if (query.contains('.')) {
          url = 'https://$query';
        } else {
          url = 'https://www.baidu.com/s?wd=${Uri.encodeComponent(query)}';
        }
      }
      widget.onNavigate(url);
    }
  }

  void _showEditDialog(int index) {
    final tab = widget.tabs[index];
    final titleController = TextEditingController(text: tab.title);
    final urlController = TextEditingController(text: tab.url);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TechTheme.cardBackground,
        title: const Text(
          '编辑标签',
          style: TechTheme.titleStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: TechTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: '标题',
                labelStyle: TextStyle(color: TechTheme.textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TechTheme.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              style: const TextStyle(color: TechTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'URL',
                labelStyle: TextStyle(color: TechTheme.textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TechTheme.primaryBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: TechTheme.textSecondary),
            ),
          ),
          Container(
            decoration: TechTheme.buttonDecoration,
            child: TextButton(
              onPressed: () {
                widget.onEditTab(index, titleController.text, urlController.text);
                Navigator.pop(context);
              },
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: TechTheme.cardGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: TechTheme.cardGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TechTheme.borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: TechTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: '搜索或输入网址...',
                          hintStyle: TextStyle(color: TechTheme.textSecondary),
                          prefixIcon: Icon(
                            Icons.search,
                            color: TechTheme.primaryBlue,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: TechTheme.buttonDecoration,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 标签页列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredTabs.length,
                itemBuilder: (context, index) {
                  final tab = _filteredTabs[index];
                  final originalIndex = widget.tabs.indexOf(tab);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: TechTheme.cardDecoration,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: TechTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.web,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tab.title,
                        style: TechTheme.titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        tab.url,
                        style: TechTheme.bodyStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 编辑按钮
                          GestureDetector(
                            onTap: () => _showEditDialog(originalIndex),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                gradient: TechTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: TechTheme.glowShadow,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          // 前往按钮
                          GestureDetector(
                            onTap: () => widget.onNavigate(tab.url),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    TechTheme.primaryGreen,
                                    TechTheme.primaryBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: TechTheme.primaryGreen.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
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
          ],
        ),
      ),
    );
  }
}