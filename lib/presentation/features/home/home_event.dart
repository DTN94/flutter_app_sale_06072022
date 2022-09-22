import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';

class GetListProductEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class GetCartEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class AddCartEvent extends BaseEvent {
  String id_product;
  AddCartEvent({required this.id_product});
  @override
  List<Object?> get props => [];
}