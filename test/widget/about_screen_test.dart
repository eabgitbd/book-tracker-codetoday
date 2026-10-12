import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/core/constants/app_constants.dart';
import 'package:book_tracker/core/constants/app_links.dart';
import 'package:book_tracker/presentation/screens/profile/about_screen.dart';

void main() {
  testWidgets('AboutScreen renders CodeToday attribution and Facebook button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScreen(),
      ),
    );

    // Verify app name and developer
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Developed by ${AppConstants.developer}'), findsOneWidget);

    // Verify Facebook button label and key
    final fbButton = find.byKey(const Key('facebook_visit_button'));
    expect(fbButton, findsOneWidget);
    expect(find.text(AppLinks.facebookButtonLabel), findsOneWidget);
  });
}
