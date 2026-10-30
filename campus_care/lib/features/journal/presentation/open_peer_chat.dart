import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/routing/main_tabs.dart';
import 'viewModels/messaging_provider.dart';

/// Opens (creating the first time) the student's peer-educator chat.
Future<void> openPeerChat(BuildContext context) async {
  final messaging = context.read<MessagingProvider>();
  final nav = Navigator.of(context);
  final tabs = context.read<MainTabs>();
  final messenger = ScaffoldMessenger.of(context);
  try {
    final id = await messaging.openPeerChat();
    nav.popUntil((r) => r.isFirst);
    tabs.select(AppTab.messages);
    nav.push(AppRoutes.chat(id));
  } on AppException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}
