import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/auth_session.dart';
import '../feature/auth/repository/auth_repository.dart';
import '../feature/auth/view/auth_view_model.dart';
import '../feature/home/page/home_page.dart';
import '../feature/item/repository/item_repository.dart';
import '../feature/item/viewmodel/item_view_model.dart';

class MuralApp extends StatefulWidget {
  const MuralApp({super.key});

  @override
  State<MuralApp> createState() => _MuralAppState();
}

class _MuralAppState extends State<MuralApp> {
  late final ApiClient _apiClient;
  late final AuthSession _session;
  late final AuthViewModel _authViewModel;
  late final ItemViewModel _itemViewModel;

  @override
  void initState() {
    super.initState();

    _session = AuthSession();

    _apiClient = ApiClient(session: _session);

    _authViewModel = AuthViewModel(
      HttpAuthRepository(_apiClient),
      _session,
    );

    _itemViewModel = ItemViewModel(
      HttpItemRepository(_apiClient),
    );
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _itemViewModel.dispose();
    _apiClient.close();
    _session.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mural FYI — Achados e Perdidos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B60),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: HomePage(
        authViewModel: _authViewModel,
        itemViewModel: _itemViewModel,
      ),
    );
  }
}