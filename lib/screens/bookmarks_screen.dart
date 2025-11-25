import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bookmark.dart';
import '../services/bookmark_service.dart';
import '../widgets/empty_state_widget.dart';

/// Bookmarks/Favorites Screen
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  final _bookmarkService = BookmarkService();
  late TabController _tabController;
  
  List<Bookmark> _allBookmarks = [];
  List<Bookmark> _filteredBookmarks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  BookmarkType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedFilter = null;
            break;
          case 1:
            _selectedFilter = BookmarkType.affirmation;
            break;
          case 2:
            _selectedFilter = BookmarkType.message;
            break;
          case 3:
            _selectedFilter = BookmarkType.journal;
            break;
        }
        _applyFilters();
      });
    }
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    final bookmarks = await _bookmarkService.getAllBookmarks();
    
    if (mounted) {
      setState(() {
        _allBookmarks = bookmarks;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = _allBookmarks;

    // Apply type filter
    if (_selectedFilter != null) {
      filtered = filtered.where((b) => b.type == _selectedFilter).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.displayTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.displayContent.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredBookmarks = filtered;
    });
  }

  Future<void> _deleteBookmark(Bookmark bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bookmark?'),
        content: Text('Remove "${bookmark.displayTitle}" from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _bookmarkService.deleteBookmark(bookmark.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
        _loadBookmarks();
      }
    }
  }

  Future<void> _copyToClipboard(Bookmark bookmark) async {
    await Clipboard.setData(
      ClipboardData(text: bookmark.displayContent),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📋 Copied to clipboard')),
      );
    }
  }

  Future<void> _share(Bookmark bookmark) async {
    await Share.share(
      '${bookmark.displayContent}\n\nShared from Mindful Chat',
      subject: bookmark.displayTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Affirmations'),
            Tab(text: 'Messages'),
            Tab(text: 'Journal'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search favorites...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookmarks.isEmpty
                    ? _searchQuery.isEmpty
                        ? const EmptyBookmarksState()
                        : EmptySearchState(searchQuery: _searchQuery)
                    : RefreshIndicator(
                        onRefresh: _loadBookmarks,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredBookmarks.length,
                          itemBuilder: (context, index) {
                            final bookmark = _filteredBookmarks[index];
                            return _BookmarkCard(
                              bookmark: bookmark,
                              onDelete: () => _deleteBookmark(bookmark),
                              onCopy: () => _copyToClipboard(bookmark),
                              onShare: () => _share(bookmark),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _BookmarkCard({
    required this.bookmark,
    required this.onDelete,
    required this.onCopy,
    required this.onShare,
  });

  IconData _getTypeIcon() {
    switch (bookmark.type) {
      case BookmarkType.affirmation:
        return Icons.format_quote;
      case BookmarkType.message:
        return Icons.chat_bubble_outline;
      case BookmarkType.journal:
        return Icons.book_outlined;
    }
  }

  Color _getTypeColor(BuildContext context) {
    switch (bookmark.type) {
      case BookmarkType.affirmation:
        return Colors.purple;
      case BookmarkType.message:
        return Theme.of(context).colorScheme.primary;
      case BookmarkType.journal:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getTypeColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to detail view based on type
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      size: 20,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bookmark.type.value.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Actions
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: onCopy,
                    tooltip: 'Copy',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.share, size: 18),
                    onPressed: onShare,
                    tooltip: 'Share',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.red,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content
              Text(
                bookmark.displayContent,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Text(
                _formatDate(bookmark.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
