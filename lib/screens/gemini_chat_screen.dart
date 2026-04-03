import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<Content> _chatHistory = [];
  bool _isTyping = false;

  final _gemini = Gemini.instance;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Add user message to chat history
    _chatHistory.add(
      Content(parts: [Parts(text: text)], role: 'user'),
    );

    try {
      // Use streaming for a better UX
      final responseBuffer = StringBuffer();
      int? aiMessageIndex;

      _gemini
          .chat(_chatHistory)
          .then((response) {
        final output = response?.output ?? 'ai_no_response'.tr();

        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(text: output, isUser: false));
        });

        // Add model response to history
        _chatHistory.add(
          Content(parts: [Parts(text: output)], role: 'model'),
        );

        _scrollToBottom();
      }).catchError((error) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: 'Error: ${error.toString()}',
            isUser: false,
          ));
        });
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: 'Error: ${e.toString()}',
          isUser: false,
        ));
      });
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _chatHistory.clear();
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('gemini_chat'.tr()),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'ai_clear_chat'.tr(),
              onPressed: _clearChat,
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcome(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return const TypingIndicator();
                      }
                      final msg = _messages[index];
                      return MessageBubble(
                        isUser: msg.isUser,
                        message: msg.text,
                      );
                    },
                  ),
          ),

          // Suggestion chips
          if (_messages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _SuggestionChip(
                    label: 'ai_suggest_permit'.tr(),
                    onTap: (text) => _sendMessage(text),
                  ),
                  _SuggestionChip(
                    label: 'ai_suggest_land'.tr(),
                    onTap: (text) => _sendMessage(text),
                  ),
                  _SuggestionChip(
                    label: 'ai_suggest_complaint'.tr(),
                    onTap: (text) => _sendMessage(text),
                  ),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'ai_input_hint'.tr(),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      enabled: !_isTyping,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isTyping
                        ? null
                        : () => _sendMessage(_textController.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              'gemini_chat'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'gemini_chat_subtitle'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final void Function(String) onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => onTap(label),
      avatar: const Icon(Icons.auto_awesome, size: 14),
    );
  }
}
