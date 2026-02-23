import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const darkBlue = Color(0xFF144AB5);
  static const lightBlue = Color(0xFFAAD4F6);

  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add(_ChatMessage.user(text));
    });
    _controller.clear();
    _scrollToBottom();

    // Later: replace this with Firebase/Cloud Function call
    final response = await _mockBotReply(text);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage.assistant(response));
      _isSending = false;
    });
    _scrollToBottom();
  }

  Future<String> _mockBotReply(String text) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final lower = text.toLowerCase();

    if (lower.contains('treatment') || lower.contains('cure')) {
      return 'Seek medical advice from a doctor.';
    }
    if (lower.contains('ulcer')) {
      return 'An ulcer is a break in the skin or a deep sore that can be slow to heal.';
    }
    if (lower.contains('gangrene')) {
      return 'Gangrene is tissue damage due to poor blood flow or serious infection.';
    }
    if (lower.contains('blister')) {
      return 'Blisters are small fluid pockets. For diabetics, monitor them carefully.';
    }
    if (lower.contains('corn') || lower.contains('callus')) {
      return 'Corns and calluses are thickened skin from pressure or friction. In diabetes, they should be monitored carefully.';
    }
    return 'I can provide general educational info only. If you are concerned, please consult a healthcare professional.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'AI Health Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ Body ONLY has banner + messages
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.amber[100],
            child: const Text(
              'This chat provides general information only.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: _messages.isEmpty
                ? _EmptyChatHint(
              onExampleTap: (q) {
                _controller.text = q;
                _sendMessage();
              },
            )
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
        ],
      ),

      // ✅ Input moved here to prevent keyboard overflow
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask about foot health...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: darkBlue, width: 1.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                width: 46,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: _isSending
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role; // 'user' or 'assistant'
  final String text;

  _ChatMessage({required this.role, required this.text});

  factory _ChatMessage.user(String text) =>
      _ChatMessage(role: 'user', text: text);

  factory _ChatMessage.assistant(String text) =>
      _ChatMessage(role: 'assistant', text: text);
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  static const darkBlue = Color(0xFF144AB5);
  static const lightBlue = Color(0xFFAAD4F6);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    final bg = isUser
        ? lightBlue.withValues(alpha: 0.45)
        : darkBlue.withValues(alpha: 0.12);

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    );

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}

class _EmptyChatHint extends StatelessWidget {
  final void Function(String question) onExampleTap;

  const _EmptyChatHint({required this.onExampleTap});

  static const darkBlue = Color(0xFF144AB5);

  @override
  Widget build(BuildContext context) {
    final examples = const [
      'What is a diabetic foot ulcer?',
      'What is gangrene?',
      'How do I care for blisters?',
      'When should I see a doctor?',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: darkBlue,
                size: 34,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ask a question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Educational support only. For treatment, consult a doctor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: examples
                  .map(
                    (q) => ActionChip(
                  label: Text(q),
                  onPressed: () => onExampleTap(q),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}