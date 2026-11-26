import 'package:flutter/material.dart';

import '../../item/model/item_category.dart';
import '../../item/viewmodel/item_view_model.dart';

class MuralHeader extends StatefulWidget {
  const MuralHeader({
    super.key,
    required this.viewModel,
    required this.listMode,
    required this.onModeChanged,
  });

  final ItemViewModel viewModel;
  final bool listMode;
  final ValueChanged<bool> onModeChanged;

  @override
  State<MuralHeader> createState() => _MuralHeaderState();
}

class _MuralHeaderState extends State<MuralHeader> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.text =
        widget.viewModel.currentSearch;

    _locationController.text =
        widget.viewModel.currentLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,

      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff12463e),
                  Color(0xff217e6c),
                ],
              ),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 28,
                ),

                const SizedBox(height: 10),

                Text(
                  'Achados e perdidos',

                  style: theme.textTheme.headlineMedium
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Encontre seus pertences e saiba onde retirá-los.',

                  style: TextStyle(
                    color: Color(0xffe0f2ec),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Card(
            margin: EdgeInsets.zero,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width =
                      constraints.maxWidth >= 600

                          ? (constraints.maxWidth - 12) / 2

                          : constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 10,

                        children: [
                          SizedBox(
                            width: width,

                            child: TextField(
                              controller: _searchController,
                              onChanged: vm.searchItems,

                              decoration:
                              const InputDecoration(
                                labelText: 'Nome ou descrição',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: width,

                            child: TextField(
                              controller: _locationController,
                              onChanged: vm.filterByLocation,

                              decoration:
                              const InputDecoration(
                                labelText: 'Local encontrado',

                                prefixIcon: Icon(
                                  Icons.place_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Categorias',

                    style: theme.textTheme.titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Todas'),

                          selected:
                          vm.currentCategory == null,

                          onSelected: (_) =>
                              vm.filterByCategory(null),
                        ),

                        for (final category
                        in ItemCategory.values) ...[
                          const SizedBox(width: 8),

                          ChoiceChip(
                            label: Text(category.label),

                            selected:
                            vm.currentCategory == category,

                            onSelected: (selected) =>
                                vm.filterByCategory(
                                  selected ? category : null,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (vm.currentSearch.isNotEmpty ||
                      vm.currentLocation.isNotEmpty ||
                      vm.currentCategory != null)

                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _locationController.clear();

                        vm.clearFilters();
                      },

                      icon: const Icon(Icons.clear_all),

                      label: const Text('Limpar filtros'),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 12,
            runSpacing: 8,

            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              Text(
                '${vm.totalElements} '
                    '${vm.totalElements == 1 ? 'objeto' : 'objetos'}',

                style: theme.textTheme.titleMedium
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SegmentedButton<bool>(
                showSelectedIcon: false,

                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.grid_view),
                    label: Text('Grade'),
                  ),

                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.view_list),
                    label: Text('Lista'),
                  ),
                ],

                selected: {widget.listMode},

                onSelectionChanged: (value) =>
                    widget.onModeChanged(value.first),
              ),

              IconButton(
                tooltip: 'Atualizar mural',

                onPressed:
                vm.isLoading ? null : vm.loadItems,

                icon: const Icon(Icons.refresh),
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}