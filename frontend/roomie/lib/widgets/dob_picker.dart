import 'package:flutter/material.dart';
import '../themes/colors.dart';
import 'field_error.dart';
import 'dob_text_field.dart';
import 'dob_calendar_panel.dart';

class DobPicker extends StatefulWidget {
  final DateTime? selectedDob;
  final String? error;
  final ValueChanged<DateTime?> onChanged;
  final int minAge;

  const DobPicker({
    super.key,
    required this.onChanged,
    this.selectedDob,
    this.error,
    this.minAge = 16,
  });

  @override
  State<DobPicker> createState() => _DobPickerState();
}

class _DobPickerState extends State<DobPicker>
    with SingleTickerProviderStateMixin {
  bool _calOpen = false;
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  DateTime get _maxDate {
    final now = DateTime.now();
    return DateTime(now.year - widget.minAge, now.month, now.day);
  }

  void _toggleCal() {
    setState(() => _calOpen = !_calOpen);
    _calOpen ? _anim.forward() : _anim.reverse();
  }

  void _onTextChanged(DateTime? date) {
    if (date != null && date.isAfter(_maxDate)) return;
    widget.onChanged(date);
  }

  void _onCalendarSelected(DateTime date) {
    setState(() => _calOpen = false);
    _anim.reverse();
    widget.onChanged(date);
  }

  int _calcAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DobTextField(
          value: widget.selectedDob,
          onChanged: _onTextChanged,
          onCalendarTap: _toggleCal,
          calOpen: _calOpen,
          hasError: widget.error != null,
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 5),
          FieldError(message: widget.error!),
        ] else if (widget.selectedDob != null) ...[
          const SizedBox(height: 5),
          Text(
            'age: ${_calcAge(widget.selectedDob!)} years',
            style: const TextStyle(
              fontSize: 11,
              color: RColors.primaryMid,
            ),
          ),
        ],
        if (_calOpen) ...[
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: DobCalendarPanel(
                selectedDate: widget.selectedDob,
                onDateSelected: _onCalendarSelected,
                minAge: widget.minAge,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
