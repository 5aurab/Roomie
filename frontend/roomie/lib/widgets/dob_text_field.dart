import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/colors.dart';
import 'field_labels.dart';

class DobTextField extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final VoidCallback onCalendarTap;
  final bool hasError;
  final bool calOpen;

  const DobTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onCalendarTap,
    this.hasError = false,
    this.calOpen = false,
  });

  @override
  State<DobTextField> createState() => _DobTextFieldState();
}

class _DobTextFieldState extends State<DobTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value != null ? _fmt(widget.value!) : '',
    );
  }

  @override
  void didUpdateWidget(DobTextField old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      final text = widget.value != null ? _fmt(widget.value!) : '';
      if (_ctrl.text != text) {
        _ctrl.text = text;
        _ctrl.selection = TextSelection.collapsed(offset: text.length);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / '
      '${d.month.toString().padLeft(2, '0')} / '
      '${d.year}';

  void _onChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 8) {
      final d = int.tryParse(digits.substring(0, 2));
      final m = int.tryParse(digits.substring(2, 4));
      final y = int.tryParse(digits.substring(4, 8));
      if (d != null && m != null && y != null) {
        try {
          final date = DateTime(y, m, d);
          if (date.day == d && date.month == m) {
            widget.onChanged(date);
            return;
          }
        } catch (_) {}
      }
    }
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? RColors.error
        : widget.calOpen
            ? RColors.primary
            : RColors.border;
    final borderWidth = (widget.calOpen || widget.hasError) ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('date of birth'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [_DobInputFormatter()],
          onChanged: _onChanged,
          style: const TextStyle(fontSize: 13, color: RColors.text),
          decoration: InputDecoration(
            hintText: 'DD / MM / YYYY',
            hintStyle: const TextStyle(fontSize: 13, color: RColors.hint),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            suffixIcon: GestureDetector(
              onTap: widget.onCalendarTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  widget.calOpen
                      ? Icons.calendar_month_rounded
                      : Icons.calendar_today_outlined,
                  size: 18,
                  color: widget.hasError
                      ? RColors.error
                      : RColors.primaryMid,
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.hasError ? RColors.error : RColors.primary,
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
          ),
        ),
      ],
    );
  }
}

class _DobInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue value,
  ) {
    final digits = value.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buf.write(' / ');
      buf.write(digits[i]);
    }
    final out = buf.toString();
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}