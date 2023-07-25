library google_places_flutter;

import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:foodtosave_app/analytics/analytics_helper.dart';
// import 'package:foodtosave_app/analytics/event_name.dart';
// import 'package:foodtosave_app/common/constants/gaps.dart';
// import 'package:foodtosave_app/common/fts_toast_helper.dart';

import 'package:rxdart/rxdart.dart';

import 'package:google_places_example/geocoding_api.dart';

class GooglePlaceAutoCompleteTextField extends StatefulWidget {
  final TextStyle? textStyle;
  final InputDecoration? inputDecoration;
  final int debounceTime;
  final ValueChanged<PlaceDetail>? itmClick;
  final TextEditingController? controller;

  const GooglePlaceAutoCompleteTextField({
    super.key,
    this.controller,
    this.debounceTime = 1500,
    this.inputDecoration,
    this.itmClick,
    this.textStyle,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GooglePlaceAutoCompleteTextFieldState createState() =>
      _GooglePlaceAutoCompleteTextFieldState();
}

class _GooglePlaceAutoCompleteTextFieldState
    extends State<GooglePlaceAutoCompleteTextField> {
  final _subject = PublishSubject<String>();
  StreamSubscription<dynamic>? _subscription;

  late final placesService = PlacesService.create();

  OverlayEntry? _overlayEntry;
  List<Prediction>? _allPredictions;

  final _layerLink = LayerLink();

  bool _showClearButton = false;
  bool _isLoading = false;

  TextEditingController? _localController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _localController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    }

    _createListener();

    _subscription = _subject.stream
        .distinct() //
        .where((event) => event.trim().isNotEmpty)
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .doOnData((event) {
          _isLoading = true;
          setState(() {});
        })
        .switchMap((value) => placesService.getPlaces(value).asStream())
        .listen((response) {
          _allPredictions = response.predictions;
          _isLoading = false;
          setState(() {});
          insertOverlay();
        }, onError: (e, s) {
          _isLoading = false;
          setState(() {});
          //TODO: error handling
        });
  }

  @override
  void didUpdateWidget(covariant GooglePlaceAutoCompleteTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _localController?.dispose();
      _localController = null;
    }

    // ignore: invalid_use_of_protected_member
    if (!_effectiveController.hasListeners) {
      _createListener();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _localController?.dispose();
    _subscription?.cancel();
  }

  void _createListener() {
    _effectiveController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newValue = _effectiveController.text.isNotEmpty;

    if (newValue == _showClearButton) {
      return;
    }

    setState(() {
      _showClearButton = newValue;
    });
  }

  void _createLocalController([TextEditingController? textEditingController]) {
    if (textEditingController != null) {
      _localController =
          TextEditingController.fromValue(textEditingController.value);
    } else {
      _localController = TextEditingController();
    }
  }

  void clear() {
    _effectiveController.clear();
    clearResult();
    setState(() {});
  }

  void clearResult() {
    _allPredictions = null;
    removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            onTap: () => _subject.add('${_effectiveController.text} '),
            decoration:
                (widget.inputDecoration ?? const InputDecoration()).copyWith(
              suffixIcon: _showClearButton
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: clear,
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            style: widget.textStyle,
            controller: _effectiveController,
            onChanged: _subject.add,
          ),
        ),
        if (_isLoading) const LinearProgressIndicator()
      ],
    );
  }

  void insertOverlay() {
    _overlayEntry = null;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry? _createOverlayEntry() {
    if (context.findRenderObject() == null) {
      return null;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: size.height + offset.dy,
          width: size.width,
          child: CompositedTransformFollower(
            showWhenUnlinked: false,
            link: _layerLink,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              color: Colors.white,
              child: _buildBody(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_allPredictions == null) {
      return const SizedBox.shrink();
    }

    if (_allPredictions!.isEmpty) {
      return const SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: Text('Não foram encontrados resultados'),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      separatorBuilder: (context, index) =>
          const Divider(color: Color.fromRGBO(237, 237, 237, 1)),
      itemCount: _allPredictions!.length,
      itemBuilder: (context, index) {
        final prediction = _allPredictions![index];
        final structuredFormatting = prediction.structuredFormatting;

        return InkWell(
          onTap: () async {
            final result = await placesService
                .getPlaceDetailsFromPlaceId(prediction.placeId!);

            widget.itmClick!(result);

            removeOverlay();
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        structuredFormatting?.mainText ?? '',
                        style: const TextStyle(
                          color: Color.fromRGBO(69, 72, 69, 1),
                        ),
                      ),
                      Text(
                        structuredFormatting?.secondaryText ??
                            prediction.description ??
                            '',
                        style: const TextStyle(
                          color: Color.fromRGBO(69, 72, 69, 0.3),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void removeOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _overlayEntry!.markNeedsBuild();
  }
}
