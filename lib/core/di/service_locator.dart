import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';

abstract final class ServiceLocator {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
  ];
}
