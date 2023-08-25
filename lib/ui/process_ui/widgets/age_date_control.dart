import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:registration_client/pigeon/biometrics_pigeon.dart';
import 'package:registration_client/provider/registration_task_provider.dart';
import 'package:registration_client/utils/app_style.dart';

import '../../../model/field.dart';
import '../../../provider/global_provider.dart';
import 'custom_label.dart';

class AgeDateControl extends StatefulWidget {
  const AgeDateControl(
      {super.key, required this.validation, required this.field});

  final RegExp validation;
  final Field field;

  @override
  State<AgeDateControl> createState() => _AgeDateControlState();
}

class _AgeDateControlState extends State<AgeDateControl> {
  TextEditingController _dayController = TextEditingController();

  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  final dayFocus = FocusNode();
  final monthFocus = FocusNode();
  final yearFocus = FocusNode();

  @override
  void initState() {
    _getSavedDate();
    super.initState();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();

    dayFocus.dispose();
    monthFocus.dispose();
    yearFocus.dispose();

    super.dispose();
  }

  void focusNextField(FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _removeFocusFromAll(String currentTab) {
    switch (currentTab) {
      case "day":
        monthFocus.unfocus();
        yearFocus.unfocus();
        break;
      case "month":
        dayFocus.unfocus();
        yearFocus.unfocus();
        break;
      case "year":
        dayFocus.unfocus();
        monthFocus.unfocus();
        break;
      default:
    }
  }

  int calculateYearDifference(DateTime date1, DateTime date2) {
    int yearDifference = date2.year - date1.year;
    if (date1.month > date2.month ||
        (date1.month == date2.month && date1.day > date2.day)) {
      yearDifference--;
    }
    return yearDifference;
  }

  _calculateAgeFromDOB() {
    DateTime date = DateTime.parse(
        "${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}");
    DateTime currentDate = DateTime.now();
    if (date.compareTo(currentDate) < 0) {
      _ageController.text =
          calculateYearDifference(date, currentDate).abs().toString();
    } else {
      _ageController.text = "";
    }
  }

  String? fieldValidation(value, message) {
    try {
      String targetDateString = widget.field.format ??
          "yyyy/MM/dd"
              .replaceAll('dd', _dayController.text.padLeft(2, '0'))
              .replaceAll('MM', _monthController.text.padLeft(2, '0'))
              .replaceAll('yyyy', _yearController.text);

      if (value == "") {
        return 'Empty';
      }
      if (!widget.validation.hasMatch(targetDateString)) {
        return message;
      }
      return null;
    } catch (e) {
      log("error");
      return "";
    }
  }

  _invalidDateText() {
    DateTime date = DateTime.parse(
        "${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}");
    DateTime currentDate = DateTime.now();
    if (date.compareTo(currentDate) > 0) {
      return "Invalid date!";
    }
    return null;
  }

  void saveData() {
    String targetDateString = widget.field.format ??
        "yyyy/MM/dd"
            .replaceAll('dd', _dayController.text.padLeft(2, '0'))
            .replaceAll('MM', _monthController.text.padLeft(2, '0'))
            .replaceAll('yyyy', _yearController.text);

    context.read<RegistrationTaskProvider>().setDateField(
          widget.field.id ?? "",
          widget.field.subType ?? "",
          _dayController.text.padLeft(2, '0'),
          _monthController.text.padLeft(2, '0'),
          _yearController.text,
        );
    context.read<GlobalProvider>().setInputMapValue(
          widget.field.id!,
          targetDateString,
          context.read<GlobalProvider>().fieldInputValue,
        );
    BiometricsApi().getAgeGroup().then((value) {
      context.read<GlobalProvider>().ageGroup = value;
    });
  }

  void _getSavedDate() {
    if (context
        .read<GlobalProvider>()
        .fieldInputValue
        .containsKey(widget.field.id)) {
      String targetDateFormat = widget.field.format ?? "yyyy/MM/dd";

      String savedDate =
          context.read<GlobalProvider>().fieldInputValue[widget.field.id];
      DateTime parsedDate = DateFormat(targetDateFormat).parse(savedDate);
      _dayController.text = parsedDate.day.toString().padLeft(2, '0');
      _monthController.text = parsedDate.month.toString().padLeft(2, '0');
      _yearController.text = parsedDate.year.toString();
      _ageController.text = calculateYearDifference(
              DateTime.parse(
                  "${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}"),
              DateTime.now())
          .abs()
          .toString();
    }
  }

  void _getDateFromAge(String value) {
    int age = int.parse(value);
    DateTime currentDate = DateTime.now();
    DateTime calculatedDate = DateTime(currentDate.year - age, 1, 1);
    _dayController.text = calculatedDate.day.toString().padLeft(2, '0');
    _monthController.text = calculatedDate.month.toString().padLeft(2, '0');
    _yearController.text = calculatedDate.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomLabel(field: widget.field),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextFormField(
                        onTap: () => _removeFocusFromAll("day"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          String? valid = fieldValidation(value, "dd");
                          if (valid == null) {
                            return _invalidDateText();
                          }
                          return valid;
                        },
                        onChanged: (value) {
                          if (value.length == 2 &&
                              _monthController.text.length == 2 &&
                              _yearController.text.length == 4) {
                            _calculateAgeFromDOB();
                          } else {
                            _ageController.text = "";
                          }
                          if (value.length >= 2) {
                            focusNextField(dayFocus, monthFocus);
                          }
                          saveData();
                        },
                        maxLength: 2,
                        focusNode: dayFocus,
                        keyboardType: TextInputType.number,
                        controller: _dayController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          hintStyle: TextStyle(
                              color: AppStyle.appBlackShade3, fontSize: 14),
                          counterText: "",
                          hintText: 'DD',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xff9B9B9F), width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: TextFormField(
                        onTap: () => _removeFocusFromAll("month"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          String? valid = fieldValidation(value, "MM");
                          if (valid == null) {
                            return _invalidDateText();
                          }
                          return valid;
                        },
                        onChanged: (value) {
                          if (value.length == 2 &&
                              _monthController.text.length == 2 &&
                              _yearController.text.length == 4) {
                            _calculateAgeFromDOB();
                          } else {
                            _ageController.text = "";
                          }
                          if (value.length >= 2) {
                            focusNextField(monthFocus, yearFocus);
                          }
                          saveData();
                        },
                        maxLength: 2,
                        focusNode: monthFocus,
                        keyboardType: TextInputType.number,
                        controller: _monthController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          hintStyle: TextStyle(
                              color: AppStyle.appBlackShade3, fontSize: 14),
                          counterText: "",
                          hintText: 'MM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xff9B9B9F), width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: TextFormField(
                        validator: (value) {
                          String? valid = fieldValidation(value, "yyyy");
                          if (valid == null) {
                            return _invalidDateText();
                          }
                          return valid;
                        },
                        onChanged: (value) {
                          if (value.length == 4 &&
                              _dayController.text.length == 2 &&
                              _monthController.text.length == 2) {
                            _calculateAgeFromDOB();
                          } else {
                            _ageController.text = "";
                          }
                          saveData();
                        },
                        onTap: () => _removeFocusFromAll("year"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        maxLength: 4,
                        focusNode: yearFocus,
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          hintStyle: TextStyle(
                              color: AppStyle.appBlackShade3, fontSize: 14),
                          counterText: "",
                          hintText: 'YYYY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xff9B9B9F), width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text("OR"),
                    const SizedBox(width: 12),
                    Flexible(
                      child: TextFormField(
                        // readOnly: true,
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if(value != "") {
                            _getDateFromAge(value);
                            saveData();
                          } else {
                            _dayController.text = "";
                            _monthController.text = "";
                            _yearController.text = "";
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          hintStyle: TextStyle(
                              color: AppStyle.appBlackShade3, fontSize: 14),
                          hintText: 'Age',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xff9B9B9F), width: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}