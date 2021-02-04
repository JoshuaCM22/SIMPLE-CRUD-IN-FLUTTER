import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/product_helper.dart';
import 'product.dart';

enum OrderOptions { orderFromAtoZ, orderFromZtoA }

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ProductHelper helper = ProductHelper();
  List<Products> products = [];

  @override
  void initState() {
    super.initState();
    _getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ascending Order'),
                value: OrderOptions.orderFromAtoZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Descending Order'),
                value: OrderOptions.orderFromZtoA,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductScreen();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: products.length,
          itemBuilder: _productCard),
    );
  }

  _computeAvailableInventoryCost(int index) {
    var output;
    var availableInventory = products[index].availableInventory;
    var price = products[index].price;
    output = availableInventory * price;
    return output;
  }

  Widget _productCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text('Product Name: ' + products[index].productName,
                        style: TextStyle(fontSize: 15.0)),
                    Text('Unit: ' + products[index].unit,
                        style: TextStyle(fontSize: 15.0)),
                    Text('Price: ' + products[index].price.toStringAsFixed(2),
                        style: TextStyle(fontSize: 15.0)),
                    Text('Date of Expiry: ' + products[index].dateOfExpiry,
                        style: TextStyle(fontSize: 15.0)),
                    Text(
                        'Available Inventory: ' +
                            products[index].availableInventory.toString(),
                        style: TextStyle(fontSize: 15.0)),
                    Text(
                        'Avaiable Inventory Cost: ' +
                            _computeAvailableInventoryCost(index)
                                .toStringAsFixed(2),
                        style: TextStyle(fontSize: 15.0)),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 160.0,
                      height: 130.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: products[index].image != null
                              ? FileImage(File(products[index].image))
                              : AssetImage('assets/images/questionMark.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  showAlertDialog(
      BuildContext context,
      String titleContent,
      String messageContent,
      String button1Content,
      String button2Content,
      int index) {
    Widget buttonNo = FlatButton(
      child: Text(
        button2Content,
        style: TextStyle(
          color: Colors.black,
          fontSize: 19.0,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget buttonYes = FlatButton(
      child: Text(
        button1Content,
        style: TextStyle(
          color: Colors.black,
          fontSize: 19.0,
        ),
      ),
      onPressed: () {
        helper.deleteProduct(products[index].id);
        setState(() {
          products.removeAt(index);
          Navigator.pop(context);
        });
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          titleContent,
          style: TextStyle(
            fontSize: 28.0,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      content: Text(
        messageContent,
        style: TextStyle(
          color: Colors.black,
          fontSize: 19.0,
          fontFamily: 'RobotoMono',
        ),
      ),
      actions: [
        buttonYes,
        buttonNo,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        'Edit',
                        style: TextStyle(
                            color: Colors.purple[700], fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showProductScreen(product: products[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        'Delete',
                        style: TextStyle(
                            color: Colors.purple[700], fontSize: 20.0),
                      ),
                      onPressed: () {
                        showAlertDialog(
                            context,
                            'Attention',
                            'Are you sure you want to delete?',
                            'Yes',
                            'No',
                            index);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showProductScreen({Products product}) async {
    final recProduct = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => Product(product: product)));
    if (recProduct != null) {
      if (product != null) {
        await helper.updateProduct(recProduct);
      } else {
        await helper.saveProduct(recProduct);
      }
      _getAllProducts();
    }
  }

  void _getAllProducts() {
    helper.getAllProducts().then((list) {
      setState(() {
        products = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderFromAtoZ:
        products.sort((a, b) {
          return a.productName
              .toLowerCase()
              .compareTo(b.productName.toLowerCase());
        });
        break;
      case OrderOptions.orderFromZtoA:
        products.sort((a, b) {
          return b.productName
              .toLowerCase()
              .compareTo(a.productName.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
