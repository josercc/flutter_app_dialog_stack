## 怎么使用

### 创建一个简单的`Dialog`

```dart
class TestDialog extends AppDialog {
  /// 是否允许弹出
  @override
  Future<bool> get allowShow => Future.value(true);

  /// 提前需要初始化的数据
  @override
  Future<void> preInit() async {}

  /// 执行弹出的逻辑
  @override
  Future<void> show() async {}
}

```

### 立即进行弹出弹框

```dart
final dialog = TestDialog();

/// 
AppDialogStackManager()..push(dialog,1)..alert();
```

### 同时弹出设置优先级

```dart
final dialog1 = TestDialog();
final dialog2 = TestDialog();

/// 此时会先展示dialog2再展示dialog1
AppDialogStackManager()..push(dialog1,1)..push(dialog2,2)..alert();
```

### 只展示一次

```dart
/// 此时只会弹出TestDialog一次 默认采用类名字判断但是你可以使用where:(dialog) => 进行自定义判断
AppDialogStackManager()..push(TestDialog())..alert();
AppDialogStackManager()..push(TestDialog())..alert();
```

### 延后弹出

```dart
AppDialogStackManager()..push(TestDialog());
// 模拟延后操作
AppDialogStackManager()..alertWhere()
```