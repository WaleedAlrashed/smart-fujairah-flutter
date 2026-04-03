// Cloudflare Workers AI Chat Screen
// Uses the cloudflare_ai package to interact with Cloudflare's AI models
// via the Workers AI REST API for text chat conversations.

import 'package:cloudflare_ai/src/text_chat/text_chat.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

/// The main screen widget for the Cloudflare AI chatbot.
/// Uses StatefulWidget because it manages mutable chat state (messages, typing status).
class CloudflareAiScreen extends StatefulWidget {
  const CloudflareAiScreen({super.key});

  @override
  State<CloudflareAiScreen> createState() => _CloudflareAiScreenState();
}

class _CloudflareAiScreenState extends State<CloudflareAiScreen> {
  // Controller for the text input field — lets us read and clear user input
  final _textController = TextEditingController();

  // Controller for the message list — enables programmatic scrolling to the bottom
  final _scrollController = ScrollController();

  // In-memory list of all chat messages (both user and AI responses)
  final List<_ChatMessage> _messages = [];

  // Tracks whether we're waiting for an AI response (used to show typing indicator and disable input)
  bool _isTyping = false;

  // The Cloudflare AI text chat model instance — initialized once in initState
  late final TextChatModel _model;

  @override
  void initState() {
    super.initState();

    // Initialize the Cloudflare AI model with credentials from the .env file.
    // dotenv.env reads key-value pairs loaded at app startup (see main.dart).
    // TextChatModel maintains conversation history internally for multi-turn chat.
    _model = TextChatModel(
      accountId: dotenv.env['CLOUDFLARE_ACCOUNT_ID'] ?? '',
      apiKey: dotenv.env['CLOUDFLARE_API_KEY'] ?? '',
      model: TextChatModels.QWEN_1_5_7B_CHAT_AWQ,
    );

    // Load a system prompt to set the AI's persona and behavior.
    // The "system" role message is not shown to the user but guides the AI's responses.
    _model.loadMessages([
      {
        "role": "system",
        "content":
            "You are the Smart Fujairah AI Assistant — a helpful, professional chatbot "
            "for Fujairah Municipality government services in the UAE. "
            "You help citizens with questions about municipality services such as: "
            "building permits, land registration, health inspections, urban planning, "
            "consumer protection, public cleanliness, housing services, and employee services. "
            "You can explain requirements, fees, processing times, and required documents. "
            "Be concise, friendly, and professional. "
            "If the user writes in Arabic, respond in Arabic. "
            "If the user writes in English, respond in English. "
            "Always remind users that for official transactions they should visit "
            "the Fujairah Municipality office or use the official portal.",
      },
    ]);
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Smoothly scrolls the message list to the bottom after a new message is added.
  /// Uses addPostFrameCallback to wait until the widget tree is rebuilt with the new message.
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

  /// Sends a message to the Cloudflare AI model and displays the response.
  /// 1. Validates input and prevents duplicate sends while typing
  /// 2. Adds the user message to the list and shows a typing indicator
  /// 3. Calls _model.chat() which sends the full conversation history to the API
  /// 4. Adds the AI response (or error) to the message list
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    final userMessage = text.trim();
    _textController.clear();

    // Add the user's message and show the typing indicator
    setState(() {
      _messages.add(_ChatMessage(text: userMessage, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // _model.chat() sends the message along with all previous messages
      // to maintain conversation context (multi-turn chat)
      final response = await _model.chat(userMessage);

      // Add the AI's response to the message list
      setState(() {
        _messages.add(_ChatMessage(text: response.content, isUser: false));
      });
    } catch (e) {
      // Display the error inline as a chat message so the user sees what went wrong
      setState(() {
        _messages.add(
          _ChatMessage(text: '${'error_occurred'.tr()}: $e', isUser: false),
        );
      });
    } finally {
      // Always hide the typing indicator, whether the request succeeded or failed
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  /// Clears all messages and resets the AI model's conversation history.
  /// Re-loads the system prompt so the AI retains its persona in the new conversation.
  void _clearChat() {
    setState(() {
      _messages.clear();
      _model.loadMessages([
        {
          "role": "system",
          "content":
              "You are the Smart Fujairah AI Assistant — a helpful, professional chatbot "
              "for Fujairah Municipality government services in the UAE.",
        },
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Scaffold provides the basic screen structure: app bar + body
    return Scaffold(
      // App bar with title and a clear-chat button (only shown when there are messages)
      appBar: AppBar(
        title: Text('ai_assistant'.tr()),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'ai_clear_chat'.tr(),
              onPressed: _clearChat,
            ),
        ],
      ),

      // Body is a Column: expandable message area on top, fixed input bar at bottom
      body: Column(
        children: [
          // Message area — takes all available space above the input bar
          Expanded(
            child: _messages.isEmpty
                // Empty state: shown when no messages yet — displays welcome text and suggestion chips
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Robot icon as visual indicator for AI chat
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Welcome title — localized via easy_localization
                          Text(
                            'ai_welcome'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Welcome subtitle with usage instructions
                          Text(
                            'ai_welcome_subtitle'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Attribution label for Cloudflare Workers AI
                          Text(
                            'Powered by Cloudflare Workers AI',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Suggestion chips — tappable shortcuts that pre-fill and send common questions
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _SuggestionChip(
                                label: 'ai_suggest_permit'.tr(),
                                onTap: () =>
                                    _sendMessage('ai_suggest_permit'.tr()),
                              ),
                              _SuggestionChip(
                                label: 'ai_suggest_land'.tr(),
                                onTap: () =>
                                    _sendMessage('ai_suggest_land'.tr()),
                              ),
                              _SuggestionChip(
                                label: 'ai_suggest_complaint'.tr(),
                                onTap: () =>
                                    _sendMessage('ai_suggest_complaint'.tr()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                // Message list — shown when there are messages
                // ListView.builder lazily builds only visible items for performance
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    // Extra item at the end for the typing indicator when waiting for AI response
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Last item (when typing) shows the animated dots indicator
                      if (index == _messages.length) {
                        return const TypingIndicator();
                      }
                      // Each message is rendered as a bubble — aligned left (AI) or right (user)
                      final message = _messages[index];
                      return MessageBubble(
                        isUser: message.isUser,
                        message: message.text,
                      );
                    },
                  ),
          ),

          // Input bar — fixed at the bottom with a subtle top shadow
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              // Top shadow to visually separate the input area from messages
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            // SafeArea ensures the input bar isn't hidden behind system UI (e.g. home indicator)
            child: SafeArea(
              child: Row(
                children: [
                  // Text field — expands to fill available width
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'ai_input_hint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      // "Send" action on the keyboard submits the message
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      // Disable input while waiting for AI response
                      enabled: !_isTyping,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Circular send button — disabled while typing to prevent duplicate sends
                  FilledButton(
                    onPressed: _isTyping
                        ? null
                        : () => _sendMessage(_textController.text),
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple data class to hold a chat message's text and sender.
/// Private to this file — only used internally by the screen.
class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

/// A tappable chip that suggests a common question to the user.
/// When tapped, it immediately sends the suggestion as a chat message.
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ActionChip is a Material chip that triggers an action on tap (no selection state)
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.auto_awesome, size: 16),
    );
  }
}
