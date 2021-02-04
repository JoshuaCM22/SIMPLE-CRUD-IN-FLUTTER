import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/product_helper.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class Product extends StatefulWidget {
  final Products product;
  Product({this.product});

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final _productNameController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = MoneyMaskedTextController(
      initialValue: 0.0,
      decimalSeparator: '.',
      thousandSeparator: ',',
      rightSymbol: '',
      leftSymbol: '');

  final _dateOfExpiryController = TextEditingController();
  final _availableInventoryController = TextEditingController();

  final _nameFocus = FocusNode();
  bool _userEdited = false;
  bool _validateForProductName = false;
  bool _validateForUnit = false;
  bool _validateForPrice = false;
  bool _validateForDateOfExpiry = false;
  bool _validateForAvailableInventory = false;

  Products _editedProduct;

  @override
  void initState() {
    super.initState();
    if (widget.product == null) {
      _editedProduct = Products();
    } else {
      _editedProduct = Products.fromMap(widget.product.toMap());
    }

    _productNameController.text = _editedProduct.productName;
    _unitController.text = _editedProduct.unit;

    if (_editedProduct.price == null) {
      _priceController.text = '0.00';
    } else {
      _priceController.text = _editedProduct.price.toStringAsFixed(2);
    }

    _dateOfExpiryController.text = _editedProduct.dateOfExpiry;

    if (_editedProduct.availableInventory == null) {
      _availableInventoryController.text = '';
    } else {
      _availableInventoryController.text =
          _editedProduct.availableInventory.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
            title: Text(_editedProduct.productName ?? 'Add New Product'),
            backgroundColor: Colors.purple[700],
            centerTitle: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _productNameController.text.isEmpty
                  ? _validateForProductName = true
                  : _validateForProductName = false;
              _unitController.text.isEmpty
                  ? _validateForUnit = true
                  : _validateForUnit = false;
              _priceController.text == '0.00'
                  ? _validateForPrice = true
                  : _validateForPrice = false;
              _dateOfExpiryController.text.isEmpty
                  ? _validateForDateOfExpiry = true
                  : _validateForDateOfExpiry = false;
              _availableInventoryController.text == ''
                  ? _validateForAvailableInventory = true
                  : _validateForAvailableInventory = false;
            });

            if (_validateForProductName == false &&
                _validateForUnit == false &&
                _validateForPrice == false &&
                _validateForDateOfExpiry == false &&
                _validateForAvailableInventory == false) {
              Navigator.pop(context, _editedProduct);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          label: Text("SUBMIT"),
          backgroundColor: Colors.purple[700],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 160.0,
                  height: 130.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _editedProduct.image != null
                          ? FileImage(File(_editedProduct.image))
                          : AssetImage('assets/images/questionMark.png'),
                    ),
                  ),
                ),
                onTap: () async {
                  await ImagePicker()
                      .getImage(source: ImageSource.gallery)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      _editedProduct.image = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _productNameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  errorText:
                      _validateForProductName ? 'No Product Name Found' : null,
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedProduct.productName = text;
                  });
                },
              ),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  errorText: _validateForUnit ? 'No Unit Found' : null,
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedProduct.unit = text;
                  });
                },
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  errorText: _validateForPrice ? 'No Price Found' : null,
                ),
                onChanged: (text) {
                  _userEdited = true;

                  _editedProduct.price = _priceController.numberValue;
                },
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dateOfExpiryController,
                decoration: InputDecoration(
                  labelText: 'Date of Expiry',
                  errorText: _validateForDateOfExpiry
                      ? 'No Date of Expiry Found'
                      : null,
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedProduct.dateOfExpiry = text;
                },
              ),
              TextField(
                controller: _availableInventoryController,
                decoration: InputDecoration(
                  labelText: 'Available Inventory',
                  errorText: _validateForAvailableInventory
                      ? 'No Available Inventory Found'
                      : null,
                ),
                onChanged: (text) {
                  _userEdited = true;

                  var convertedText = int.parse(text);
                  _editedProduct.availableInventory = convertedText;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String titleContent,
      String messageContent, String button1Content, String button2Content) {
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
        Navigator.pop(context);
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

  Future<bool> _requestPop() {
    if (_userEdited) {
      showAlertDialog(
          context, 'Attention', 'Do you want to discard?', 'Yes', 'No');
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
