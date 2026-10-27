import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Which sub-tab of the Messages tab is showing.
enum MessagesTab { chats, notifications }

enum AppTab { home, appointments, messages, profile }

/// Which bottom-bar tab is showing. Provided once in app.dart.
class MainTabs extends ChangeNotifier {
  AppTab _tab = AppTab.home;
  MessagesTab _messagesTab = MessagesTab.chats;

  AppTab get tab => _tab;
  int get index => _tab.index;
  MessagesTab get messagesTab => _messagesTab;

  void select(AppTab tab, {MessagesTab? messages}) {
    final newMessages = messages ?? _messagesTab;
    if (tab == _tab && newMessages == _messagesTab) return;
    _tab = tab;
    _messagesTab = newMessages;
    notifyListeners();
  }

  void reset() {
    _tab = AppTab.home;
    _messagesTab = MessagesTab.chats;
    notifyListeners();
  }
}

class AppNav {
  const AppNav._();

  /// Closes every page opened on top of the tabs and shows [tab].
  /// Pass [then] to open another page on top of that tab (e.g. a chat on Messages).
  static void toTab(
    BuildContext context,
    AppTab tab, {
    MessagesTab? messages,
    Route<void>? then,
  }) {
    final tabs = context.read<MainTabs>();
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    tabs.select(tab, messages: messages);
    if (then != null) nav.push(then);
  }
}
