import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_type.dart';

import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/category/category_state.dart';
import '../../../../../data/enums/category_type.dart';
import '../../../../../data/models/category.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/deco/bottom_sheet_line.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/empty_list.dart';
import '../buttons/grid_item_button.dart';

class CategorieInputField extends StatefulWidget {
  final TextEditingController categorieController;
  final BookingType bookingType;
  final ValueChanged<Category?> onCategorieChanged;
  final bool isOptional;

  const CategorieInputField({
    super.key,
    required this.categorieController,
    required this.bookingType,
    required this.onCategorieChanged,
    this.isOptional = false,
  });

  @override
  State<CategorieInputField> createState() => _CategorieInputFieldState();
}

class _CategorieInputFieldState extends State<CategorieInputField> {
  late final CategoryBloc _categoryBloc;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _categoryBloc = context.read<CategoryBloc>();
    _focusNode = FocusNode();
  }

  String? _checkCategorieInput() {
    if (widget.isOptional) {
      return null;
    }
    final t = AppLocalizations.of(context);
    String categorieInput = widget.categorieController.text.trim();
    if (categorieInput.isEmpty) {
      return t.translate('empty_category_error');
    }
    return null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return CircularLoadingIndicator();
        } else if (state is CategoryListLoaded) {
          List<Category> filteredCategories = [];
          if (widget.bookingType == BookingType.expense) {
            filteredCategories = state.categories
                .where((category) => category.categoryType.pluralName.contains(CategoryType.expense.pluralName))
                .toList()
              ..sort((a, b) => a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
          } else if (widget.bookingType == BookingType.income) {
            filteredCategories = state.categories
                .where((category) => category.categoryType.pluralName.contains(CategoryType.income.pluralName))
                .toList()
              ..sort((a, b) => a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
                child: Text(t.translate('category'), style: TextStyle(fontSize: 14.0)),
              ),
              TextFormField(
                controller: widget.categorieController,
                readOnly: true,
                focusNode: _focusNode,
                validator: (categorieInput) => _checkCategorieInput(),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.black87,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                  hintText: '${t.translate('category')}...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12, top: 12),
                    child: const FaIcon(FontAwesomeIcons.grip, size: 22.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      widget.categorieController.text = '';
                      widget.onCategorieChanged(null);
                    },
                    icon: const Icon(Icons.clear_rounded, size: 22.0),
                  ),
                  counterText: '',
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    builder: (context) {
                      final double screenHeight = MediaQuery.of(context).size.height;
                      final double bottomSheetHeight = screenHeight * 0.48;
                      final double gridHeight = bottomSheetHeight * 0.68;
                      return BlocProvider.value(
                        value: _categoryBloc,
                        child: SafeArea(
                          child: SizedBox(
                            height: bottomSheetHeight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BottomSheetLine(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${t.translate('select_category')}:',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 28),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  filteredCategories.isEmpty
                                      ? EmptyList(
                                          text: 'no_categories',
                                          icon: Icon(
                                            FontAwesomeIcons.grip,
                                            size: 48.0,
                                            color: Colors.white70,
                                          ))
                                      : SizedBox(
                                          height: gridHeight,
                                          child: GridView.count(
                                            crossAxisCount: 4,
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            mainAxisSpacing: 6,
                                            crossAxisSpacing: 0,
                                            childAspectRatio: 1.3,
                                            children: filteredCategories.map((category) {
                                              return GridItemButton(
                                                text: category.categoryName,
                                                textSize: 16,
                                                color: Colors.cyanAccent,
                                                borderRadius: 4,
                                                onTap: () {
                                                  setState(() {
                                                    widget.categorieController.text = category.categoryName;
                                                  });
                                                  widget.onCategorieChanged(category);
                                                  Navigator.pop(context);
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        } else if (state is CategoryError) {
          return Center(child: Text(state.message));
        }
        return SizedBox.shrink();
      },
    );
  }
}
