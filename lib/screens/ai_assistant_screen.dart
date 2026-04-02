import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

const _geminiApiKey = 'AIzaSyCYi9g0YmOPxzhjkTHdfXS6ZvOAnEpLpqU';

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  late final GenerativeModel _model;
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
      systemInstruction: Content.text(
        'You are the Smart Fujairah AI Assistant — a helpful, professional chatbot '
        'for Fujairah Municipality government services in the UAE. '
        'You help citizens with questions about municipality services such as: '
        'building permits, land registration, health inspections, urban planning, '
        'consumer protection, public cleanliness, housing services, and employee services. '
        'You can explain requirements, fees, processing times, and required documents. '
        'Be concise, friendly, and professional. '
        'If the user writes in Arabic, respond in Arabic. '
        'If the user writes in English, respond in English. '
        'Always remind users that for official transactions they should visit '
        'the Fujairah Municipality office or use the official portal.',
      ),
    );
    _chat = _model.startChat();
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
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      String responseText = '';
      final stream = _chat.sendMessageStream(Content.text(userMessage));

      await for (final chunk in stream) {
        final chunkText = chunk.text ?? '';
        if (chunkText.isNotEmpty) {
          responseText += chunkText;
          setState(() {
            if (_messages.isNotEmpty && !_messages.last.isUser) {
              _messages[_messages.length - 1] = ChatMessage(
                text: responseText,
                isUser: false,
              );
            } else {
              _messages.add(ChatMessage(text: responseText, isUser: false));
            }
          });
          _scrollToBottom();
        }
      }

      if (responseText.isEmpty) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'ai_no_response'.tr(),
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(text: '${'error_occurred'.tr()}: $e', isUser: false),
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
      _chat = _model.startChat();
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
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
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
                          const SizedBox(height: 24),
                          // Suggestion chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _SuggestionChip(
                                label: 'ai_suggest_permit'.tr(),
                                onTap: () => _sendMessage(
                                    'ai_suggest_permit'.tr()),
                              ),
                              _SuggestionChip(
                                label: 'ai_suggest_land'.tr(),
                                onTap: () =>
                                    _sendMessage('ai_suggest_land'.tr()),
                              ),
                              _SuggestionChip(
                                label: 'ai_suggest_complaint'.tr(),
                                onTap: () => _sendMessage(
                                    'ai_suggest_complaint'.tr()),
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
                    itemCount: _messages.length +
                        (_isTyping &&
                                (_messages.isEmpty || _messages.last.isUser)
                            ? 1
                            : 0),
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
