import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/robot_face_cubit.dart';
import '../services/timer_service.dart';

class TimerDialog extends StatefulWidget {
  const TimerDialog({super.key});

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  int _selectedMinutes = 5;
  final List<int> _presetMinutes = [1, 5, 10, 15, 25, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotFaceCubit, RobotFaceState>(
      builder: (context, state) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.timer, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Focus Timer'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!state.isTimerRunning) ...[
                const Text('Select timer duration:'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetMinutes.map((minutes) {
                    final isSelected = minutes == _selectedMinutes;
                    return FilterChip(
                      label: Text('${minutes}m'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMinutes = minutes;
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Timer is running - show current status
                Column(
                  children: [
                    Text('Timer Running', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        TimerService().formatTime(state.timerSeconds),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    if (state.aiMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.smart_toy, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(state.aiMessage, style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (!state.isTimerRunning) ...[
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RobotFaceCubit>().startTimer(_selectedMinutes);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ] else ...[
              TextButton.icon(
                onPressed: () {
                  context.read<RobotFaceCubit>().stopTimer();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RobotFaceCubit>().pauseTimer();
                },
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
            ],
          ],
        );
      },
    );
  }
}
