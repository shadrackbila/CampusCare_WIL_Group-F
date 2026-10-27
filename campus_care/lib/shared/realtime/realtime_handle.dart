/// Something that must be closed when the screen or provider that opened it goes away.
abstract class RealtimeHandle {
  Future<void> close();
}

class CallbackRealtimeHandle implements RealtimeHandle {
  CallbackRealtimeHandle(this._onClose);

  final Future<void> Function() _onClose;
  bool _closed = false;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _onClose();
  }
}
