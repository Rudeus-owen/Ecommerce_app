// // user_site/screens/cart_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:new_ecommerce_app/user%20site/providers/cart.dart';

// class CartScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<Cart>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Cart'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Card(
//             margin: EdgeInsets.all(15),
//             child: Padding(
//               padding: EdgeInsets.all(8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Text(
//                     'Total',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   Spacer(),
//                   Chip(
//                     label: Text(
//                       '\$${cart.totalAmount.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Theme.of(context).primaryTextTheme.titleLarge?.color,
//                       ),
//                     ),
//                     backgroundColor: Theme.of(context).primaryColor,
//                   ),
//                   TextButton(
//                     child: Text('ORDER NOW'),
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       foregroundColor: Theme.of(context).primaryColor,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           Expanded(
//             child: ListView.builder(
//               itemCount: cart.items.length,
//               itemBuilder: (ctx, i) => CartItemWidget(
//                 id: cart.items.values.toList()[i].id,
//                 productId: cart.items.keys.toList()[i],
//                 title: cart.items.values.toList()[i].title,
//                 quantity: cart.items.values.toList()[i].quantity,
//                 price: cart.items.values.toList()[i].price,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class CartItemWidget extends StatelessWidget {
//   final String id;
//   final String productId;
//   final String title;
//   final int quantity;
//   final double price;

//   CartItemWidget({
//     required this.id,
//     required this.productId,
//     required this.title,
//     required this.quantity,
//     required this.price,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: ValueKey(id),
//       background: Container(
//         color: Theme.of(context).colorScheme.error,
//         child: Icon(
//           Icons.delete,
//           color: Colors.white,
//           size: 40,
//         ),
//         alignment: Alignment.centerRight,
//         padding: EdgeInsets.only(right: 20),
//         margin: EdgeInsets.symmetric(
//           horizontal: 15,
//           vertical: 4,
//         ),
//       ),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         Provider.of<Cart>(context, listen: false).removeItem(productId);
//       },
//       child: Card(
//         margin: EdgeInsets.symmetric(
//           horizontal: 15,
//           vertical: 4,
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(8),
//           child: ListTile(
//             leading: CircleAvatar(
//               child: Padding(
//                 padding: EdgeInsets.all(5),
//                 child: FittedBox(
//                   child: Text('\$${price}'),
//                 ),
//               ),
//             ),
//             title: Text(title),
//             subtitle: Text('Total: \$${(price * quantity)}'),
//             trailing: Text('$quantity x'),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartList = [
    {
      "image": "assets/images/yellow.jpg",
      "title": "Shoe",
      "price": "100",
      "discprice": "",
      "qty": 1,
      "size": "S",
      "currency": "\$"
    },
    {
      "image": "assets/images/blue.jpg",
      "title": "Yellow Shoe",
      "price": "10000",
      "discprice": "9000",
      "qty": 1,
      "size": "L",
      "currency": "\$"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '3 Items',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: ListView.builder(
          itemCount: cartList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 90,
                    width: 75,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(right: 15),
                    child: Expanded(
                      child: Image.asset(
                        "${cartList[index]["image"]}",
                      ),
                    ),
                  ),
                  titlePriceQtyWidget(index),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          cartList[index]["size"].toString(),
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              cartList.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.red[400],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        height: MediaQuery.of(context).size.height * 0.28,
        color: Colors.transparent,
        child: Column(
          children: [
            priceText("Sub total:", "\$2000"),
            priceText("Shipping:", "\$5"),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              color: Colors.grey[400],
            ),
            priceText("Total:", "\$2005"),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF77F00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Checkout",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget titlePriceQtyWidget(int index) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cartList[index]["title"].toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          cartList[index]["discprice"] == "" ||
                  cartList[index]["discprice"] == "0"
              ? Text(
                  "${cartList[index]["currency"]}${cartList[index]["price"]}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${cartList[index]["currency"]}${cartList[index]["discprice"]}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${cartList[index]["currency"]}${cartList[index]["price"]}",
                      style: TextStyle(
                        color: Colors.red[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => handleQtyClick(index, "plus"),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text("${cartList[index]["qty"]}"),
                ),
                GestureDetector(
                  onTap: () => handleQtyClick(index, "minus"),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  handleQtyClick(int index, String plusOrMinus) {
    if (plusOrMinus == "plus") {
      cartList[index]["qty"] = cartList[index]['qty'] + 1;
    } else {
      cartList[index]["qty"] = cartList[index]['qty'] - 1;
    }
    setState(() {
      if (cartList[index]["qty"] == 0) {
        cartList.removeAt(index);
      }
    });
  }

  Widget priceText(title, price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title',
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 14,
          ),
        ),
        Text(
          "$price",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget totalPriceText(title, price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title',
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 14,
          ),
        ),
        Text(
          "$price",
          style: const TextStyle(
            color: Color(0xFFF77F00),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
