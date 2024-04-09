import 'package:flutter/material.dart';

import 'dismiss_keyboard.dart';
import 'raw_pip_view.dart';

class PIPView extends StatefulWidget {
  final PIPViewCorner initialCorner;
  final double? floatingWidth;
  final double? floatingHeight;
  final bool avoidKeyboard;
  final EdgeInsets padding;

  final Widget Function(
    BuildContext context,
    bool isFloating,
  ) builder;

  const PIPView({
    Key? key,
    required this.builder,
    this.initialCorner = PIPViewCorner.topRight,
    this.floatingWidth,
    this.floatingHeight,
    this.avoidKeyboard = true,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  PIPViewState createState() => PIPViewState();

  static PIPViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<PIPViewState>();
  }
}

class PIPViewState extends State<PIPView> with TickerProviderStateMixin {
  Widget? _bottomWidget;
  bool _shouldShowTopWidget = true;

  void presentBelow(Widget widget) {
    dismissKeyboard(context);
    setState(() => _bottomWidget = widget);
  }

  void stopFloating() {
    dismissKeyboard(context);
    setState(() => _bottomWidget = null);
  }

  bool get isFloating => _bottomWidget != null && _shouldShowTopWidget;

  // NOTE: floating を終了しつつ、下側のウィジェットに置き換える
  void replaceToBelow() {
    dismissKeyboard(context);
    setState(() {
      _shouldShowTopWidget = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFloating = _bottomWidget != null;
    return RawPIPView(
      avoidKeyboard: widget.avoidKeyboard,
      bottomWidget: isFloating
          ? Navigator(
              onGenerateInitialRoutes: (navigator, initialRoute) => [
                MaterialPageRoute(builder: (context) => _bottomWidget!),
              ],
            )
          : null,
      onTapTopWidget: isFloating ? stopFloating : null,
      topWidget: _shouldShowTopWidget
          ? IgnorePointer(
              ignoring: isFloating,
              child: Builder(
                builder: (context) => widget.builder(context, isFloating),
              ),
            )
          : null,
      floatingHeight: widget.floatingHeight,
      floatingWidth: widget.floatingWidth,
      initialCorner: widget.initialCorner,
      padding: widget.padding,
    );
  }
}
