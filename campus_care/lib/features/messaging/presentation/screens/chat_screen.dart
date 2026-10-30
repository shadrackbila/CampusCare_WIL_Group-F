import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/sa_time.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/practitioner_avatar.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../data/messaging_repository.dart';
import '../../models/chat_message.dart';
import '../../models/conversation_summary.dart';
import '../viewModels/chat_provider.dart';
import '../viewModels/messaging_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().student?.userId;
    if (userId == null || conversationId.isEmpty) {
      return const SkyBackground(
        child: SafeArea(
          child: Center(
            child: Text(
              'This chat is not available.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    return ChangeNotifierProvider<ChatProvider>(
      create: (ctx) => ChatProvider(
        ctx.read<MessagingRepository>(),
        conversationId: conversationId,
        myUserId: userId,
      )..start(),
      child: _ChatView(conversationId: conversationId),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.conversationId});

  final String conversationId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final chat = context.read<ChatProvider>();
    final ok = await chat.send(_controller.text);
    if (ok && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final summary = context.select<MessagingProvider, ConversationSummary?>(
      (m) => m.byId(widget.conversationId),
    );
    final name = summary?.otherName ?? 'Peer Educator';
    final role = summary?.otherRole ?? 'Peer Educator';
    final msgs = chat.messages;

    return PopScope(
      onPopInvokedWithResult: (_, __) =>
          context.read<MessagingProvider>().load(silent: true),
      child: SkyBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Back',
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    PractitionerAvatar(
                      photoUrl: summary?.photoUrl,
                      seed: widget.conversationId,
                      size: 44,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            role,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: chat.loading && !chat.loaded
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : chat.error != null && !chat.loaded
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ErrorBanner(chat.error!),
                            TextButton(
                              onPressed: () =>
                                  context.read<ChatProvider>().retry(),
                              child: const Text(
                                'Try again',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _MessageList(
                        messages: msgs,
                        myUserId: context.read<ChatProvider>().myUserId,
                      ),
              ),
              if (chat.sendError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: ErrorBanner(chat.sendError!),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLength: 1000,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) =>
                            context.read<ChatProvider>().clearSendError(),
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Send message',
                      onPressed: chat.sending ? null : _send,
                      icon: chat.sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages, required this.myUserId});

  final List<ChatMessage> messages;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    // Reversed list: index 0 is the newest message, so new messages stay in view.
    final items = <Widget>[];
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      items.add(_Bubble(message: m, mine: m.senderId == myUserId));
      final day = saToday(m.createdAt);
      final prevDay = i > 0 ? saToday(messages[i - 1].createdAt) : null;
      if (prevDay == null || prevDay != day) items.add(_DateHeader(day));
    }
    items.add(const _Notice());
    return ListView(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: items,
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Messages are private. Only people in this chat can read them. '
        'Peer educators are trained students, not counsellors. '
        'In an emergency, use Emergency SOS on the Home screen.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader(this.day);

  final DateTime day;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Center(
      child: Text(
        formatDate(day),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final t = saWallClock(message.createdAt);
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        label: '${mine ? 'You' : 'Them'}, $hh:$mm. ${message.body}',
        child: ExcludeSemantics(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: mine ? AppColors.blue : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.body,
                  style: TextStyle(color: mine ? Colors.white : AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '$hh:$mm',
                  style: TextStyle(
                    fontSize: 10,
                    color: mine ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
