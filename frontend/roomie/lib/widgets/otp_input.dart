import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/colors.dart';

class OtpInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final int codeLength;
  final void Function(String value, int index) onChanged;
  final void Function(KeyEvent event, int index) onKeyEvent;

  const OtpInput({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
    this.codeLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            codeLength,
            (i) => _OtpBox(
              controller: controllers[i],
              focusNode: focusNodes[i],
              hasError: hasError,
              onChanged: (v) => onChanged(v, i),
              onKeyEvent: (e) => onKeyEvent(e, i),
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: hasError ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error_outline_rounded, size: 14, color: RColors.errorText),
                SizedBox(width: 5),
                Text(
                  'invalid code, please try again',
                  style: TextStyle(fontSize: 12, color: RColors.errorText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 44,
        height: 54,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: RColors.text,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: focusNode.hasFocus ? RColors.primaryLight : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? RColors.error : RColors.border,
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: RColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: RColors.error, width: 1.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}