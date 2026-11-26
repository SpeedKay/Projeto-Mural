import 'package:flutter/material.dart';

import '../viewmodel/item_view_model.dart';
import '../model/item_model.dart';
import '../model/item_status.dart';

import 'item_card.dart';

class MuralWidget extends StatelessWidget {
  const MuralWidget({
    super.key,
    required this.viewModel,
    required this.header,
    this.listMode = false,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onRedeem,
  });

  final ItemViewModel viewModel;
  final Widget header;

  final bool listMode;
  final bool canManage;

  final ValueChanged<ItemModel>? onEdit;
  final ValueChanged<ItemModel>? onDelete;
  final ValueChanged<ItemModel>? onRedeem;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,

      builder: (context, _) {
        final items = viewModel.items;

        Widget buildItem(BuildContext context, int index) {
          final item = items[index];

          return ItemCard(
            key: ValueKey(item.itemId),
            item: item,
            listMode: listMode,
            loadPhoto: viewModel.findPhoto,

            isBusy: viewModel.isItemBusy(item.itemId),

            onEdit: canManage && onEdit != null
                ? () => onEdit!(item)
                : null,

            onDelete: canManage && onDelete != null
                ? () => onDelete!(item)
                : null,

            onRedeem: canManage &&
                onRedeem != null &&
                item.status == ItemStatus.unclaimed
                ? () => onRedeem!(item)
                : null,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = width >= 1100
                ? 4
                : width >= 780
                ? 3
                : width >= 500
                ? 2
                : 1;

            return RefreshIndicator(
              onRefresh: viewModel.loadItems,

              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,

                slivers: [
                  SliverToBoxAdapter(
                    child: header,
                  ),

                  if (viewModel.isLoading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(),
                    ),

                  if (viewModel.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),

                        child: Column(
                          children: [
                            Text(
                              viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 10),

                            OutlinedButton.icon(
                              onPressed: viewModel.loadItems,
                              icon: const Icon(Icons.refresh),
                              label: const Text(
                                'Tentar novamente',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

                  else if (items.isEmpty &&
                      !viewModel.isLoading)

                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(36),

                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                            ),

                            SizedBox(height: 12),

                            Text(
                              'Nenhum objeto encontrado.',
                            ),

                            Text(
                              'Tente alterar os filtros.',
                            ),
                          ],
                        ),
                      ),
                    )

                  else if (listMode)

                      SliverPadding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),

                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ),

                              child: buildItem(context, index),
                            ),

                            childCount: items.length,
                          ),
                        ),
                      )

                    else

                      SliverPadding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),

                        sliver: SliverGrid(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 340,
                          ),

                          delegate: SliverChildBuilderDelegate(
                            buildItem,
                            childCount: items.length,
                          ),
                        ),
                      ),

                  if (viewModel.hasMore &&
                      !viewModel.isLoading &&
                      viewModel.errorMessage == null)

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),

                        child: Center(
                          child: OutlinedButton(
                            onPressed: viewModel.loadMore,

                            child: const Text(
                              'Carregar mais objetos',
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}