import 'package:flutter_app_sale_06072022/common/bases/base_repository.dart';

class ProductRepository extends BaseRepository{

  Future getListProducts() {
    return apiRequest.getProducts();
  }

  Future getCart() {
    return apiRequest.getCart();
  }

  Future addCart(String id_product) {
    return apiRequest.addCart(id_product);
  }

  Future updateCart(String idCart, String idProduct, num quantity) {
    return apiRequest.updateCart(idCart,idProduct,quantity);
  }

}