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
import '../../../../core/utils/app_flushbar.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../data/enums/category_type.dart';
import '../widgets/buttons/category_type_segmented_button.dart';

class CreateCategoryPage extends StatefulWidget {
  CategoryType selectedCategoryType;

  CreateCategoryPage({
    super.key,
    required this.selectedCategoryType,
  });

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final GlobalKey<FormState> _createCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final RoundedLoadingButtonController _createCategoryButtonController = RoundedLoadingButtonController();

  Future<void> _createCategory(BuildContext contextForCategory) async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _createCategoryButtonController.start();

      if (_createCategoryFormKey.currentState!.validate() == false) {
        _createCategoryButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _createCategoryButtonController.reset();
        });
        return;
      }

      final Category newCategory = Category(
        userId: supabase.auth.currentUser!.id,
        categoryName: _categoryNameController.text.trim(),
        categoryType: widget.selectedCategoryType,
      );

      contextForCategory.read<CategoryBloc>().add(CreateCategory(category: newCategory));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _createCategoryButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createCategoryButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _createCategoryButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createCategoryButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _createCategoryButtonController.reset();
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
            if (state is CategoryCreated) {
              _createCategoryButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, categoryListRoute);
              });
            } else if (state is CategoryError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _createCategoryButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _createCategoryButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('create_category')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _createCategoryFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CategoryTypeSegmentedButton(
                          categoryType: widget.selectedCategoryType,
                          onChanged: (CategoryType newCategoryType) {
                            setState(() {
                              widget.selectedCategoryType = newCategoryType;
                            });
                          },
                        ),
                        TitleInputField(titleController: _categoryNameController, text: 'category_name'),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'create_category_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('create_category'),
                            controller: _createCategoryButtonController,
                            onPressed: () => _createCategory(context),
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
