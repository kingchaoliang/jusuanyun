import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/web_tab.dart';
import '../services/storage_service.dart';
import 'tech_theme.dart';

class WebViewContainer extends StatefulWidget {
  final WebTab tab;
  final Function(String) onTitleChanged;
  final Function(String) onUrlChanged;

  const WebViewContainer({
    Key? key,
    required this.tab,
    required this.onTitleChanged,
    required this.onUrlChanged,
  }) : super(key: key);

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late WebViewController controller;
  bool isLoading = true;
  int loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              loadingProgress = 0;
            });
            widget.onUrlChanged(url);
          },
          onProgress: (int progress) {
            setState(() {
              loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            
            // 页面加载完成后执行优化脚本
            _optimizeWebPageDisplay();
            _autoFillCredentials();
            _updatePageTitle();
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.tab.url));
  }

  Future<void> _optimizeWebPageDisplay() async {
    // 隐藏导航元素和优化显示的JavaScript代码
    const String optimizeScript = '''
      // 隐藏导航栏相关元素
      function hideNavigationElements() {
        const elementsToHide = [
          'nav', '.nav', '#nav', '.navigation', '.navbar',
          '.header', '#header', '.top-bar', '.menu-bar',
          '.breadcrumb', '.breadcrumbs'
        ];
        
        elementsToHide.forEach(selector => {
          const elements = document.querySelectorAll(selector);
          elements.forEach(el => {
            if (el && el.style) {
              el.style.display = 'none';
            }
          });
        });
      }
      
      // 优化移动端显示
      function optimizeMobileDisplay() {
        const viewport = document.querySelector('meta[name="viewport"]');
        if (viewport) {
          viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
        } else {
          const newViewport = document.createElement('meta');
          newViewport.name = 'viewport';
          newViewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
          document.head.appendChild(newViewport);
        }
        
        // 禁用滚动条
        document.body.style.overflow = 'hidden';
        document.documentElement.style.overflow = 'hidden';
      }
      
      hideNavigationElements();
      optimizeMobileDisplay();
    ''';

    try {
      await controller.runJavaScript(optimizeScript);
    } catch (e) {
      print('执行优化脚本失败: $e');
    }
  }

  Future<void> _autoFillCredentials() async {
    // 获取保存的自动填充信息
    final credentials = StorageService.getAutoFillCredentials(widget.tab.id);
    if (credentials['username']?.isEmpty ?? true) return;

    // 自动填充JavaScript代码
    final String autoFillScript = '''
      function autoFillCredentials() {
        const username = "${credentials['username']}";
        const password = "${credentials['password']}";
        
        console.log('开始自动填充凭据...');
        
        // 查找用户名输入框（优先级：number > text > email等）
        const usernameSelectors = [
          'input[type="number"]',
          'input[type="text"]',
          'input[type="email"]',
          'input[name*="user"]',
          'input[name*="account"]',
          'input[name*="login"]',
          'input[id*="user"]',
          'input[id*="account"]',
          'input[placeholder*="用户"]',
          'input[placeholder*="账号"]',
          'input[placeholder*="手机"]',
          'input[placeholder*="邮箱"]'
        ];
        
        // 查找密码输入框
        const passwordSelectors = [
          'input[type="password"]'
        ];
        
        let usernameField = null;
        let passwordField = null;
        
        // 查找用户名字段
        for (const selector of usernameSelectors) {
          usernameField = document.querySelector(selector);
          if (usernameField) {
            console.log('找到用户名输入框:', selector);
            break;
          }
        }
        
        // 查找密码字段
        passwordField = document.querySelector(passwordSelectors[0]);
        
        if (usernameField && username) {
          usernameField.focus();
          usernameField.value = username;
          usernameField.dispatchEvent(new Event('input', { bubbles: true }));
          usernameField.dispatchEvent(new Event('change', { bubbles: true }));
          usernameField.blur();
          console.log('用户名已填充');
        }
        
        if (passwordField && password) {
          passwordField.focus();
          passwordField.value = password;
          passwordField.dispatchEvent(new Event('input', { bubbles: true }));
          passwordField.dispatchEvent(new Event('change', { bubbles: true }));
          passwordField.blur();
          console.log('密码已填充');
        }
        
        // 自动点击登录按钮
        setTimeout(() => {
          const loginButtonSelectors = [
            'uni-button.mt-12.fng-btn-common-skin',
            'button:contains("立即登录")',
            'button:contains("登录")',
            'input[type="submit"]',
            '.login-btn',
            '#login-btn',
            '.submit-btn'
          ];
          
          for (const selector of loginButtonSelectors) {
            const button = document.querySelector(selector);
            if (button) {
              console.log('找到登录按钮，自动点击');
              button.click();
              break;
            }
          }
        }, 1000);
      }
      
      // 延迟执行，确保页面完全加载
      setTimeout(autoFillCredentials, 1500);
    ''';

    try {
      await controller.runJavaScript(autoFillScript);
    } catch (e) {
      print('执行自动填充脚本失败: $e');
    }
  }

  Future<void> _updatePageTitle() async {
    try {
      final title = await controller.getTitle();
      if (title != null && title.isNotEmpty) {
        widget.onTitleChanged(title);
      }
    } catch (e) {
      print('获取页面标题失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // WebView
        WebViewWidget(controller: controller),
        
        // 加载进度条
        if (isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: TechTheme.primaryGradient,
              ),
              child: LinearProgressIndicator(
                value: loadingProgress / 100.0,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
              ),
            ),
          ),
        
        // 加载指示器
        if (isLoading)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryBlue),
                ),
                SizedBox(height: 16),
                Text(
                  '正在加载...',
                  style: TextStyle(
                    color: TechTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}