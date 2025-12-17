import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:jusconnect/core/utils/validators.dart';

class CpfField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final String referenceName;

  const CpfField({
    super.key,
    this.hintText,
    this.labelText,
    this.initialValue,
    required this.referenceName,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: referenceName,
      initialValue: initialValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText ?? 'CPF',
        hintText: hintText ?? '000.000.000-00',
        prefixIcon: const Icon(Icons.credit_card),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Campo obrigatório'),
        (value) => Validators.validateCpf(value),
      ]),
    );
  }
}
