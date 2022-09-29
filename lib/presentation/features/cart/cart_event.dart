import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';

class GetListCartEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class UpdateCartEvent extends BaseEvent {
  String idCart;
  String idProduct;
  num quantity;

  UpdateCartEvent({required this.idCart,required this.idProduct,required this.quantity});
  @override
  List<Object?> get props => [];
}
