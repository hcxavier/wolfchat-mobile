import 'package:flutter/foundation.dart';
import '../models/home_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _loadData();
  }

  final HomeModel _model = const HomeModel();
  bool _isLoading = false;
  bool _isSidebarOpen = false;
  bool _isSettingsModalOpen = false;
  String _userName = 'Usuário';

  HomeModel get model => _model;
  bool get isLoading => _isLoading;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isSettingsModalOpen => _isSettingsModalOpen;
  String get userName => _userName;

  void _loadData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void closeSidebar() {
    _isSidebarOpen = false;
    notifyListeners();
  }

  void openSettingsModal() {
    _isSettingsModalOpen = true;
    notifyListeners();
  }

  void closeSettingsModal() {
    _isSettingsModalOpen = false;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void onGetStartedPressed() {
    // TODO: Implementar navegação para tela principal do chat
  }

  void onLearnMorePressed() {
    // TODO: Implementar navegação para tela de informações
  }
}
