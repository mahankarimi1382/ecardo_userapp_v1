import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CommonSingleDatePicker extends StatefulWidget {
  final String? hintText;
  final Function(DateTime) onDateSelected;
  final DateTime? initialDate;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final Color? fillColor;
  final double? verticalPadding;
  final double? topLeftBorderRadius;
  final double? topRightBorderRadius;
  final double? bottomLeftBorderRadius;
  final double? bottomRightBorderRadius;
  final double? borderRadius;
  final FocusNode? focusNode;
  final bool isFocused;
  final bool? isBorderShow;
  final bool isSuffixIconCompact;
  final bool? isSuffixIconOnTap;
  final Function()? suffixIconOnTap;
  final double? suffixIconWidth;
  final double? suffixIconHeight;

  const CommonSingleDatePicker({
    super.key,
    this.hintText,
    required this.onDateSelected,
    this.initialDate,
    this.suffixIcon,
    this.suffixIconColor,
    this.fillColor,
    this.verticalPadding = 18,
    this.topLeftBorderRadius,
    this.topRightBorderRadius,
    this.bottomLeftBorderRadius,
    this.bottomRightBorderRadius,
    this.borderRadius,
    this.focusNode,
    this.isFocused = false,
    this.isBorderShow = true,
    this.isSuffixIconCompact = true,
    this.isSuffixIconOnTap,
    this.suffixIconOnTap,
    this.suffixIconWidth,
    this.suffixIconHeight,
  });

  @override
  State<CommonSingleDatePicker> createState() => _CommonSingleDatePickerState();
}

class _CommonSingleDatePickerState extends State<CommonSingleDatePicker> {
  late final bool isDarkMode;
  late DateTime _selectedDay;
  late TextEditingController _dateController;

  final DateFormat dateFormat = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate ?? DateTime.now();
    _dateController = TextEditingController(
      text: widget.initialDate != null
          ? dateFormat.format(widget.initialDate!)
          : '',
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = widget.isFocused
        ? AppColors.lightPrimary.withValues(alpha: 0.60)
        : AppColors.lightTextPrimary.withValues(alpha: 0.2);

    Widget? processedSuffixIcon = widget.suffixIcon;
    if (widget.suffixIcon != null && widget.isFocused) {
      if (widget.suffixIcon is Image) {
        final image = widget.suffixIcon as Image;
        processedSuffixIcon = ColorFiltered(
          colorFilter: ColorFilter.mode(
            AppColors.lightPrimary,
            BlendMode.srcIn,
          ),
          child: image,
        );
      }
    }

    return TextFormField(
      style: TextStyle(
        fontSize: 16,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0,
        height: 1.1,
        fontWeight: FontWeight.w600,
      ),
      controller: _dateController,
      focusNode: widget.focusNode,
      onTap: () async {
        if (widget.focusNode != null) {
          widget.focusNode!.requestFocus();
        }
        await _selectDate(context, _selectedDay, _dateController);
        if (widget.focusNode != null) {
          widget.focusNode!.unfocus();
        }
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIconConstraints: widget.isSuffixIconCompact
            ? const BoxConstraints(minWidth: 20, minHeight: 20)
            : null,
        fillColor: AppColors.transparent,
        filled: true,
        hintText: widget.hintText,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.verticalPadding ?? 17,
        ),
        hintStyle: TextStyle(
          letterSpacing: 0,
          color: AppColors.lightTextTertiary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 1.1,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _getBorderRadius(context),
          borderSide: widget.isBorderShow == true
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _getBorderRadius(context),
          borderSide: widget.isBorderShow == true
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        suffixIcon: processedSuffixIcon != null
            ? (widget.isSuffixIconOnTap == true
                  ? GestureDetector(
                      onTap: widget.suffixIconOnTap,
                      child: widget.isSuffixIconCompact
                          ? Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 8,
                                end: 12,
                              ),
                              child: SizedBox(
                                width: widget.suffixIconWidth ?? 16,
                                height: widget.suffixIconHeight ?? 16,
                                child: processedSuffixIcon,
                              ),
                            )
                          : SizedBox(
                              width: widget.suffixIconWidth ?? 16,
                              height: widget.suffixIconHeight ?? 16,
                              child: processedSuffixIcon,
                            ),
                    )
                  : (widget.isSuffixIconCompact
                        ? Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 8,
                              end: 12,
                            ),
                            child: SizedBox(
                              width: widget.suffixIconWidth ?? 16,
                              height: widget.suffixIconHeight ?? 16,
                              child: processedSuffixIcon,
                            ),
                          )
                        : SizedBox(
                            width: widget.suffixIconWidth ?? 16,
                            height: widget.suffixIconHeight ?? 16,
                            child: processedSuffixIcon,
                          )))
            : null,
      ),
      keyboardType: TextInputType.datetime,
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime selectedDate,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showRoundedDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.utc(1990, 1, 1),
      lastDate: DateTime.utc(2030, 12, 31),
      borderRadius: 16,
      height: MediaQuery.of(context).size.height * 0.35,
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: AppColors.lightPrimary),
      ),
      styleDatePicker: MaterialRoundedDatePickerStyle(
        textStyleYearButton: TextStyle(
          letterSpacing: 0,
          color: AppColors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
        textStyleDayButton: TextStyle(
          letterSpacing: 0,
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        textStyleButtonPositive: TextStyle(
          letterSpacing: 0,
          color: AppColors.lightPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        textStyleButtonNegative: TextStyle(
          letterSpacing: 0,
          color: AppColors.lightPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        backgroundHeader: AppColors.lightPrimary,
        textStyleCurrentDayOnCalendar: TextStyle(
          letterSpacing: 0,
          color: AppColors.lightPrimary,
        ),
        textStyleDayOnCalendarSelected: TextStyle(
          letterSpacing: 0,
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        _selectedDay = picked;
        widget.onDateSelected(picked);
        controller.text = dateFormat.format(picked);
      });
    }
  }

  BorderRadius _getBorderRadius(BuildContext context) {
    final baseRadius = widget.borderRadius ?? 16;

    final topLeft = widget.topLeftBorderRadius ?? baseRadius;
    final topRight = widget.topRightBorderRadius ?? baseRadius;
    final bottomLeft = widget.bottomLeftBorderRadius ?? baseRadius;
    final bottomRight = widget.bottomRightBorderRadius ?? baseRadius;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return BorderRadius.only(
      topLeft: Radius.circular(isRtl ? topRight : topLeft),
      topRight: Radius.circular(isRtl ? topLeft : topRight),
      bottomLeft: Radius.circular(isRtl ? bottomRight : bottomLeft),
      bottomRight: Radius.circular(isRtl ? bottomLeft : bottomRight),
    );
  }
}
