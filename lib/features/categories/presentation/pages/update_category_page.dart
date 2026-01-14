import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/category/category_event.dart';
import '../../../../blocs/category/category_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/page_arguments/category_list_page_arguments.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../data/enums/category_type.dart';
import '../widgets/buttons/category_type_segmented_button.dart';

class UpdateCategoryPage extends StatefulWidget {
  final Category category;

  const UpdateCategoryPage({
    super.key,
    required this.category,
  });

  @override
  State<UpdateCategoryPage> createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  final GlobalKey<FormState> _updateCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final RoundedLoadingButtonController _updateCategoryButtonController = RoundedLoadingButtonController();
  late CategoryType _selectedCategoryType;

  @override
  void initState() {
    super.initState();
    _categoryNameController.text = widget.category.categoryName;
    _selectedCategoryType = widget.category.categoryType;
  }

  Future<void> _updateCategory(BuildContext contextForCategory) async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _updateCategoryButtonController.start();

      if (_updateCategoryFormKey.currentState!.validate() == false) {
        _updateCategoryButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _updateCategoryButtonController.reset();
        });
        return;
      }

      final Category updatedCategory = Category(
        id: widget.category.id,
        userId: supabase.auth.currentUser!.id,
        categoryName: _categoryNameController.text.trim(),
        categoryType: _selectedCategoryType,
      );

      contextForCategory.read<CategoryBloc>().add(UpdateCategory(category: updatedCategory));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _updateCategoryButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateCategoryButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _updateCategoryButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateCategoryButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _updateCategoryButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => CategoryBloc(CategoryRepository()),
      child: Builder(builder: (context) {
        return BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryUpdated) {
              _updateCategoryButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(
                  context,
                  categoryListRoute,
                  arguments: CategoryListPageArguments(state.category.categoryType),
                );
              });
            } else if (state is CategoryError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _updateCategoryButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _updateCategoryButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('update_category')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _updateCategoryFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TypeSegmentedButton(
                          type: _selectedCategoryType,
                          onChanged: (CategoryType updatedCategoryType) {
                            setState(() {
                              _selectedCategoryType = updatedCategoryType;
                            });
                          },
                          leftValue: CategoryType.expenses,
                          rightValue: CategoryType.revenue,
                          leftText: CategoryType.expenses.name,
                          rightText: CategoryType.revenue.name,
                        ),
                        TitleInputField(titleController: _categoryNameController, text: 'category_name'),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'update_category_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('save'),
                            controller: _updateCategoryButtonController,
                            onPressed: () => _updateCategory(context),
                            horizontalPadding: 12.0,
                            buttonColor: Colors.cyanAccent,
                            textColor: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
