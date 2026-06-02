import 'package:flutter/material.dart';
import '../themes/colors.dart';

class DobCalendarPanel extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int minAge;

  const DobCalendarPanel({
    super.key,
    required this.onDateSelected,
    this.selectedDate,
    this.minAge = 16,
  });

  @override
  State<DobCalendarPanel> createState() => _DobCalendarPanelState();
}

class _DobCalendarPanelState extends State<DobCalendarPanel> {
  late int _viewYear;
  late int _viewMonth;

  late final ScrollController _yearScroll;
  static const double _yearItemH = 38.0;
  static const int _minYear = 1900;

  @override
  void initState() {
    super.initState();
    final maxDate = _maxDate;
    _viewYear = widget.selectedDate?.year ?? maxDate.year;
    _viewMonth = widget.selectedDate?.month ?? maxDate.month;
    _yearScroll = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToYear());
  }

  @override
  void dispose() {
    _yearScroll.dispose();
    super.dispose();
  }

  DateTime get _maxDate {
    final now = DateTime.now();
    return DateTime(now.year - widget.minAge, now.month, now.day);
  }

  bool _isDateAllowed(DateTime d) => !d.isAfter(_maxDate);

  int get _maxYear => _maxDate.year;
  int get _totalYears => _maxYear - _minYear + 1;

  void _scrollToYear() {
    final idx = _maxYear - _viewYear;
    final offset = (idx * _yearItemH) - (_yearItemH * 2);
    _yearScroll.animateTo(
      offset.clamp(0, _yearScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _selectYear(int year) {
    setState(() {
      _viewYear = year;
      final lastDay = DateTime(_viewYear, _viewMonth + 1, 0).day;
      if (widget.selectedDate != null &&
          widget.selectedDate!.day > lastDay) {
        // keep month, just clamp day — handled by day grid
      }
      // clamp month if now beyond max
      final maxD = _maxDate;
      if (_viewYear == maxD.year && _viewMonth > maxD.month) {
        _viewMonth = maxD.month;
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_viewMonth == 1) {
        if (_viewYear > _minYear) {
          _viewMonth = 12;
          _viewYear--;
        }
      } else {
        _viewMonth--;
      }
    });
  }

  void _nextMonth() {
    final next = DateTime(_viewYear, _viewMonth + 1, 1);
    final maxFirst = DateTime(_maxDate.year, _maxDate.month, 1);
    if (!next.isAfter(maxFirst)) {
      setState(() {
        if (_viewMonth == 12) {
          _viewMonth = 1;
          _viewYear++;
        } else {
          _viewMonth++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: RColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      height: 316,
      child: Row(
        children: [
          _YearColumn(
            scrollController: _yearScroll,
            minYear: _minYear,
            maxYear: _maxYear,
            selectedYear: _viewYear,
            itemHeight: _yearItemH,
            totalYears: _totalYears,
            onYearSelected: _selectYear,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: RColors.border,
          ),
          Expanded(
            child: _MonthGrid(
              year: _viewYear,
              month: _viewMonth,
              selectedDate: widget.selectedDate,
              maxDate: _maxDate,
              onPrevMonth: _prevMonth,
              onNextMonth: _nextMonth,
              onDateSelected: widget.onDateSelected,
              isDateAllowed: _isDateAllowed,
            ),
          ),
        ],
      ),
    );
  }
}

class _YearColumn extends StatelessWidget {
  final ScrollController scrollController;
  final int minYear;
  final int maxYear;
  final int selectedYear;
  final double itemHeight;
  final int totalYears;
  final ValueChanged<int> onYearSelected;

  const _YearColumn({
    required this.scrollController,
    required this.minYear,
    required this.maxYear,
    required this.selectedYear,
    required this.itemHeight,
    required this.totalYears,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        child: ListView.builder(
          controller: scrollController,
          itemCount: totalYears,
          itemExtent: itemHeight,
          itemBuilder: (_, i) {
            final year = maxYear - i;
            final isSel = year == selectedYear;
            return GestureDetector(
              onTap: () => onYearSelected(year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                alignment: Alignment.center,
                color: isSel ? RColors.primaryLight : Colors.transparent,
                child: Text(
                  '$year',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSel ? FontWeight.w600 : FontWeight.w400,
                    color: isSel
                        ? RColors.primary
                        : RColors.primaryMid,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final int year;
  final int month;
  final DateTime? selectedDate;
  final DateTime maxDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime) isDateAllowed;

  const _MonthGrid({
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.maxDate,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDateSelected,
    required this.isDateAllowed,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _dow = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  bool get _canGoNext {
    final next = DateTime(year, month + 1, 1);
    final maxFirst = DateTime(maxDate.year, maxDate.month, 1);
    return !next.isAfter(maxFirst);
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          // nav row
          Row(
            children: [
              _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrevMonth),
              Expanded(
                child: Center(
                  child: Text(
                    '${_months[month - 1]} $year',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RColors.primary,
                    ),
                  ),
                ),
              ),
              _NavBtn(
                icon: Icons.chevron_right_rounded,
                onTap: _canGoNext ? onNextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // day-of-week headers
          Row(
            children: _dow
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: RColors.hint,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // day grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (_, i) {
                if (i < firstWeekday) return const SizedBox();
                final day = i - firstWeekday + 1;
                final date = DateTime(year, month, day);
                final allowed = isDateAllowed(date);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isSel = selectedDate != null &&
                    date.year == selectedDate!.year &&
                    date.month == selectedDate!.month &&
                    date.day == selectedDate!.day;

                return GestureDetector(
                  onTap: allowed ? () => onDateSelected(date) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      color: isSel
                          ? RColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: isToday && !isSel
                          ? Border.all(
                              color: RColors.border, width: 1)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSel ? FontWeight.w600 : FontWeight.w400,
                        color: isSel
                            ? Colors.white
                            : allowed
                                ? const Color(0xFF1A1A2E)
                                : RColors.hint,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? RColors.primaryMid : RColors.hint,
        ),
      ),
    );
  }
}