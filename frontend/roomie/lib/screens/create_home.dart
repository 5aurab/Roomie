import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../widgets/logo_mark.dart';
import '../widgets/field_labels.dart';
import '../widgets/primary_button.dart';

class CreateHomeScreen extends StatefulWidget {
  const CreateHomeScreen({super.key});

  @override
  State<CreateHomeScreen> createState() => _CreateHomeScreenState();
}

class _CreateHomeScreenState extends State<CreateHomeScreen> {
  final _nameController = TextEditingController();
  int _roomCount = 3;

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  void _increment() => setState(() => _roomCount++);
  void _decrement() => setState(() {
        if (_roomCount > 1) _roomCount--;
      });

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: Logo()),
                const SizedBox(height: 20),
                const Text(
                  'Set up your home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: RColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tell us a bit about where you live',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: RColors.primaryMid,
                  ),
                ),
                const SizedBox(height: 32),
                const FieldLabel('Name'),
                const SizedBox(height: 8),
                _RoomieTextField(
                  controller: _nameController,
                  placeholder: 'Name your home',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const FieldLabel('Number of rooms'),
                const SizedBox(height: 8),
                _RoomCounter(
                  count: _roomCount,
                  onDecrement: _decrement,
                  onIncrement: _increment,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: _isValid ? _onContinue : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    // todo: navigate to next screen
  }
}

// ---------------------------------------------------------------------------
// Text input styled to match the Roomie design system
// ---------------------------------------------------------------------------
class _RoomieTextField extends StatelessWidget {
  const _RoomieTextField({
    required this.controller,
    required this.placeholder,
    this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        color: RColors.primary,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: RColors.hint,
        ),
        filled: true,
        fillColor: RColors.primaryLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Room counter:  −  3  +
// ---------------------------------------------------------------------------
class _RoomCounter extends StatelessWidget {
  const _RoomCounter({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: RColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RColors.border),
      ),
      child: Row(
        children: [
          _CounterButton(icon: '−', onTap: onDecrement),
          Expanded(
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: RColors.primary,
                ),
              ),
            ),
          ),
          _CounterButton(icon: '+', onTap: onIncrement),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: RColors.border,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(
              fontSize: 18,
              color: RColors.primary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}