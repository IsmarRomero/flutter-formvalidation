
import 'dart:convert';
import 'dart:io';

import 'package:formvalidation/src/models/producto_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:mime_type/mime_type.dart';

class ProductosProvider {

  final String _url = 'https://flutter-varios-b0a06.firebaseio.com';

  Future<bool> crearProducto(ProductoModel producto) async {
    final url = '$_url/productos.json';
    print('JSON ================ Body');
    print(productoModelToJson(producto));
    final response = await http.post(url, body: productoModelToJson(producto));

    final decodedData = json.decode(response.body);

    print(decodedData);

    return true;
  }

    Future<bool> editarProducto(ProductoModel producto) async {
    final url = '$_url/productos/${producto.id}.json';
    print('JSON ================ Body');
    print(productoModelToJson(producto));
    final response = await http.put(url, body: productoModelToJson(producto));

    final decodedData = json.decode(response.body);

    print(decodedData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json';
    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    
    final List<ProductoModel> productos = List();

    if (decodedData == null) return [];

    decodedData.forEach((id, producto) {
      final prodTemp = ProductoModel.fromJson(producto);
      prodTemp.id = id;

      productos.add(prodTemp);
     });

     print(productos);

    return productos;
  }

  Future<int> borrarProducto(String id ) async {

     final url = '$_url/productos/$id.json';
     final resp = await http.delete(url);

     print(resp.body);

     return 1;
  }

  Future<String> subirImagen(File imagen) async {
    
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dm1ku2w4d/image/upload?upload_preset=pu6tfbyg');

    final mimeType = mime(imagen.path).split('/'); //image/jpeg

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url
      );

    final file = await http.MultipartFile.fromPath(
      'file', imagen.path,
      contentType: MediaType(mimeType[0], mimeType[1]));

      imageUploadRequest.files.add(file);

      final streamResponse = await imageUploadRequest.send();

      final resp = await http.Response.fromStream(streamResponse);

      if(resp.statusCode != 200 && resp.statusCode != 201){
        print('algo salio mal');
        print(resp.body);
        return null;
      }

      final respData = json.decode(resp.body);
      print(respData);
      return respData['secure_url'];
  }
}