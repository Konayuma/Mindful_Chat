import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<JournalEntry> _entries = [];
  MoodType? _selectedMood;
  bool _isWriting = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
    
    _loadEntries();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _loadEntries() {
    // TODO: Load entries from database
    setState(() {
      _entries = [
        JournalEntry(
          id: '1',
          title: 'Grateful Today',
          content: 'I am grateful for my family and the beautiful weather today. Sometimes we forget to appreciate the small things in life.',
          mood: MoodType.happy,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        JournalEntry(
          id: '2',
          title: 'Feeling Anxious',
          content: 'Work has been stressful lately. I need to remember to take breaks and breathe deeply when I feel overwhelmed.',
          mood: MoodType.anxious,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    });
  }

  void _toggleWritingMode() {
    setState(() {
      _isWriting = !_isWriting;
      if (_isWriting) {
        _fabController.forward();
      } else {
        _fabController.reverse();
        _clearForm();
      }
    });
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _selectedMood = null;
  }

  void _saveEntry() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your mood'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      mood: _selectedMood!,
      date: DateTime.now(),
    );

    setState(() {
      _entries.insert(0, newEntry);
    });

    _toggleWritingMode();
    
    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry saved successfully'),
        backgroundColor: Color(0xFF8FEC95),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Journal',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isWriting) _buildWritingInterface(isDark),
          Expanded(
            child: _entries.isEmpty ? _buildEmptyState(isDark) : _buildEntriesList(isDark),
          ),
        ],
      ),
      floatingActionButton: _isWriting ? null : _buildFloatingButton(),
    );
  }

  Widget _buildWritingInterface(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood selector
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodType.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? mood.color.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected ? Border.all(color: mood.color, width: 2) : null,
                      ),
                      child: Icon(
                        mood.icon,
                        color: mood.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? mood.color : (isDark ? Colors.grey[400] : Colors.black54),
                        fontFamily: 'Satoshi',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // Title input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Entry title...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey,
                fontFamily: 'Satoshi',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          // Content input
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey,
                fontFamily: 'Satoshi',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
            maxLines: 6,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleWritingMode,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.black54,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FEC95),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No journal entries yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing to track your thoughts and feelings',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontFamily: 'Satoshi',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildEntryCard(isDark, entry),
        );
      },
    );
  }

  Widget _buildEntryCard(bool isDark, JournalEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                entry.mood.icon,
                color: entry.mood.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                entry.mood.label,
                style: TextStyle(
                  fontSize: 14,
                  color: entry.mood.color,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Satoshi',
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(entry.date),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontFamily: 'Satoshi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'Satoshi',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.black87,
              fontFamily: 'Satoshi',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Read more',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontFamily: 'Satoshi',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton(
            onPressed: _toggleWritingMode,
            backgroundColor: const Color(0xFF8FEC95),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        );
      },
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

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final MoodType mood;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.date,
  });
}

enum MoodType {
  happy('Happy', Icons.sentiment_very_satisfied, Color(0xFFFFD54F)),
  sad('Sad', Icons.sentiment_very_dissatisfied, Color(0xFF64B5F6)),
  anxious('Anxious', Icons.sentiment_neutral, Color(0xFFFF9800)),
  angry('Angry', Icons.mood_bad, Color(0xFFE91E63)),
  calm('Calm', Icons.spa, Color(0xFF4CAF50)),
  tired('Tired', Icons.bedtime, Color(0xFF9C27B0));

  const MoodType(this.label, this.icon, this.color);
  
  final String label;
  final IconData icon;
  final Color color;
}
