import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/validators.dart';
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

  final _dueDate = Rxn<DateTime>();
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
    _dueDate.value = _editingTask?.dueDate ??
        DateTime.now().add(const Duration(days: 1));
    _status.value = _editingTask?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate.value == null) {
      Get.snackbar('Missing due date', 'Please select a due date.');
      return;
    }

    _isSaving.value = true;
    bool success;

    if (_isEditMode) {
      final updated = _editingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate.value,
        status: _status.value,
      );
      success = await _taskController.updateTask(updated);
    } else {
      final newTask = Task(
        id: '', // ignored on create — Firestore assigns the id
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(), // ignored on create — server timestamp used
        dueDate: _dueDate.value!,
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
          builder: (ctx) => AlertDialog(
            title: const Text('Delete task?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
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

                Text('Due Date', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Obx(() => InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _dueDate.value != null
                                  ? DateFormat.yMMMd().format(_dueDate.value!)
                                  : 'Select a date',
                            ),
                          ],
                        ),
                      ),
                    )),

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