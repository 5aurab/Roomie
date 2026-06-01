import 'package:flutter/material.dart';
import '../themes/colors.dart';
import 'field_labels.dart';
import 'field_error.dart';

class RoomieDobPicker extends StatefulWidget {
  final DateTime? selectedDob;
  final String? error;
  final ValueChanged<DateTime> onChanged;

  const RoomieDobPicker({
    super.key,
    required this.onChanged,
    this.selectedDob,
    this.error,
  });

  @override
  State<RoomieDobPicker> createState() => _RoomieDobPickerState();
}

class _RoomieDobPickerState extends State<RoomieDobPicker> {
  String _formatDob(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / '
      '${d.month.toString().padLeft(2, '0')} / '
      '${d.year}';

  Future<void> _open() async {
    DateTime? tempSelected = widget.selectedDob;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: RoomieColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ──────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: RoomieColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Title ────────────────────────────────────────────────
                  const Text(
                    'date of birth',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: RoomieColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'you must be 18 or older to use roomie',
                    style: TextStyle(
                      fontSize: 12,
                      color: RoomieColors.hint,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Calendar ─────────────────────────────────────────────
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: RoomieColors.primary,
                            onPrimary: Colors.white,
                            onSurface: RoomieColors.text,
                            surface: RoomieColors.bg,
                          ),
                      textTheme: Theme.of(context).textTheme.copyWith(
                            bodyMedium: const TextStyle(
                              fontSize: 13,
                              color: RoomieColors.text,
                            ),
                          ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: RoomieColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate:
                          tempSelected ?? DateTime(DateTime.now().year - 20),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(
                        DateTime.now().year - 18,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                      onDateChanged: (date) {
                        setModalState(() => tempSelected = date);
                      },
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Divider(color: RoomieColors.border, thickness: 0.5),
                  const SizedBox(height: 16),

                  // ── Actions ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: RoomieColors.border,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'cancel',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: RoomieColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (tempSelected != null) {
                              widget.onChanged(tempSelected!);
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tempSelected != null
                                  ? RoomieColors.primary
                                  : RoomieColors.primaryMid,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'confirm →',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoomieFieldLabel('date of birth'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _open,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: widget.error != null
                    ? RoomieColors.error
                    : RoomieColors.border,
                width: widget.error != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: widget.selectedDob != null
                      ? RoomieColors.primary
                      : RoomieColors.hint,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.selectedDob != null
                      ? _formatDob(widget.selectedDob!)
                      : 'dd / mm / yyyy',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.selectedDob != null
                        ? RoomieColors.text
                        : RoomieColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 5),
          RoomieFieldError(message: widget.error!),
        ],
      ],
    );
  }
}