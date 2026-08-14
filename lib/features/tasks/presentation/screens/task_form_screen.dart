import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_alert_dialog.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/task_model.dart';
import '../controllers/task_controller.dart';

/// Handles BOTH creating a new task and editing an existing one.
/// Mode is determined purely by whether a Task was passed as a
/// navigation argument — no separate screens/routes needed for each.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Due date and time are edited separately (two pickers) but combined
  // into a single DateTime when saving — see _combinedDueDate.
  final _dueDate = Rxn<DateTime>();
  final _dueTime = Rxn<TimeOfDay>();
  final _status = TaskStatus.pending.obs;
  final _isSaving = false.obs;

  Task? _editingTask;
  bool get _isEditMode => _editingTask != null;

  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    _editingTask = arg is Task ? arg : null;

    _titleController = TextEditingController(text: _editingTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: _editingTask?.description ?? '');

    final initialDueDate = _editingTask?.dueDate ??
        DateTime.now().add(const Duration(days: 1));
    _dueDate.value = initialDueDate;
    _dueTime.value = TimeOfDay.fromDateTime(initialDueDate);

    _status.value = _editingTask?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Merges the separately-picked date and time into one DateTime.
  /// Falls back to 11:59 PM if the user picked a date but skipped the
  /// time step, so a task never silently loses its due time.
  DateTime? get _combinedDueDate {
    if (_dueDate.value == null) return null;
    final time = _dueTime.value ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(
      _dueDate.value!.year,
      _dueDate.value!.month,
      _dueDate.value!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _dueDate.value = picked;
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) _dueTime.value = picked;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dueDate = _combinedDueDate;
    if (dueDate == null) {
      Get.snackbar('Missing due date', 'Please select a due date.');
      return;
    }

    _isSaving.value = true;
    bool success;

    if (_isEditMode) {
      final updated = _editingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dueDate,
        status: _status.value,
      );
      success = await _taskController.updateTask(updated);
    } else {
      final newTask = Task(
        id: '', // ignored on create — Firestore assigns the id
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(), // ignored on create — server timestamp used
        dueDate: dueDate,
        status: TaskStatus.pending,
      );
      success = await _taskController.addTask(newTask);
    }

    _isSaving.value = false;
    if (success) Get.back();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AppAlertDialog(
            icon: Icons.delete_outline_rounded,
            title: 'Delete task?',
            message: 'This cannot be undone.',
            cancelText: 'Cancel',
            confirmText: 'Delete',
            isDestructive: true,
            onCancel: () => Navigator.pop(ctx, false),
            onConfirm: () => Navigator.pop(ctx, true),
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await _taskController.deleteTask(_editingTask!.id);
      if (success) Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'Add Task'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'e.g. Finish project report',
                  validator: (v) => Validators.required(v, fieldName: 'Title'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Optional details about this task',
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.md),

                // Due Date + Due Time side by side — together they form
                // the full due DateTime saved to Firestore.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due Date',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Obx(() => InkWell(
                                onTap: _pickDueDate,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                                child: InputDecorator(
                                  decoration: const InputDecoration(),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 18),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          _dueDate.value != null
                                              ? DateFormat.yMMMd()
                                                  .format(_dueDate.value!)
                                              : 'Select date',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due Time',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Obx(() => InkWell(
                                onTap: _pickDueTime,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                                child: InputDecorator(
                                  decoration: const InputDecoration(),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_outlined,
                                          size: 18),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          _dueTime.value != null
                                              ? _dueTime.value!
                                                  .format(context)
                                              : 'Select time',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                if (_isEditMode) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('Status', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Obx(() => SegmentedButton<TaskStatus>(
                        segments: const [
                          ButtonSegment(
                            value: TaskStatus.pending,
                            label: Text('Pending'),
                            icon: Icon(Icons.pending_outlined),
                          ),
                          ButtonSegment(
                            value: TaskStatus.completed,
                            label: Text('Completed'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                        ],
                        selected: {_status.value},
                        onSelectionChanged: (selection) =>
                            _status.value = selection.first,
                      )),
                ],

                const SizedBox(height: AppSpacing.xl),
                Obx(() => AppButton(
                      label: _isEditMode ? 'Save Changes' : 'Add Task',
                      isLoading: _isSaving.value,
                      onPressed: _save,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}