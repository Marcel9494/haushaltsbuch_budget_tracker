import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/buttons/add_button.dart';

import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../blocs/category/category_state.dart';
import '../../../../../data/models/category.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../categories/data/enums/category_type.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../buttons/grid_item_button.dart';

class CategorieInputField extends StatefulWidget {
  final TextEditingController categorieController;
  final BookingType bookingType;
  final ValueChanged<Category> onCategorieChanged;

  const CategorieInputField({
    super.key,
    required this.categorieController,
    required this.bookingType,
    required this.onCategorieChanged,
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
    final t = AppLocalizations.of(context);
    String categorieInput = widget.categorieController.text.trim();
    if (categorieInput.isEmpty) {
      return t.translate('empty_categorie_error');
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
            filteredCategories = state.categories.where((category) => category.categoryType.name.contains(CategoryType.expenses.name)).toList()
              ..sort((a, b) => a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
          } else if (widget.bookingType == BookingType.income) {
            filteredCategories = state.categories.where((category) => category.categoryType.name.contains(CategoryType.revenue.name)).toList()
              ..sort((a, b) => a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(t.translate('category'), style: TextStyle(fontSize: 16.0)),
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
                  suffixIcon: Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
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
                      final double bottomSheetHeight = screenHeight * 0.56;
                      final double gridHeight = bottomSheetHeight * 0.56;
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
                                  SizedBox(
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
                                  const SizedBox(height: 6),
                                  const Divider(),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: AddButton(
                                        text: t.translate('create_category'),
                                        onPressed: () {},
                                      ),
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
