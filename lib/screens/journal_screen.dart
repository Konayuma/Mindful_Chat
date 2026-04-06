import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/bookmark_service.dart';
import '../models/bookmark.dart';
import '../widgets/empty_state_widget.dart';

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPrivate;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPrivate = true,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isPrivate: json['is_private'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
      'is_private': isPrivate,
    };
  }
}

/// Journal/Notes Screen
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final supabase = SupabaseService.client;
      final response = await supabase
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final entries = (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();

      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading journal entries: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createEntry() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const JournalEditorScreen(),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _editEntry(JournalEntry entry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(entry: entry),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Delete "${entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final supabase = SupabaseService.client;
        await supabase.from('journal_entries').delete().eq('id', entry.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted')),
          );
          _loadEntries();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEntry,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? EmptyJournalState(onCreateEntry: _createEntry)
              : RefreshIndicator(
                  onRefresh: _loadEntries,
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            return _JournalGridCard(
                              entry: _entries[index],
                              onTap: () => _editEntry(_entries[index]),
                              onDelete: () => _deleteEntry(_entries[index]),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            return _JournalListCard(
                              entry: _entries[index],
                              onTap: () => _editEntry(_entries[index]),
                              onDelete: () => _deleteEntry(_entries[index]),
                            );
                          },
                        ),
                ),
    );
  }
}

class _JournalListCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalListCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
                ),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: entry.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _formatDate(entry.createdAt),
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
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _JournalGridCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalGridCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  entry.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(entry.createdAt),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Journal Editor Screen
class JournalEditorScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalEditorScreen({super.key, this.entry});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _bookmarkService = BookmarkService();
  bool _isBookmarked = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _checkBookmarkStatus();
    }
  }

  Future<void> _checkBookmarkStatus() async {
    if (widget.entry != null) {
      final bookmarked = await _bookmarkService.isBookmarked(
        type: BookmarkType.journal,
        itemId: widget.entry!.id,
      );
      if (mounted) {
        setState(() {
          _isBookmarked = bookmarked;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = SupabaseAuthService.instance.currentUserId;
      if (userId == null) throw Exception('Not authenticated');

      final supabase = SupabaseService.client;
      
      if (widget.entry == null) {
        // Create new entry
        await supabase.from('journal_entries').insert({
          'user_id': userId,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
        });
      } else {
        // Update existing entry
        await supabase.from('journal_entries').update({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
        }).eq('id', widget.entry!.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          if (widget.entry != null)
            IconButton(
              icon: Icon(_isBookmarked ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                if (widget.entry != null) {
                  await _bookmarkService.toggleBookmark(
                    type: BookmarkType.journal,
                    itemId: widget.entry!.id,
                    payload: {
                      'id': widget.entry!.id,
                      'title': widget.entry!.title,
                      'content': widget.entry!.content,
                      'tags': widget.entry!.tags,
                      'timestamp': widget.entry!.createdAt.toIso8601String(),
                    },
                  );
                  _checkBookmarkStatus();
                }
              },
            ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Entry title...',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
