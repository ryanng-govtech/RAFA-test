import 'package:flutter/material.dart';

import '../contants.dart';

class CheckboxListTileFormField extends FormField<bool> {
  CheckboxListTileFormField({
    Key? key,
    FormFieldValidator<bool>? validator,
    bool initialValue = false,
    FormFieldSetter<int>? onSaved,
    Color? activeColor,
    Color? checkColor,
    Widget? title,
    Widget? subtitle,
    bool selected = false,
    ValueChanged<bool?>? onChanged,
  }) : super(
          key: key,
          validator: validator,
          initialValue: initialValue,
          builder: (state) {
            return Column(
              children: [
                CheckboxListTile(
                    activeColor: activeColor,
                    checkColor: checkColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: title,
                    subtitle: subtitle,
                    selected: state.value ?? false,
                    value: state.value,
                    onChanged: (value) {
                      state.didChange(value);
                      if (onChanged != null) {
                        onChanged(value);
                      }
                      ;
                    }),
                if (state.hasError)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        state.errorText!,
                        maxLines: 3,
                        style: TextStyle(
                            color: kRed,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
              ],
            );
          },
        );
}
