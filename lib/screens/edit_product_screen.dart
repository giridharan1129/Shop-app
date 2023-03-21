import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class EditProductsScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductsScreen({Key key}) : super(key: key);

  @override
  State<EditProductsScreen> createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final priceFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _editedProduct =
      Product(id: null, description: '', imageUrl: '', price: 0, title: '');

  @override
  void initState() {
    imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    priceFocusNode.dispose();
    descriptionFocusNode.dispose();
    imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg') &&
              !_imageUrlController.text.endsWith('.gif'))) {
        return;
      }
      setState(() {});
    }
  }

  void saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: saveForm, icon: Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(priceFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please provide a title';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          title: newValue);
                    },
                  ),
                  TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(value),
                            title: _editedProduct.title);
                      }),
                  TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Should be atleast 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            description: newValue,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            title: _editedProduct.title);
                      }),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: _imageUrlController.text.isEmpty
                            ? Text('Enter a Url')
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return ' Please enter a image Url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return "Please enter a valid URL";
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.gif')) {
                                return 'Please enter a valid image URL';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  description: _editedProduct.description,
                                  imageUrl: newValue,
                                  price: _editedProduct.price,
                                  title: _editedProduct.title);
                            }),
                      )
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
