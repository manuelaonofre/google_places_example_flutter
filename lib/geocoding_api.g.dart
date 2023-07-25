// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodingResult _$GeocodingResultFromJson(Map<String, dynamic> json) =>
    GeocodingResult(
      addressComponents: (json['address_components'] as List<dynamic>)
          .map((e) => AddressComponents.fromJson(e as Map<String, dynamic>))
          .toList(),
      formattedAddress: json['formatted_address'] as String,
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      placeId: json['place_id'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GeocodingResultToJson(GeocodingResult instance) =>
    <String, dynamic>{
      'address_components':
          instance.addressComponents.map((e) => e.toJson()).toList(),
      'formatted_address': instance.formattedAddress,
      'geometry': instance.geometry.toJson(),
      'place_id': instance.placeId,
      'types': instance.types,
    };

PlacesAutocompleteResponse _$PlacesAutocompleteResponseFromJson(
        Map<String, dynamic> json) =>
    PlacesAutocompleteResponse(
      predictions: (json['predictions'] as List<dynamic>?)
          ?.map((e) => Prediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PlacesAutocompleteResponseToJson(
        PlacesAutocompleteResponse instance) =>
    <String, dynamic>{
      'predictions': instance.predictions?.map((e) => e.toJson()).toList(),
      'status': instance.status,
    };

Prediction _$PredictionFromJson(Map<String, dynamic> json) => Prediction(
      description: json['description'] as String?,
      id: json['id'] as String?,
      matchedSubstrings: (json['matched_substrings'] as List<dynamic>?)
          ?.map((e) => MatchedSubstrings.fromJson(e as Map<String, dynamic>))
          .toList(),
      placeId: json['place_id'] as String?,
      reference: json['reference'] as String?,
      structuredFormatting: json['structured_formatting'] == null
          ? null
          : StructuredFormatting.fromJson(
              json['structured_formatting'] as Map<String, dynamic>),
      terms: (json['terms'] as List<dynamic>?)
          ?.map((e) => Terms.fromJson(e as Map<String, dynamic>))
          .toList(),
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
    );

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{
      'description': instance.description,
      'id': instance.id,
      'matched_substrings':
          instance.matchedSubstrings?.map((e) => e.toJson()).toList(),
      'place_id': instance.placeId,
      'reference': instance.reference,
      'structured_formatting': instance.structuredFormatting?.toJson(),
      'terms': instance.terms?.map((e) => e.toJson()).toList(),
      'types': instance.types,
      'lat': instance.lat,
      'lng': instance.lng,
    };

MatchedSubstrings _$MatchedSubstringsFromJson(Map<String, dynamic> json) =>
    MatchedSubstrings(
      length: json['length'] as int?,
      offset: json['offset'] as int?,
    );

Map<String, dynamic> _$MatchedSubstringsToJson(MatchedSubstrings instance) =>
    <String, dynamic>{
      'length': instance.length,
      'offset': instance.offset,
    };

StructuredFormatting _$StructuredFormattingFromJson(
        Map<String, dynamic> json) =>
    StructuredFormatting(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );

Map<String, dynamic> _$StructuredFormattingToJson(
        StructuredFormatting instance) =>
    <String, dynamic>{
      'main_text': instance.mainText,
      'secondary_text': instance.secondaryText,
    };

Terms _$TermsFromJson(Map<String, dynamic> json) => Terms(
      offset: json['offset'] as int?,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$TermsToJson(Terms instance) => <String, dynamic>{
      'offset': instance.offset,
      'value': instance.value,
    };
