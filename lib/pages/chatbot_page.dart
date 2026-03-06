import 'package:flutter/material.dart';

// Provides a simple rule-based educational chatbot interface
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

    final response = await _mockBotReply(text);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage.assistant(response));
      _isSending = false;
    });
    _scrollToBottom();
  }

  // Chatbot response using keyword-based logic
  Future<String> _mockBotReply(String text) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final lower = text.toLowerCase();

    // Greeting
    if (lower == 'hi' ||
        lower == 'hello' ||
        lower.contains('hey')) {
      return 'Hello! I can give general educational information about diabetic foot problems such as ulcers, blisters, corns, calluses, infection warning signs, and foot care :)';
    }

    // Thank you
    if (lower.contains('thank')) {
      return 'You are welcome! If you have more questions about diabetic foot health, feel free to ask.';
    }

    // What the chatbot does
    if (lower.contains('what can you do') ||
        lower.contains('help me') ||
        lower.contains('what do you know')) {
      return 'I provide general educational information about diabetic foot care and common foot problems. However, I do not diagnose conditions or give treatment plans.';
    }

    // Ulcer
    if (lower.contains('ulcer') ||
        lower.contains('diabetic foot ulcer')) {
      return 'A diabetic foot ulcer is an open  sore or wound on the foot that can heal slowly and may become infected. It is usually circular. It should be taken seriously and assessed by a healthcare professional.';
    }

    // Gangrene
    if (lower.contains('gangrene')) {
      return 'Gangrene means body tissue is dying, often because of poor blood flow or serious infection. You will notice that the color of the skin will darken. It needs urgent medical attention to prevent amputation.';
    }

    // Blister
    if (lower.contains('blister')) {
      return 'A blister is a small pocket of fluid under the skin. In a person with diabetes, even a blister should be monitored carefully because it can break down and become infected.';
    }

    // Corn / callus
    if (lower.contains('corn') || lower.contains('callus') || lower.contains('calluses')) {
      return 'Corns and calluses are thickened areas of skin caused by pressure or friction. In diabetes, they should be monitored carefully because thick calluses can break down into ulcers. Do not cut them yourself or use chemical corn removers.';
    }

    // Infection / warning signs
    if (lower.contains('infection') ||
        lower.contains('infected') ||
        lower.contains('warning sign') ||
        lower.contains('danger sign') ||
        lower.contains('redness') ||
        lower.contains('swelling') ||
        lower.contains('pus') ||
        lower.contains('smell')) {
      return 'Warning signs include redness, swelling, color change, discharge, bad smell, increasing pain, numbness, or a sore, blister, or ulcer that is not healing. These signs should be assessed by a healthcare professional.';
    }

    // Other diabetic diseases
    if (lower.contains('kidney') ||
        lower.contains('eye') ||
        lower.contains('retinopathy') ||
        lower.contains('neuropathy')) {
      return 'Diabetes can affect many parts of the body such as the eyes, kidneys, nerves, and heart. This assistant mainly provides information about diabetic foot health. For other complications, please consult a healthcare professional.';
    }

    // Pain / numbness
    if (lower.contains('pain') ||
        lower.contains('numb') ||
        lower.contains('numbness')) {
      return 'Pain or numbness in the feet can be important warning signs in diabetes. Numbness may make injuries harder to notice, so daily foot checks are important.';
    }

    // Amputation
    if (lower.contains('amputation') ||
        lower.contains('amputate')) {
      return 'In severe cases, untreated infections or gangrene in the foot may lead to amputation. Early detection and proper foot care can greatly reduce this risk.';
    }

    // When to see a doctor
    if (lower.contains('doctor') ||
        lower.contains('hospital') ||
        lower.contains('clinic') ||
        lower.contains('mediclinic') ||
        lower.contains('when should i see') ||
        lower.contains('when to seek help')) {
      return 'You should seek medical help if you notice a wound, sore, blister, or ulcer that is not healing, or if there is swelling, redness, discharge, bad smell, color change, pain, or numbness.';
    }

    // Foot care / prevention
    if (lower.contains('prevention') ||
        lower.contains('prevent') ||
        lower.contains('foot care') ||
        lower.contains('care for my feet') ||
        lower.contains('protect my feet')) {
      return 'Basic foot care includes checking your feet every day, keeping them clean and dry, wearing well-fitting footwear, avoiding self-cutting corns or calluses, and seeking medical advice early for any sore, blister, or skin change. You can also check the Foot Care Tips.';
    }

    // Shoes / footwear
    if (lower.contains('shoe') ||
        lower.contains('footwear') ||
        lower.contains('socks')) {
      return 'Proper footwear is important in diabetes. Shoes should fit well and not rub the skin. Socks and footwear can help reduce pressure and lower the risk of blisters and skin breakdown.';
    }

    // Cut / wound
    if (lower.contains('cut') ||
        lower.contains('wound') ||
        lower.contains('sore')) {
      return 'A cut or sore on a diabetic foot should not be ignored. If it does not start healing promptly or looks worse, it should be checked by a healthcare professional.';
    }

    // Treatment / cure
    if (lower.contains('treatment') ||
        lower.contains('cure') ||
        lower.contains('medicine') ||
        lower.contains('antibiotic')) {
      return 'I can only provide general educational information. For treatment decisions, medicines, dressings, or antibiotics, please consult a doctor or podiatry team.';
    }

    // Other diseases outside scope
    if (lower.contains('cancer') ||
        lower.contains('eczema') ||
        lower.contains('psoriasis') ||
        lower.contains('fungus') ||
        lower.contains('heart disease') ||
        lower.contains('kidney') ||
        lower.contains('asthma')) {
      return 'I am designed mainly for educational information about diabetic foot conditions. For other diseases or a diagnosis, please consult a qualified healthcare professional.';
    }

    // Emergency-seeming phrases
    if (lower.contains('black') ||
        lower.contains('turning black') ||
        lower.contains('severe infection') ||
        lower.contains('blood') ||
        lower.contains('flesh') ||
        lower.contains('bone')) {
      return 'That may be serious. Please seek urgent medical attention as soon as possible.';
    }

    // Asking about images
    if (lower.contains('image') ||
        lower.contains('picture') ||
        lower.contains('show me')) {
      return 'This chat assistant cannot display medical images. However, you can use the Scan feature of the app to analyze a foot image.';
    }

    // Fallback
    return 'I can provide general educational information about diabetic foot ulcers, gangrene, blisters, corns, calluses, warning signs, and foot care. I do not diagnose conditions or replace a healthcare professional.';
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
          'Foot Care Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),


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

      // Text input
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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

              // Send Button
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
  final String role; // role can be user or assitant
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

// Show sample question as default
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Center(
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
              alignment: WrapAlignment.center,
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