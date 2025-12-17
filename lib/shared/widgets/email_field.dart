// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EmailField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final String referenceName;

  const EmailField({
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
        labelText: labelText ?? 'E-mail',
        hintText: hintText ?? 'Digite seu e-mail',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.emailAddress,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Campo obrigatório'),
        FormBuilderValidators.email(errorText: 'E-mail inválido'),
      ]),
    );
  }
}
