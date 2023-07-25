import 'package:flutter/material.dart';
import 'package:google_places_example/autocomplete_places_component.dart';

import 'geocoding_api.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Center(
              child: GooglePlaceAutoCompleteTextField(
                itmClick: (PlaceDetail prediction) {
                  final fullAddress = prediction.fullAddress;

                  if (!prediction.isFullAddress) {
                    //TODO: handle special cases
                    return;
                  }

                  controller.text = fullAddress;
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: fullAddress.length));
                },
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                      gapPadding: 0),
                  filled: true,
                  // fillColor: greyBackground,
                  hintText: "Pesquisar endereço e número",
                  // prefixIcon: Icon(
                  //   Icons.search,
                  //   // color: darkGrey,
                  // ),
                ),
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
