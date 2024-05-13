import 'package:flutter/foundation.dart';

/// 统一管理App弹框
class AppDialogStackManager {
  static final AppDialogStackManager _instance = AppDialogStackManager._();
  AppDialogStackManager._();
  factory AppDialogStackManager() => _instance;

  /// 等待弹框的Map
  final Map<int, AppDialog> _stack = {};

  /// 获取当前队列所有弹框的对象
  List<AppDialog> get dialogs => _stack.values.toList();

  final List<VoidCallback> _listeners = [];

  bool _isDailoging = false;
  bool get isDailoging => _isDailoging;

  /// 已经弹框的Dialog
  final List<AppDialog> _completedDialogs = [];

  /// 将弹框进行入栈
  push(AppDialog dialog, [int? level]) {
    if (level == null) {
      final levels = _stack.keys.toList();
      levels.sort();
      if (levels.isEmpty) {
        level = 0;
      } else {
        level = levels.last + 1;
      }
    }
    _stack[level] = dialog;
  }

  /// 只弹出一次
  pushOnce<T extends AppDialog>(
    T dialog, {
    int? level,
    bool useDialogEqual = false,
    bool Function(T dialog)? where,
  }) {
    var completionDialogs = _completedDialogs.whereType<T>().toList();
    if (where != null) {
      completionDialogs = completionDialogs.where(where).toList();
    } else if (useDialogEqual) {
      completionDialogs =
          completionDialogs.where((element) => element.equal(dialog)).toList();
    }
    bool allow = completionDialogs.isEmpty;
    if (allow) {
      push(dialog, level);
    }
  }

  /// 进行弹框
  alert() async {
    if (_stack.isEmpty) return;

    /// 获取当前的Key 并且从小到大排序
    final levels = _stack.keys.toList();
    levels.sort();

    _isDailoging = true;
    for (final level in levels) {
      await _alertLevel(level);
    }
    _isDailoging = false;
    _completionDialog();
  }

  alertLevel(int level) async {
    _isDailoging = true;
    await _alertLevel(level);
    _isDailoging = false;
    _completionDialog();
  }

  alertWhere(bool Function(AppDialog dialog) where) async {
    if (_stack.isEmpty) return;
    for (final level in _stack.keys) {
      final dialog = _stack[level]!;
      if (where(dialog)) {
        _isDailoging = true;
        await _alertLevel(level);
        _isDailoging = false;
        _completionDialog();
        break;
      }
    }
  }

  _alertLevel(int level) async {
    final dialog = _stack[level];
    if (dialog == null) return;
    await dialog.init();
    if (!await dialog.allowShow) {
      return;
    }
    await dialog.show();
    _completedDialogs.add(dialog);
    _stack.remove(level);
  }

  _completionDialog() {
    for (final listener in _listeners) {
      listener();
    }
  }

  addDialogCompletionListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  removeDialogCompletionListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}

/// 弹框的基类
abstract class AppDialog<T> {
  /// 初始化弹框的数据
  Future<void> init() async {
    if (isInitHudLoading) {
      showHUD();
      await preInit();
      hideHUD();
    } else {
      await preInit();
    }
  }

  Future<void> preInit();

  /// 是否允许弹出
  Future<bool> get allowShow;

  /// 进行弹框
  Future<void> show();

  bool equal(T dialog) {
    return false;
  }

  bool get isInitHudLoading => false;

  void showHUD() {}
  void hideHUD() {}
}
