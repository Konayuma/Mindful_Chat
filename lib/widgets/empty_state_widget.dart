import 'package:flutter/material.dart';

/// Reusable empty state widget for various screens
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FEC95).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 64,
                    color: const Color(0xFF8FEC95),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (customAction != null) ...[
              const SizedBox(height: 32),
              customAction!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FEC95),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state specifically for journal entries
class EmptyJournalState extends StatelessWidget {
  final VoidCallback onCreateEntry;

  const EmptyJournalState({
    super.key,
    required this.onCreateEntry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.edit,
      title: 'Start Your Journal',
      message: 'Your thoughts and reflections will appear here.\nStart your first journal entry to begin your wellness journey.',
      actionLabel: 'Create First Entry',
      onAction: onCreateEntry,
    );
  }
}

/// Empty state for bookmarks/favorites
class EmptyBookmarksState extends StatelessWidget {
  const EmptyBookmarksState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'No Favourites Yet',
      message: 'Save your favorite affirmations, messages, and journal entries.\nThey\'ll appear here for easy access.',
    );
  }
}

/// Empty state for chat history
class EmptyChatState extends StatelessWidget {
  final VoidCallback onStartChat;

  const EmptyChatState({
    super.key,
    required this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'Start a Conversation',
      message: 'Share what\'s on your mind. I\'m here to listen and support you on your mental wellness journey.',
      actionLabel: 'Start Chatting',
      onAction: onStartChat,
    );
  }
}

/// Empty state for search results
class EmptySearchState extends StatelessWidget {
  final String searchQuery;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'We couldn\'t find anything matching "$searchQuery".\nTry using different keywords.',
    );
  }
}

/// Loading state with animation
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: child,
              );
            },
            onEnd: () {
              // This will cause the animation to repeat
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                  gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8FEC95),
                    const Color(0xFF8FEC95).withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state with retry option
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FEC95),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
