// Basic smoke test for the Store Admin app.

import 'package:flutter_test/flutter_test.dart';

import 'package:store_admin/main.dart';

void main() {
  testWidgets('App builds and shows the navigation destinations',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StoreAdminApp());
    // The first frame kicks off async network calls that will fail in tests
    // (no backend running); we only assert the shell renders.
    await tester.pump();

    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Items'), findsWidgets);
    expect(find.text('Invoices'), findsWidgets);
  });
}
