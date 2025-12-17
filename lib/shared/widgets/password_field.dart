import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class PasswordField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final String referenceName;

  const PasswordField({
    super.key,
    this.hintText,
    this.labelText,
    this.initialValue,
    required this.referenceName,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.referenceName,
      initialValue: widget.initialValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Senha',
        hintText: widget.hintText ?? 'Digite sua senha',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      obscureText: _obscurePassword,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Campo obrigatório'),
        FormBuilderValidators.minLength(
          6,
          errorText: 'Senha deve ter no mínimo 6 caracteres',
        ),
      ]),
    );
  }
}
