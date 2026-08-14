import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/shared/widgets/app_alert_dialog.dart';

void main() {
  testWidgets('AppAlertDialog renders title, message and compact action buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: AppAlertDialog(
                  icon: Icons.warning_amber_rounded,
                  title: 'Delete task?',
                  message: 'This cannot be undone.',
                  cancelText: 'Cancel',
                  confirmText: 'Delete',
                  isDestructive: true,
                  onCancel: () {},
                  onConfirm: () {},
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Delete task?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
