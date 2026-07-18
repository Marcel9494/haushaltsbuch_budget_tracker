import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_helper.dart';

import '../../../../../data/enums/amount_type.dart';
import '../../../../../data/enums/booking_type.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../bookings/presentation/widgets/bottom_sheets/show_amount_type_bottom_sheet.dart';
import '../../../../bookings/presentation/widgets/buttons/grid_item_button.dart';
import '../deco/bottom_sheet_line.dart';

class AmountInputField extends StatefulWidget {
  final TextEditingController amountController;
  final BookingType bookingType;
  final AmountType amountType;
  final ValueChanged<AmountType> onAmountTypeChanged;
  final ValueChanged<double>? onAmountChanged;
  final String text;
  final bool showMinus;
  final bool autofocus;

  const AmountInputField({
    super.key,
    required this.amountController,
    required this.bookingType,
    required this.onAmountTypeChanged,
    this.amountType = AmountType.none,
    this.onAmountChanged,
    this.text = 'amount',
    this.showMinus = false,
    this.autofocus = false,
  });

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  late FocusNode _focusNode;
  late bool _isFirstInput;
  late AmountType _selectedAmountType;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _isFirstInput = true;
    _selectedAmountType = widget.amountType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAmountTypeChanged(_selectedAmountType);

      if (widget.autofocus) {
        _focusNode.requestFocus();

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _openAmountBottomSheet();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(AmountInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bookingType != oldWidget.bookingType) {
      if (widget.bookingType == BookingType.expense) {
        _selectedAmountType = AmountType.variable;
      } else if (widget.bookingType == BookingType.income) {
        _selectedAmountType = AmountType.active;
      } else {
        _selectedAmountType = AmountType.none;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAmountTypeChanged(_selectedAmountType);
      });
    }
  }

  String? _checkAmountInput() {
    final t = AppLocalizations.of(context);
    String amountInput = widget.amountController.text.trim();
    if (amountInput.isEmpty) {
      return t.translate('empty_${widget.text}_error');
    }
    return null;
  }

  String _formatAmountNumber(String input) {
    if (input.isEmpty) {
      return '';
    }

    input = input.replaceAll('.', '').replaceAll(',', '.');
    double? value = double.tryParse(input);
    if (value == null) {
      return widget.amountController.text;
    }

    // Beispiel: 1234.56 → 1.234,56
    String formatted = value.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String integer = parts[0];
    String decimals = parts[1];

    if (integer.length > 8) {
      integer = integer.substring(0, 8);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < integer.length; i++) {
      int position = integer.length - i;
      buffer.write(integer[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()},$decimals €';
  }

  void _addAmountInput(String value) {
    if (_isFirstInput) {
      widget.amountController.clear();
      _isFirstInput = false;
    }

    String text = widget.amountController.text.replaceAll(' €', '');

    if (value == '-') {
      if (text.isEmpty) {
        widget.amountController.text = '-';
      }
      return;
    }

    if (value == ',') {
      if (text.contains(',')) {
        return;
      }

      if (text.isEmpty) {
        widget.amountController.text = '0,';
        return;
      }

      widget.amountController.text += ',';
      return;
    }

    if (RegExp(r'\d').hasMatch(value)) {
      String integerPart = text.contains(',') ? text.split(',')[0] : text;
      String decimalPart = text.contains(',') ? text.split(',')[1] : '';
      // Prüfen: max 2 Nachkommastellen
      if (text.contains(',') && decimalPart.length >= 2) {
        return;
      }

      // Prüfen: max 10 Ziffern insgesamt
      if (integerPart.length + decimalPart.length >= 10) {
        return;
      }

      // Führende Null korrigieren
      if (text == '0' && value != ',') {
        text = value;
      } else {
        text += value;
      }

      widget.amountController.text += value;
    }
  }

  void _clearAmountInput() {
    final text = widget.amountController.text;
    if (text.isNotEmpty) {
      widget.amountController.text = text.substring(0, text.length - 1);
    }
  }

  void _finalizeAmountInputFormat() {
    String text = widget.amountController.text;

    if (text.isEmpty || text == ',' || text == '0,' || text == '0' || text == '-') {
      widget.amountController.text = '0,00 €';
      return;
    }

    widget.amountController.text = _formatAmountNumber(text.replaceAll('.', ''));
    if (widget.onAmountChanged != null) {
      widget.onAmountChanged!(parseAmount(widget.amountController.text));
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
          child: Text(t.translate(widget.text), style: TextStyle(fontSize: 14.0)),
        ),
        TextFormField(
          controller: widget.amountController,
          readOnly: true,
          showCursor: true,
          focusNode: _focusNode,
          validator: (amountInput) => _checkAmountInput(),
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
            hintText: '${t.translate(widget.text)}...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12, top: 12),
              child: const FaIcon(FontAwesomeIcons.moneyBill1, size: 22.0),
            ),
            suffixIcon: widget.bookingType.name != BookingType.transfer.name
                ? SizedBox(
                    width: 126.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 24,
                          width: 1.3,
                          color: Colors.white30,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => ShowAmountTypeBottomSheet.show(
                              context,
                              selected: _selectedAmountType,
                              bookingType: widget.bookingType,
                              onChanged: (newAmountType) {
                                setState(() {
                                  _selectedAmountType = newAmountType;
                                  widget.onAmountTypeChanged(newAmountType);
                                });
                              },
                            ),
                            child: Text(t.translate(_selectedAmountType.name)),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ShowAmountTypeBottomSheet.show(
                            context,
                            selected: _selectedAmountType,
                            bookingType: widget.bookingType,
                            onChanged: (newAmountType) {
                              setState(() {
                                _selectedAmountType = newAmountType;
                                widget.onAmountTypeChanged(newAmountType);
                              });
                            },
                          ),
                          icon: const FaIcon(FontAwesomeIcons.scaleBalanced, size: 20.0),
                        ),
                      ],
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      widget.amountController.clear();
                    },
                    icon: const Icon(Icons.clear_rounded, size: 22.0),
                  ),
            counterText: '',
          ),
          onTap: _openAmountBottomSheet,
        ),
      ],
    );
  }

  void _openAmountBottomSheet() {
    _isFirstInput = true;
    final t = AppLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BottomSheetLine(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${t.translate('enter_${widget.text}')}:',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
                children: [
                  // Erste Zeile
                  GridItemButton(text: '1', onTap: () => _addAmountInput('1')),
                  GridItemButton(text: '2', onTap: () => _addAmountInput('2')),
                  GridItemButton(text: '3', onTap: () => _addAmountInput('3')),
                  GridItemButton(icon: Icons.clear_rounded, color: Colors.cyanAccent, iconSize: 32, onTap: () => widget.amountController.clear()),
                  // Zweite Zeile
                  GridItemButton(text: '4', onTap: () => _addAmountInput('4')),
                  GridItemButton(text: '5', onTap: () => _addAmountInput('5')),
                  GridItemButton(text: '6', onTap: () => _addAmountInput('6')),
                  GridItemButton(icon: Icons.backspace_rounded, color: Colors.cyanAccent, onTap: () => _clearAmountInput()),
                  // Dritte Zeile
                  GridItemButton(text: '7', onTap: () => _addAmountInput('7')),
                  GridItemButton(text: '8', onTap: () => _addAmountInput('8')),
                  GridItemButton(text: '9', onTap: () => _addAmountInput('9')),
                  GridItemButton(icon: Icons.check_rounded, color: Colors.greenAccent, iconSize: 32, onTap: () => Navigator.pop(context)),
                  // Vierte Zeile
                  GridItemButton(text: widget.showMinus == true ? '-' : '', onTap: widget.showMinus == true ? () => _addAmountInput('-') : () {}),
                  GridItemButton(text: '0', onTap: () => _addAmountInput('0')),
                  GridItemButton(text: ',', onTap: () => _addAmountInput(',')),
                  GridItemButton(text: '', onTap: () {}),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _finalizeAmountInputFormat();
      _focusNode.unfocus();
    });
  }
}
