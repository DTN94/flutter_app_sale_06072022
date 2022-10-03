import 'package:flutter_app_sale_06072022/common/bases/base_repository.dart';

class CartRepository extends BaseRepository{
  Future getCart() {
    return apiRequest.getCart();
  }
  Future updateCart(String idCart, String idProduct, num quantity) {
    return apiRequest.updateCart(idCart,idProduct,quantity);
  }
  Future conformCart(String idCart) {
    return apiRequest.conformCart(idCart);
  }
}