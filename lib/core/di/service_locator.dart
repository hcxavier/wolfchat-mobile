import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/search/viewmodels/search_viewmodel.dart';

abstract final class ServiceLocator {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
    ChangeNotifierProvider<SearchViewModel>(create: (_) => SearchViewModel()),
  ];
}

// Pseudo-update for commit 5 at 2026-04-03 13:35:49
