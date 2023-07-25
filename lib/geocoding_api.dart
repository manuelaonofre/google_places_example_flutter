import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/place_details.dart';

part 'geocoding_api.g.dart';

class PlaceDetail {
  final String fullAddress;

  final String? neighborhood;
  final String? street;
  final String? city;
  final String? state;
  final String? stateUf;
  final String country;
  final String? postalCode;
  final String? number;
  final LatLng coordinates;
  final bool isFullAddress;

  PlaceDetail({
    required this.fullAddress,
    required this.neighborhood,
    required this.street,
    required this.city,
    required this.state,
    required this.stateUf,
    required this.country,
    required this.coordinates,
    this.number,
    this.postalCode,
    this.isFullAddress = false,
  });

  factory PlaceDetail.fromAddressComponent(Result? result) {
    String? number;
    String street = '';
    String? neighborhood;
    String? state;
    String? stateUf;
    String? city;
    String? country;
    String? postalCode;

    final location = result!.geometry!.location;
    final components = result.addressComponents ?? [];

    for (var component in components) {
      final types = component.types ?? [];

      if (types.contains('street_number')) {
        number = component.longName ?? '';
      } else if (types.contains('route') ||
          types.contains('sublocality_level_3') ||
          types.contains('premise') ||
          types.contains('street_address')) {
        street = '$street ${component.longName ?? ''}';
      } else if (types.contains('sublocality_level_2') ||
          types.contains('sublocality_level_1')) {
        neighborhood = component.longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = component.longName ?? '';
        stateUf = component.shortName ?? '';
      } else if (types.contains('administrative_area_level_4') ||
          types.contains('administrative_area_level_2')) {
        city = component.longName ?? '';
      } else if (types.contains('country')) {
        country = component.longName ?? '';
      } else if (types.contains('postal_code') &&
          !types.contains('postal_code_prefix')) {
        postalCode = component.longName ?? '';
      }
    }

    if (street.isEmpty && result.name != null) {
      street = result.name!;
    }

    final isBrasilia = city?.contains('Brasília') ?? false;

    return PlaceDetail(
      street: street.trim(),
      number: number,
      city: city,
      neighborhood: neighborhood,
      state: state,
      stateUf: stateUf,
      country: country ?? '',
      postalCode: postalCode,
      fullAddress: result.formattedAddress ?? '',
      coordinates: LatLng(location!.lat!, location.lng!),
      isFullAddress: {
        if (!isBrasilia) ...[street],
        city,
        state,
      }.every((element) => element != null),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class GeocodingResult {
  @JsonKey(name: "address_components")
  final List<AddressComponents> addressComponents;

  @JsonKey(name: "formatted_address")
  final String formattedAddress;

  @JsonKey(name: "geometry")
  final Geometry geometry;

  @JsonKey(name: "place_id")
  final String placeId;

  final List<String> types;

  GeocodingResult({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
    required this.types,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResultFromJson(json);

  static List<GeocodingResult> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => GeocodingResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => _$GeocodingResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlacesAutocompleteResponse {
  final List<Prediction>? predictions;
  final String? status;

  PlacesAutocompleteResponse({
    this.predictions,
    this.status,
  });

  factory PlacesAutocompleteResponse.fromJson(Map<String, dynamic> json) =>
      _$PlacesAutocompleteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlacesAutocompleteResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Prediction {
  final String? description;
  final String? id;

  @JsonKey(name: 'matched_substrings')
  final List<MatchedSubstrings>? matchedSubstrings;

  @JsonKey(name: 'place_id')
  final String? placeId;
  final String? reference;

  @JsonKey(name: 'structured_formatting')
  final StructuredFormatting? structuredFormatting;
  final List<Terms>? terms;
  final List<String>? types;
  final String? lat;
  final String? lng;

  Prediction({
    this.description,
    this.id,
    this.matchedSubstrings,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    this.terms,
    this.types,
    this.lat,
    this.lng,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MatchedSubstrings {
  final int? length;
  final int? offset;

  MatchedSubstrings({this.length, this.offset});

  factory MatchedSubstrings.fromJson(Map<String, dynamic> json) =>
      _$MatchedSubstringsFromJson(json);

  Map<String, dynamic> toJson() => _$MatchedSubstringsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StructuredFormatting {
  @JsonKey(name: 'main_text')
  final String? mainText;

  @JsonKey(name: 'secondary_text')
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) =>
      _$StructuredFormattingFromJson(json);

  Map<String, dynamic> toJson() => _$StructuredFormattingToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Terms {
  final int? offset;
  final String? value;

  Terms({this.offset, this.value});

  factory Terms.fromJson(Map<String, dynamic> json) => _$TermsFromJson(json);

  Map<String, dynamic> toJson() => _$TermsToJson(this);
}

// @JsonSerializable(explicitToJson: true)
// class ViaCepAddress {
//   final String cep;
//   final String logradouro;
//   final String complemento;
//   final String bairro;
//   final String localidade;
//   final String uf;
//   final String ibge;
//   final String gia;
//   final String ddd;
//   final String siafi;

//   ViaCepAddress({
//     required this.cep,
//     required this.logradouro,
//     required this.complemento,
//     required this.bairro,
//     required this.localidade,
//     required this.uf,
//     required this.ibge,
//     required this.gia,
//     required this.ddd,
//     required this.siafi,
//   });

//   // factory ViaCepAddress.fromJson(Map<String, dynamic> json) =>
//   //     _$ViaCepAddressFromJson(json);
//   // Map<String, dynamic> toJson() => _$ViaCepAddressToJson(this);
// }

class PlacesService {
  final Dio _dio;

  PlacesService._(this._dio);

  factory PlacesService.create() {
    return PlacesService._(Dio());
  }

  String get apiKey => "";

  Future<List<GeocodingResult>> reverseGeocode(
      double latitude, double longitude) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey&language=pt-BR";
    final response = await _dio.get<Map<String, dynamic>>(url);
    final data = response.data!["results"] as List<dynamic>;
    final placeResult = GeocodingResult.fromJsonList(data);
    return placeResult;
  }

  Future<PlacesAutocompleteResponse> getPlaces(String term) async {
    print(term);
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$term&key=$apiKey&language=pt-BR&components=country:br";
    final response = await _dio.get<Object>(url);
    final placeResult = PlacesAutocompleteResponse.fromJson(
        response.data as Map<String, dynamic>);
    return placeResult;
  }

  Future<PlaceDetail> getPlaceDetailsFromPlaceId(String placeId) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey";
    final response = await _dio.get<Object>(url);

    final placeDetails =
        PlaceDetails.fromJson(response.data as Map<String, dynamic>);

    return PlaceDetail.fromAddressComponent(placeDetails.result!);
  }

  // Future<Address?> getAddressFromLocation(
  //     double latitude, double longitude) async {
  //   final placemarks = await reverseGeocode(latitude, longitude);

  //   final currentPlacemark = placemarks.firstOrNull;

  //   if (currentPlacemark == null) {
  //     return null;
  //   }

  //   final place = await getPlaceDetailsFromPlaceId(currentPlacemark.placeId);

  //   return Address.fromPlaceDetail(place);
  // }

/*
  Future<List<ViaCepAddress>> findByViaCep(PlaceDetail detail) async {
    final url = "https://viacep.com.br/ws/${detail.stateUf}/${detail.city}/${detail.street!}/json";
    final response = await _dio.get<Object>(url);
    final data = response.data as List<dynamic>;

    final result = data.map((e) => ViaCepAddress.fromJson(e as Map<String, dynamic>)).toList();
    return result;
  }
  */
}
