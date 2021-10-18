import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mesita_aplication_2/src/database/pedidos_temporales_database.dart';
import 'package:mesita_aplication_2/src/models/agregar_producto_pedido_model.dart';
import 'package:mesita_aplication_2/src/models/pedido_temporal_model.dart';
import 'package:mesita_aplication_2/src/preferences/preferences.dart';
import 'package:mesita_aplication_2/src/utils/constants.dart';

class PedidosApi {
  final _comandaDatabase = PedidosTemporalDatabase();

  final _prefs = Preferences();

  Future<bool> enviarComanda(String idMesa, String total) async {
    try {
      final comandaList = await _comandaDatabase.obtenerDetallesPedidoTemporales(idMesa);

      if (comandaList.length > 0) {
        double totalPedido = 0.0;

        var detalle = '';

        for (var i = 0; i < comandaList.length; i++) {
          totalPedido = totalPedido + double.parse(comandaList[i].subtotal);

          detalle += '${comandaList[i].idProducto};;;${comandaList[i].cantidad};;;${comandaList[i].subtotal};;;${comandaList[i].observaciones};;;${comandaList[i].llevar}//';
        }

        final url = Uri.parse('${apiBaseURL}/api/Negocio/guardar_pedido');

        final resp = await http.post(
          url,
          body: {
            'tn': '${_prefs.token}',
            'id_mesa': '$idMesa',
            'id_usuario': '${_prefs.idUser}',
            'pedido_total': '$totalPedido',
            'detalle': '$detalle',
            'app': 'true',
          },
        );

        final decodedData = json.decode(resp.body);

        print(decodedData);

        print(decodedData['exito']);
        if (decodedData['result']== '1') {

          await _comandaDatabase.deleteDetallesPedidoTemporal();
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");

      return false;
    }
  }

  Future<bool> agregarDetallePedido(String idPedido, DetalleProductoModel detalle) async {
    try {
      final List<DetalleProductoModel> detallesList = [];
      detallesList.add(detalle);

      AgreparProductoPedidoModel pedido = AgreparProductoPedidoModel();
      pedido.idPedido = idPedido;

      pedido.detalles = detallesList;
      pedido.token = '${_prefs.token}';

      var envio = jsonEncode(pedido.toJson());
      print(envio);
      final url = Uri.parse('${apiBaseURL}/api/Negocio/guardar_pedido_detalle');
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'tn': '${_prefs.token}',
      //   'app': 'true',
      // };

      final resp = await http.post(url, body: envio);

      final decodedData = json.decode(resp.body);

      print(decodedData);

      print(decodedData['exito']);
      if (decodedData['result']['code'] == 1) {
        return true;
      } else {
        return false;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");

      return false;
    }
  }
/* 
  Future<List<PedidoModel>> obtenerPedidosPorIdMesa(String idMesa) async {
    final List<PedidoModel> listaReturnPedidos = [];

    final listaPedidos = await _pedidosDatabase.obtenerPedidosPorIdMesa(idMesa);

    if (listaPedidos.length > 0) {
      for (var i = 0; i < listaPedidos.length; i++) {
        PedidoModel pedidos = PedidoModel();

        pedidos.idPedido = listaPedidos[i].idPedido;
        pedidos.idMesa = listaPedidos[i].idMesa;
        pedidos.total = listaPedidos[i].total;
        pedidos.fecha = listaPedidos[i].fecha;
        pedidos.estado = listaPedidos[i].fecha;

        final List<DetallePedidoModel> listDetalles = [];
        final listaDetallesPedido = await _pedidosDatabase.obtenerDetallesPedidoPorIdPedido(listaPedidos[i].idPedido);

        for (var x = 0; x < listaDetallesPedido.length; x++) {
          DetallePedidoModel detalles = DetallePedidoModel();

          detalles.idDetalle = listaDetallesPedido[x].idDetalle;
          detalles.idPedido = listaDetallesPedido[x].idPedido;
          detalles.idProducto = listaDetallesPedido[x].idProducto;
          detalles.cantidad = listaDetallesPedido[x].cantidad;
          detalles.totalDetalle = listaDetallesPedido[x].totalDetalle;
          detalles.observaciones = listaDetallesPedido[x].observaciones;
          detalles.estado = listaDetallesPedido[x].estado;
          detalles.llevar = listaDetallesPedido[x].llevar;

          final productoDB = await _productosDatabase.obtenerProductosPorIdProducto(listaDetallesPedido[x].idProducto);

          if (productoDB.length > 0) {
            detalles.subtotal = productoDB[0].productoPrecio;
            detalles.nombreProducto = productoDB[0].productoNombre;
            detalles.fotoProducto = productoDB[0].productoFoto;
          }

          listDetalles.add(detalles);
        }

        pedidos.detallesPedido = listDetalles;

        listaReturnPedidos.add(pedidos);
      }
    }
    return listaReturnPedidos;
  }

 */

}
