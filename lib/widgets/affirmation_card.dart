import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/affirmation.dart';
import '../services/bookmark_service.dart';
import '../models/bookmark.dart';

/// Reusable affirmation card widget
class AffirmationCard extends StatefulWidget {
  final Affirmation affirmation;
  final VoidCallback? onRefresh;
  final bool showActions;
  final EdgeInsets? padding;

  const AffirmationCard({
    super.key,
    required this.affirmation,
    this.onRefresh,
    this.showActions = true,
    this.padding,
  });

  @override
  State<AffirmationCard> createState() => _AffirmationCardState();
}

class _AffirmationCardState extends State<AffirmationCard> {
  final _bookmarkService = BookmarkService();
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final bookmarked = await _bookmarkService.isBookmarked(
      type: BookmarkType.affirmation,
      itemId: widget.affirmation.id,
    );
    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isLoading = true;
    });

    final added = await _bookmarkService.toggleBookmark(
      type: BookmarkType.affirmation,
      itemId: widget.affirmation.id,
      payload: {
        'id': widget.affirmation.id,
        'content': widget.affirmation.content,
        'author': widget.affirmation.author,
        'category': widget.affirmation.category,
        'tags': widget.affirmation.tags,
      },
    );

    if (mounted) {
      setState(() {
        _isBookmarked = added;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? '✅ Added to favorites' : '❌ Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(
      ClipboardData(
        text: '${widget.affirmation.content}\n\n— ${widget.affirmation.author ?? 'Mindful Chat'}',
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _share() async {
    await Share.share(
      '${widget.affirmation.content}\n\n— ${widget.affirmation.author ?? 'Mindful Chat'}\n\nShared from Mindful Chat',
      subject: 'Daily Affirmation',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primaryColor.withOpacity(0.2),
                  primaryColor.withOpacity(0.1),
                ]
              : [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.affirmation.category.toUpperCase(),
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quote icon
          Icon(
            Icons.format_quote,
            size: 40,
            color: primaryColor.withOpacity(0.3),
          ),
          
          const SizedBox(height: 12),
          
          // Affirmation content
          Text(
            widget.affirmation.content,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Author
          if (widget.affirmation.author != null)
            Text(
              '— ${widget.affirmation.author}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Tags
          if (widget.affirmation.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.affirmation.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
                    ),
                  ),
                );
              }).toList(),
            ),
          
          if (widget.showActions) ...[
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Refresh button
                if (widget.onRefresh != null)
                  IconButton(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Get new affirmation',
                    style: IconButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.1),
                    ),
                  )
                else
                  const SizedBox(width: 48),
                
                // Action buttons
                Row(
                  children: [
                    // Bookmark button
                    IconButton(
                      onPressed: _isLoading ? null : _toggleBookmark,
                      icon: Icon(
                        _isBookmarked ? Icons.favorite : Icons.favorite_border,
                      ),
                      tooltip: _isBookmarked ? 'Remove from favorites' : 'Add to favorites',
                      style: IconButton.styleFrom(
                        foregroundColor: _isBookmarked ? Colors.red : primaryColor,
                        backgroundColor: (_isBookmarked ? Colors.red : primaryColor).withOpacity(0.1),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Copy button
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy to clipboard',
                      style: IconButton.styleFrom(
                        foregroundColor: primaryColor,
                        backgroundColor: primaryColor.withOpacity(0.1),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Share button
                    IconButton(
                      onPressed: _share,
                      icon: const Icon(Icons.share),
                      tooltip: 'Share affirmation',
                      style: IconButton.styleFrom(
                        foregroundColor: primaryColor,
                        backgroundColor: primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
