import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/constants/api_constant.dart';
import 'package:flutter_app_sale_06072022/common/widgets/loading_widget.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/presentation/features/cart/cart_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/bases/base_widget.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/cart.dart';
import '../../../data/repositories/cart_repository.dart';
import 'cart_event.dart';


class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Giỏ hàng"),
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, CartRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? CartRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<CartRepository, CartBloc>(
          update: (context, repository, bloc) {
            bloc?.updateCartRepository(repository);
            return bloc ?? CartBloc()
              ..updateCartRepository(repository);
          },
        ),
      ],
      child: CartContainer(),
    );
  }
}
 class CartContainer extends StatefulWidget {
   const CartContainer({Key? key}) : super(key: key);

   @override
   State<CartContainer> createState() => _CartContainerState();
 }

 class _CartContainerState extends State<CartContainer> {
   Cart? _cartModel;
   late CartBloc _cartBloc;

   @override
   void initState() {
     super.initState();
     _cartBloc = context.read<CartBloc>();
     _cartBloc.eventSink.add(GetListCartEvent());
   }

   @override
   Widget build(BuildContext context) {
     return WillPopScope(
         onWillPop: () async{
           Navigator.pop(context, _cartModel);
           return true;
         },
       child: SafeArea(
           child: Container(
             child: Stack(
               children: [
                 StreamBuilder<Cart>(
                     initialData: null,
                     stream: _cartBloc.cartController.stream,
                     builder: (context, snapshot) {
                       if (snapshot.hasError) {
                         return const Center(child: Text("Data error"));
                       }
                       if (snapshot.hasData) {
                         _cartModel = snapshot.data;
                         if (snapshot.data!.products.isEmpty) {
                           return const Center(
                             child: Text(
                               'Your Cart is Empty',
                               style:
                               TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                             )
                           );
                         }
                         return Column(
                           children: [
                             Expanded(
                               child: ListView.builder(
                                   itemCount: snapshot.data?.products.length ?? 0,
                                   itemBuilder: (context, index) {
                                     return _buildItem(snapshot.data?.products[index]);
                                   }
                               )
                             ),
                             Container(
                               margin: EdgeInsets.symmetric(vertical: 5),
                               padding: EdgeInsets.all(10),
                               child: Text(
                                   "Tổng tiền : " +
                                       NumberFormat("#,###", "en_US")
                                           .format(_cartModel?.price) +
                                       " đ",
                                   style: TextStyle(fontSize: 22, color: Colors.black,fontWeight: FontWeight.bold))),
                             Container(
                               padding: EdgeInsets.all(5),
                               child: ElevatedButton(
                                 onPressed: () {
                                   if (_cartModel != null) {
                                     String? cartId = _cartModel!.id;
                                     _cartBloc.eventSink.add(ConformCartEvent(idCart: cartId));
                                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt hàng thành công !!!')));
                                     Navigator.pushNamedAndRemoveUntil(context, "/home" , (Route<dynamic> route) => false);
                                   }
                                 },
                                 style: ButtonStyle(
                                     backgroundColor:
                                     MaterialStateProperty.all(Colors.deepOrange)),
                                 child: Padding(
                                   padding: EdgeInsets.only(left:15, bottom: 10, right: 15, top:10),
                                   child: Text("Đặt Đơn",style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
                                   ),
                                 ),
                               )
                             ),
                           ],
                         );
                       }
                       return Container();
                     }
                     ),
                 LoadingWidget(
                   bloc: _cartBloc,
                   child: Container(),
                 )
               ],
             ),

           )
       ),
     );
   }

   Widget _buildItem(Product? product) {
     if (product == null) return Container();
     return Container(
       height: 135,
       child: Card(
         elevation: 5,
         shadowColor: Colors.blueGrey,
         child: Container(
           padding: EdgeInsets.only(top: 5, bottom: 5),
           child: Row(
             children: [
               ClipRRect(
                 borderRadius: BorderRadius.circular(5),
                 child: Image.network(ApiConstant.BASE_URL + product.img,
                     width: 150, height: 120, fit: BoxFit.fill),
               ),
               Expanded(
                 child: Padding(
                   padding: const EdgeInsets.only(left: 10),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Padding(
                         padding: const EdgeInsets.only(top: 5),
                         child: Text((product.name).toString(),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                             style: TextStyle(fontSize: 17)),
                       ),
                       Text(
                           "Giá : " +
                               NumberFormat("#,###", "en_US")
                                   .format(product.price) +
                               " đ",
                           style: TextStyle(fontSize: 14)),
                       Row(
                         children: [
                           ElevatedButton(
                             onPressed: () {
                               if (_cartModel != null ) {
                                 String cartId = _cartModel!.id;
                                 if (cartId.isNotEmpty) {
                                   _cartBloc.eventSink.add(UpdateCartEvent(idCart: cartId, idProduct: product.id, quantity: product.quantity - 1));
                                 }
                               }
                             },
                             child: Text("-"),
                           ),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             child: Text((product.quantity).toString(),
                                 style: TextStyle(fontSize: 16)),
                           ),
                           ElevatedButton(
                             onPressed: () {
                               if (_cartModel != null ) {
                                 String cartId = _cartModel!.id;
                                 if (cartId.isNotEmpty) {
                                   _cartBloc.eventSink.add(UpdateCartEvent(idCart: cartId, idProduct: product.id, quantity: product.quantity + 1));
                                 }
                               }
                             },
                             child: Text("+"),
                           ),
                         ],
                       )
                     ],
                   ),
                 ),
               ),
             ],
           ),
         ),
       ),
     );
   }
 }


