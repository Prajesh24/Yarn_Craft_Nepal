import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/yarn_bottom_nav.dart';

final currentTabProvider =
    NotifierProvider<TabNotifier, NavTab>(() => TabNotifier());

class TabNotifier extends Notifier<NavTab> {
  @override
  NavTab build() => NavTab.home;

  void switchTo(NavTab tab) => state = tab;
}
