import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/features/search/models/search_result.dart';
import 'package:wolfchat/features/search/viewmodels/search_viewmodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HeroIcon(
            HeroIcons.arrowLeft,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Buscar conversas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _SearchInput(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (query) {
              context.read<SearchViewModel>().search(query);
            },
          ),
          const Expanded(child: _SearchResultsList()),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar nas conversas...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: HeroIcon(
                HeroIcons.magnifyingGlass,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const HeroIcon(
                      HeroIcons.xMark,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList();
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.brand500,
            ),
          );
        }
        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HeroIcon(
                  HeroIcons.exclamationTriangle,
                  size: 48,
                  color: AppColors.brand500,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao carregar conversas',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    viewModel.errorMessage ?? 'Erro desconhecido',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    viewModel.clearError();
                    await viewModel.search(viewModel.query);
                  },
                  icon: const HeroIcon(
                    HeroIcons.arrowPath,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Tentar novamente',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceCard,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }
        if (viewModel.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeroIcon(
                  viewModel.query.isEmpty
                      ? HeroIcons.clock
                      : HeroIcons.magnifyingGlass,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.query.isEmpty
                      ? 'Nenhuma conversa recente'
                      : 'Nenhum resultado encontrado',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: viewModel.results.length,
          itemBuilder: (context, index) {
            final result = viewModel.results[index];
            return _SearchResultItem(
              result: result,
              onTap: () {
                context.go('/chat/${result.conversationId}');
              },
            );
          },
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({
    required this.result,
    required this.onTap,
  });
  final SearchResult result;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.surfaceHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: HeroIcon(
                    HeroIcons.chatBubbleLeft,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.preview,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
