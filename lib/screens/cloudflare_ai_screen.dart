import 'package:cloudflare_ai/src/text_chat/text_chat.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class CloudflareAiScreen extends StatefulWidget {
  const CloudflareAiScreen({super.key});

  @override
  State<CloudflareAiScreen> createState() => _CloudflareAiScreenState();
}

class _CloudflareAiScreenState extends State<CloudflareAiScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  late final TextChatModel _model;

  @override
  void initState() {
    super.initState();
    _model = TextChatModel(
      accountId: dotenv.env['CLOUDFLARE_ACCOUNT_ID'] ?? '',
      apiKey: dotenv.env['CLOUDFLARE_API_KEY'] ?? '',
      model: TextChatModels.QWEN_1_5_7B_CHAT_AWQ,
    );

    // Set system prompt
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
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    final userMessage = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: userMessage, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _model.chat(userMessage);

      setState(() {
        _messages.add(_ChatMessage(text: response.content, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(text: '${'error_occurred'.tr()}: $e', isUser: false),
        );
      });
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      // Re-initialize with system prompt
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

    return Scaffold(
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
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ai_welcome'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ai_welcome_subtitle'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Powered by Cloudflare Workers AI',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
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
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const TypingIndicator();
                      }
                      final message = _messages[index];
                      return MessageBubble(
                        isUser: message.isUser,
                        message: message.text,
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: SafeArea(
              child: Row(
                children: [
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      enabled: !_isTyping,
                    ),
                  ),
                  const SizedBox(width: 8),
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

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.auto_awesome, size: 16),
    );
  }
}
