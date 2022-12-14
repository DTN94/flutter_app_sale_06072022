import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/data/datasources/local/cache/app_cache.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/product/product_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/product/product_event.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/api_constant.dart';
import '../../../common/constants/variable_constant.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/cart.dart';
class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}
class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Chi tiết sản phẩm"),
        actions: [
          Container(
              margin: EdgeInsets.only(top: 10),
              child: IconButton(
                icon: Icon(Icons.history_edu),
                onPressed: () {
                  Navigator.pushNamed(context, VariableConstant.ORDER_HISTORY_ROUTE);
                },
              )
          ),
          Consumer<ProductBloc>(
            builder: (context, bloc, child){
              return StreamBuilder<Cart>(
                  initialData: null,
                  stream: bloc.cartController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError || snapshot.data == null || snapshot.data?.products.isEmpty == true) {
                      return Container();
                    }
                    int count = snapshot.data?.products.length ?? 0;
                    return Container(
                      margin: EdgeInsets.only(right: 10, top: 10),
                      child: Badge(
                          badgeContent: Text(count.toString(), style: const TextStyle(color: Colors.white),),
                          child: IconButton(
                            icon: Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              Navigator.pushNamed(context, VariableConstant.CART_ROUTE).then((cartUpdate){
                                if(cartUpdate != null){
                                  bloc.cartController.sink.add(cartUpdate as Cart);
                                }
                              });
                            },
                          )
                      ),
                    );
                  }
              );
            },
          )
        ],
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context, true);}
        )
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? ProductRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<ProductRepository, ProductBloc>(
          update: (context, repository, bloc) {
            bloc?.updateProductRepository(repository);
            return bloc ?? ProductBloc()
              ..updateProductRepository(repository);
          },
        ),
      ],
      child: ProductContainer(),
    );
  }
}

class ProductContainer extends StatefulWidget {
  const ProductContainer({Key? key}) : super(key: key);

  @override
  State<ProductContainer> createState() => _ProductContainerState();
}

class _ProductContainerState extends State<ProductContainer> {
  Product? product;
  late ProductBloc _productBloc;
  String selectedImage = "";
  String image = "";

  @override
  void initState() {
    super.initState();
    _productBloc = context.read<ProductBloc>();
    _productBloc.eventSink.add(GetCartEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var dataReceive = ModalRoute.of(context)?.settings.arguments as Product;
    product = dataReceive;
    selectedImage = image = ApiConstant.BASE_URL + product!.img;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Stack(
          children: [
            ListView(
              children: [
                Column(
                  children: [
                    SizedBox(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Hero(
                          tag: product!.id,
                          child: Image.network(selectedImage,fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildSmallProductPreview(image),
                        ...List.generate(product!.gallery.length,
                                (index) => buildSmallProductPreview(ApiConstant.BASE_URL + product!.gallery[index])),
                      ],
                    ),
                  ],
                ),
                TopRoundedContainer(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                                product!.name,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                Text(
                                    "Giá : ",
                                    style: TextStyle(fontSize: 18)),
                                Text(NumberFormat("#,###", "en_US")
                                    .format(product!.price) +
                                    " đ",
                                    style: TextStyle(fontSize: 20,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Text(
                              product!.address,
                              maxLines: 4,
                              style: TextStyle(fontSize: 16,
                                  fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                      TopRoundedContainer(
                        color: Color(0xFFF6F7F9),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: DefaultButton(
                            text: "Thêm Vào Giỏ",
                            press: () {
                              String token = AppCache.getString(VariableConstant.TOKEN);
                              if(token.isNotEmpty){
                                _productBloc.eventSink.add(AddToCartEvent(id: product!.id));
                              }else{
                                Navigator.pushNamedAndRemoveUntil(context, "/sign_in" , (Route<dynamic> route) => false);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            LoadingWidget(
              bloc: _productBloc,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }

  GestureDetector buildSmallProductPreview(String url) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = url;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.all(5),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: Color(0xFFFF7643).withOpacity(selectedImage == url ? 1 : 0)),
        ),
        child: Image.network(url),
      ),
    );
  }

}

class TopRoundedContainer extends StatelessWidget {
  const TopRoundedContainer({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.only(top: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    this.text,
    this.press,
  }) : super(key: key);
  final String? text;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          primary: Colors.white,
          backgroundColor: Color(0xFFFF7643),
        ),
        onPressed: press as void Function()?,
        child: Text(
          text!,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
