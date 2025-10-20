// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ProductType { shirt, jacket, pants, shoes, bag, other }

@JsonEnum()
enum SimpleColor {
  white('White', Colors.white),
  black('Black', Colors.black),
  red('Red', Colors.red),
  blue('Blue', Colors.blue),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  purple('Purple', Colors.purple),
  brown('Brown', Colors.brown),
  pink('Pink', Colors.pink),
  gray('Gray', Colors.grey),
  silver(
      'Silver', Colors.grey), // Silver not defined, using grey as placeholder
  gold('Gold', Colors.amber), // Gold not defined, using amber as closest match
  other(
      'Other', Colors.transparent); // Transparent as a placeholder for "other"

  final String name;
  final Color color;

  const SimpleColor(this.name, this.color);
}

@JsonEnum()
enum ClothingSize { XXXS, XXS, XS, S, M, L, XL, XXL, XXXL }
