import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/llm_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';
import 'welcome_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _filteredConversations = [];
  String? _currentConversationId;
  final List<String> _openingMessages = [
    "Hello! I'm your mental health companion.",
    "Welcome! Let's talk about mental health.",
    "Hi there! Your wellbeing matters.",
    "Greetings! Let's focus on your wellness.",
    "Hello! Taking care of your mind is important.",
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _isFirstQuery = true;
  bool _isConnected = false;
  bool _isCheckingConnection = false;
  bool _showBeginChatScreen = true;
  int _currentMessageIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasShownToast = false;
  LLMModel _selectedModel = LLMModel.mindfulCompanion;
  Timer? _debounceTimer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
    _currentMessageIndex = DateTime.now().millisecondsSinceEpoch % _openingMessages.length;
    
    // Initialize pulse animation for brain icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Add search controller listener
    _searchController.addListener(() {
      _filterConversations(_searchController.text);
    });
  }

  /// Initialize async operations off the main thread
  Future<void> _initializeAsync() async {
    // Defer heavy operations
    Future.microtask(() async {
      await _checkServerConnection();
      _loadConversations();
      
      // Show toast after frame is rendered
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_showBeginChatScreen && !_hasShownToast) {
            _showFirstQueryToast();
            _hasShownToast = true;
          }
        });
      }
    });
  }

  /// Load user's conversations from database
  void _loadConversations() {
    try {
      final user = SupabaseAuthService.instance.currentUser;
      if (user == null) {
        print('⚠️ No user logged in, cannot load conversations');
        return;
      }

      print('📥 Loading conversations for user: ${user.id}');
      
      SupabaseDatabaseService.instance.getUserConversations(user.id).listen(
        (conversations) {
          print('✅ Loaded ${conversations.length} conversations');
          if (mounted) {
            setState(() {
              _conversations = conversations;
              _filteredConversations = _conversations;
            });
          }
        },
        onError: (error) {
          print('❌ Error loading conversations: $error');
        },
      );
    } catch (e) {
      print('❌ Error setting up conversation stream: $e');
    }
  }

  /// Filter conversations based on search query
  void _filterConversations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredConversations = _conversations;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredConversations = _conversations.where((conversation) {
        final title = (conversation['title'] as String? ?? '').toLowerCase();
        return title.contains(lowercaseQuery);
      }).toList();
    });
  }

  /// Load messages for a specific conversation
  Future<void> _loadConversationMessages(String conversationId, String title) async {
    try {
      print('📥 Loading messages for conversation: $conversationId');
      
      // Show loading state
      setState(() {
        _isLoading = true;
        _showBeginChatScreen = false;
        _currentConversationId = conversationId;
        _messages.clear();
      });

      // Fetch messages from database using stream (get first snapshot)
      final messagesStream = SupabaseDatabaseService.instance
          .getConversationMessages(conversationId);
      
      // Get first batch of messages
      final messages = await messagesStream.first;

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages.map((msg) {
            return ChatMessage(
              text: msg['content'] as String,
              isUser: msg['is_user_message'] as bool,
              timestamp: DateTime.parse(msg['timestamp'] as String),
            );
          }).toList());
          _isLoading = false;
        });

        print('✅ Loaded ${_messages.length} messages');
        
        // Scroll to bottom after messages loaded
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded $title'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $e'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _checkServerConnection() async {
    setState(() => _isCheckingConnection = true);
    
    try {
      final health = await ApiService.checkHealth();
      setState(() {
        _isConnected = health['status'] == 'healthy';
        _isCheckingConnection = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isCheckingConnection = false;
      });
    }
  }

  /// Sanitize text by removing markdown formatting (optimized)
  Future<String> _sanitizeTextAsync(String text) async {
    // Run text sanitization off the main thread
    return Future.microtask(() => _performSanitization(text));
  }

  /// Synchronous sanitization (for short text)
  String _sanitizeText(String text) {
    return _performSanitization(text);
  }

  /// Actual sanitization logic
  String _performSanitization(String text) {
    print('🔧 Sanitizing text (length: ${text.length})');
    print('📝 Original text: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
    
    String sanitized = text;
    
    // Remove bold markdown (**text** or __text__) - must come before single asterisk/underscore
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (match) => match.group(1) ?? '',
    );
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'__(.+?)__'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove italic markdown (*text* or _text_) - comes after bold removal
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)'),
      (match) => match.group(1) ?? '',
    );
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(?<!_)_(?!_)(.+?)(?<!_)_(?!_)'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove strikethrough markdown (~~text~~)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'~~(.+?)~~'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove inline code markdown (`text`)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'`([^`]+?)`'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove code blocks (```text```)
    sanitized = sanitized.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Remove headers (# ## ### etc)
    sanitized = sanitized.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remove bullet points and list markers
    sanitized = sanitized.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ');
    sanitized = sanitized.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
    
    // Remove links [text](url) - keep only text
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\[([^\]]+?)\]\([^\)]+?\)'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove images ![alt](url)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'!\[([^\]]*?)\]\([^\)]+?\)'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove blockquotes
    sanitized = sanitized.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    
    // Remove horizontal rules
    sanitized = sanitized.replaceAll(RegExp(r'^(-{3,}|\*{3,}|_{3,})$', multiLine: true), '');
    
    // Clean up excessive whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    sanitized = sanitized.trim();
    
    print('✅ Sanitized text: ${sanitized.substring(0, sanitized.length > 100 ? 100 : sanitized.length)}...');
    return sanitized;
  }

  /// Show copy dialog on long press
  void _showCopyDialog(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview of the text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Copy button
              ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (mounted) {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Message copied to clipboard",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: const Color(0xFF8FEC95),
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                icon: const Icon(Icons.copy, color: Colors.white),
                label: const Text(
                  'Copy Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FEC95),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build message context asynchronously to avoid blocking UI
  Future<List<Map<String, String>>> _buildMessageContext() async {
    return Future.microtask(() {
      final context = <Map<String, String>>[];
      final recentMessages = _messages.length > 6 
          ? _messages.sublist(_messages.length - 6) 
          : _messages;
      
      for (var msg in recentMessages) {
        context.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
      
      return context;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isProcessing) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Prevent multiple simultaneous sends
    setState(() => _isProcessing = true);

    // Create conversation if this is the first message
    if (_currentConversationId == null) {
      try {
        final user = SupabaseAuthService.instance.currentUser;
        if (user != null) {
          // Ensure user profile exists in database first
          await SupabaseDatabaseService.instance.ensureUserProfile(
            userId: user.id,
            email: user.email ?? '',
            displayName: user.userMetadata?['display_name'] as String?,
          );

          // Create the conversation
          final conversation = await SupabaseDatabaseService.instance.createConversation(
            userId: user.id,
            title: userMessage.length > 50 
                ? '${userMessage.substring(0, 47)}...' 
                : userMessage,
          );
          _currentConversationId = conversation['id'] as String;
          print('✅ Created conversation: $_currentConversationId with title: ${conversation['title']}');
        }
      } catch (e) {
        print('❌ Error creating conversation: $e');
      }
    }

    // Add user message immediately for responsive UI
    setState(() {
      _showBeginChatScreen = false;
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    // Save user message to database
    if (_currentConversationId != null) {
      try {
        await SupabaseDatabaseService.instance.addMessage(
          conversationId: _currentConversationId!,
          content: userMessage,
          isUserMessage: true,
        );
      } catch (e) {
        print('Error saving user message: $e');
      }
    }

    // Schedule scroll after frame to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Use LLM service to route to selected model
      LLMService.setModel(_selectedModel);
      
      // Build context asynchronously
      final context = await _buildMessageContext();
      
      // Get response from API
      final response = await LLMService.sendMessage(
        userMessage,
        context: context.isNotEmpty ? context : null,
      );

      // Sanitize response asynchronously for long text
      final sanitizedResponse = response.trim().length > 100
          ? await _sanitizeTextAsync(response.trim())
          : _performSanitization(response.trim());

      // Update UI after processing
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: sanitizedResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
          _isFirstQuery = false;
          _isProcessing = false;
        });

        // Save AI response to database
        if (_currentConversationId != null) {
          try {
            await SupabaseDatabaseService.instance.addMessage(
              conversationId: _currentConversationId!,
              content: sanitizedResponse,
              isUserMessage: false,
            );
          } catch (e) {
            print('Error saving AI message: $e');
          }
        }
      }
    } catch (e) {
      // Handle API error with user-friendly messages
      String errorMessage = _getErrorMessage(e.toString());
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
          _isProcessing = false;
        });

        // Show snackbar with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () {
                _messageController.text = userMessage;
                _sendMessage();
              },
            ),
          ),
        );
      }
    }

    _scrollToBottom();
  }

  String _getErrorMessage(String error) {
    if (error.contains('No internet') || error.contains('SocketException')) {
      return "I'm having trouble connecting. Please check your internet connection and try again.";
    } else if (error.contains('timeout') || error.contains('starting up')) {
      return "The server is starting up. This can take 30-60 seconds on the first request. Please try again in a moment.";
    } else if (error.contains('Cannot reach server')) {
      return "I can't reach the server right now. Please check your internet connection or try again later.";
    } else {
      return "I'm sorry, I'm having trouble processing your request right now. Please try again later or consider reaching out to a mental health professional if you need immediate support.";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModelSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select AI Model',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which AI assistant you\'d like to chat with',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              ...LLMModel.values.map((model) {
                final isSelected = _selectedModel == model;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedModel = model;
                    });
                    Navigator.pop(context);
                    
                    // Show toast with model info
                    Fluttertoast.showToast(
                      msg: '${model.displayName} selected',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          model == LLMModel.mindfulCompanion
                              ? Icons.psychology
                              : Icons.auto_awesome,
                          color: isSelected 
                              ? const Color(0xFF8FEC95)
                              : (isDark ? Colors.grey[600] : Colors.grey),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? const Color(0xFF8FEC95)
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                model.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected 
                                      ? const Color(0xFF8FEC95).withValues(alpha: 0.8)
                                      : (isDark ? Colors.grey[400] : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF8FEC95),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
      drawer: _buildSideNavDrawer(),
      body: Row(
        children: [
          // Left sidebar (desktop view)
          if (MediaQuery.of(context).size.width > 768)
            _buildLeftSidebar(),
          // Main chat area
          Expanded(
            child: Column(
              children: [
                _buildTopNavBar(),
                Expanded(
                  child: _messages.isEmpty && _showBeginChatScreen
                      ? _buildBeginChatScreen()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length && _isLoading) {
                              return _buildTypingIndicator();
                            }
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: Container(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Left: Sidebar toggle (mobile)
            if (MediaQuery.of(context).size.width <= 768)
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/sidebar.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            const SizedBox(width: 8),
            // Center: Title with model selector dropdown
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Model selector dropdown
                GestureDetector(
                  onTap: () => _showModelSelector(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedModel.displayName,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCheckingConnection 
                          ? Icons.cloud_queue 
                          : (_isConnected ? Icons.cloud_done : Icons.cloud_off),
                      color: _isCheckingConnection 
                          ? Colors.orange 
                          : (_isConnected ? Colors.green : Colors.red),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCheckingConnection 
                          ? 'Checking...' 
                          : (_isConnected ? 'Connected' : 'Offline'),
                      style: TextStyle(
                        fontSize: 11,
                        color: _isCheckingConnection 
                            ? Colors.orange 
                            : (_isConnected ? Colors.green : Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: New chat button without stroke
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/NewChat.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: _startNewChat,
            tooltip: 'New Chat',
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildLeftSidebar() {
    final user = SupabaseAuthService.instance.currentUser;
    final email = user?.email ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 280,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[500] : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          // New Chat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startNewChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF8FEC95) : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/images/NewChat.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.black : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                label: const Text('New Chat'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recent chats section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Recent Chats',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredConversations.isEmpty
                ? Center(
                    child: Text(
                      _conversations.isEmpty 
                          ? 'No conversations yet' 
                          : 'No matching conversations',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _filteredConversations[index];
                      final title = conversation['title'] as String? ?? 'Untitled Chat';
                      final conversationId = conversation['id'] as String;
                      
                      return ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.black87,
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        dense: true,
                        onTap: () {
                          _loadConversationMessages(conversationId, title);
                        },
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          // User profile section (clickable)
          InkWell(
            onTap: () => _showProfileMenu(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.split('@')[0],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavDrawer() {
    final user = SupabaseAuthService.instance.currentUser;
    final email = user?.email ?? 'Guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: Container(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            // Search bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey[500] : Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // New Chat Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewChat();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF8FEC95) : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/images/NewChat.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.black : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text('New Chat'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Recent chats section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Recent Chats',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredConversations.isEmpty
                  ? Center(
                      child: Text(
                        _conversations.isEmpty 
                            ? 'No conversations yet' 
                            : 'No matching conversations',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _filteredConversations[index];
                        final title = conversation['title'] as String? ?? 'Untitled Chat';
                        final conversationId = conversation['id'] as String;
                        
                        return ListTile(
                          leading: Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: isDark ? Colors.grey[400] : Colors.black87,
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          dense: true,
                          onTap: () {
                            Navigator.pop(context);
                            _loadConversationMessages(conversationId, title);
                          },
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            // User profile section (clickable)
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _showProfileMenu(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email.split('@')[0],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _handleSignOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _showBeginChatScreen = true;
      _isFirstQuery = true;
      _hasShownToast = false;
      _currentConversationId = null; // Clear current conversation to start fresh
      // Cycle to next message
      _currentMessageIndex = (_currentMessageIndex + 1) % _openingMessages.length;
    });
    
    // Show toast for new chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownToast) {
        _showFirstQueryToast();
        _hasShownToast = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New chat started'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showFirstQueryToast() {
    Fluttertoast.showToast(
      msg: "Note: First question may take 30-60 seconds as the server starts up.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      textColor: Colors.orange.shade900,
      fontSize: 14.0,
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      try {
        await SupabaseAuthService.instance.signOut();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            ),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildBeginChatScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Official MENTAL.svg logo
            SvgPicture.asset(
              'assets/images/MENTAL.svg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 48),
            
            // Welcome message - no container, just flowing text
            Text(
              _openingMessages[_currentMessageIndex],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                height: 1.5,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF8FEC95),
              child: const Icon(
                Icons.psychology,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showCopyDialog(message.text),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser 
                      ? (isDark ? const Color(0xFF8FEC95) : Colors.black)
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser 
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: message.isUser 
                            ? (isDark 
                                ? Colors.black.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.7))
                            : (isDark
                                ? Colors.grey.withValues(alpha: 0.6)
                                : Colors.grey.withValues(alpha: 0.8)),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated pulsing brain icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF8FEC95),
                  child: const Icon(
                    Icons.psychology,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(0),
                      const SizedBox(width: 4),
                      _buildDot(1),
                      const SizedBox(width: 4),
                      _buildDot(2),
                    ],
                  ),
                  if (_isFirstQuery) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Processing your question...\nFirst query may take 30-60 seconds\n(Server is waking up)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Thinking...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Ask about mental health...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) {
                  // Debounce to prevent too many rapid updates
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    // Could add auto-save draft functionality here
                  });
                },
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF8FEC95) : Colors.black,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: Icon(
                Icons.send,
                color: _isLoading 
                    ? Colors.grey 
                    : (isDark ? Colors.black : Colors.white),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}