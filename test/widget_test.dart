import 'package:flutter_test/flutter_test.dart';
import 'package:cuatro_retos_flutter/main.dart';

void main() {
  testWidgets('La aplicación muestra sus cuatro secciones', (tester) async {
    await tester.pumpWidget(const CuatroRetosApp());
    expect(find.text('CUATRO RETOS'), findsOneWidget);
    expect(find.text('Películas'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);
    expect(find.text('Clima'), findsOneWidget);
    expect(find.text('Cripto'), findsOneWidget);
  });
}
