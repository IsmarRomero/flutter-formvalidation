import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {

  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final productoProvider = new ProductosProvider();

  bool _guardando = false;

  File foto;

  ProductoModel producto = new ProductoModel();



  @override
  Widget build(BuildContext context) {

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
            IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ]
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton()
              ],
            ),
          )
        )
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto',
      
      ),
      onSaved: (value) => producto.titulo = value,
      validator: (value){
        if(value.length < 3) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }
  Widget _crearPrecio() {
      return TextFormField(
        initialValue: producto.valor.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Precio',
      ),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value) {
        if (utils.isNumeric(value)) {
          return null;
        } else {
          return 'Sólo números';
        }
      },
    );
  }

  Widget _crearDisponible() {
    return SwitchListTile(
      value: producto.disponible,
      activeColor: Colors.deepPurple,
      title: Text('Disponible'),
      onChanged: (value) => setState((){
        producto.disponible = value;
      }),
    );
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
        ),
        color: Colors.deepPurple,
        textColor: Colors.white,
      label: Text('Guardar'),
      icon: Icon(Icons.save),
      onPressed: (_guardando) ? null : _submit,
    );
  }

  void _submit() async {

  

  if (!formKey.currentState.validate()) return;
  formKey.currentState.save();

  setState(() {
    
  _guardando = true;
  });

  if (foto != null) {
    producto.fotoUrl = await productoProvider.subirImagen(foto);
  }

  if (producto.id == null) {
  productoProvider.crearProducto(producto);

  } else {
  productoProvider.editarProducto(producto);
    
  }
  //  setState(() {
    
  // _guardando = false;
  // });
  mostrarSnackbar('Registro guardado');

    Future.delayed(Duration(milliseconds: 1500), (){
    Navigator.pop(context);
    });
  }

  void mostrarSnackbar(String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),

      );
    scaffoldKey.currentState.showSnackBar(snackBar);

  }

  Widget _mostrarFoto() {
    if(producto.fotoUrl != null) {
      return FadeInImage(
        image: NetworkImage(producto.fotoUrl),
        placeholder: AssetImage('assets/original.gif'),
        fit: BoxFit.contain,
      );
    } else {
      return Image(
        image: AssetImage(foto?.path ?? 'assets/original.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  void _seleccionarFoto() async {
   _procesarImagen(ImageSource.gallery);

  }

  void _tomarFoto() async {
   _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async{
       foto = await ImagePicker.pickImage(
      source: origen
    );

    if (foto != null) {
      producto.fotoUrl = null;

    }
    setState(() {
      
    });
  }
}

// dm1ku2w4d
// image
// pu6tfbyg // Upload_reset