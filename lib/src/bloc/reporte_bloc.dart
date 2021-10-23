import 'package:mesita_aplication_2/src/api/reportes_api.dart';
import 'package:mesita_aplication_2/src/database/productos_linea_database.dart';
import 'package:mesita_aplication_2/src/database/reporte_general_database.dart';
import 'package:mesita_aplication_2/src/database/reporte_linea_database.dart';
import 'package:mesita_aplication_2/src/database/reporte_producto_database.dart';
import 'package:mesita_aplication_2/src/models/reporte_general_model.dart';
import 'package:mesita_aplication_2/src/models/reporte_linea_model.dart';
import 'package:mesita_aplication_2/src/models/reporte_producto_model.dart';
import 'package:mesita_aplication_2/src/preferences/preferences.dart';
import 'package:rxdart/rxdart.dart';

class ReporteBloc {
  final _prefs = Preferences();
  final _reportesApi = ReportesApi();
  final _reportGDB = ReporteGeneralDatabase();
  final _reporteLineaDB = ReporteLineaDatabase();
  final _reporteProductoDB = ReporteProductoDatabase();

  final _reporteGeneralController = BehaviorSubject<List<ReporteGeneralModel>>();
  final _reportesLineaController = BehaviorSubject<List<ReporteLineaModel>>();
  final _reporteProductosController = BehaviorSubject<List<ReporteProductoModel>>();

  Stream<List<ReporteGeneralModel>> get reporteGeneralStream => _reporteGeneralController.stream;
  Stream<List<ReporteLineaModel>> get reporteLineaStream => _reportesLineaController.stream;
  Stream<List<ReporteProductoModel>> get reporteProductoStream => _reporteProductosController.stream;

  void obtenerReporteGeneralPorIdItem(String fechaI, String fechaF, int idItem) async {
    _reporteGeneralController.sink.add(await _reportGDB.obtenerReporteGeneralPorId(idItem.toString()));
    await _reportesApi.obtenerReportesLinea(fechaI, fechaF, idItem);
    _reporteGeneralController.sink.add(await _reportGDB.obtenerReporteGeneralPorId(idItem.toString()));
  }

  void obtenerReporteLinea() async {
    _reportesLineaController.sink.add([]);
    _reportesLineaController.sink.add(await _reporteLineaDB.obtenerReportLinea(_prefs.idNegocio));
  }

  void obtenerReporteProductos(String fechaI, String fechaF) async {
    _reporteProductosController.sink.add([]);
    await _reportesApi.obtenerReportesProductos(fechaI, fechaF);
    _reporteProductosController.sink.add(await obtenerReporteProducto());
  }

  Future<List<ReporteProductoModel>> obtenerReporteProducto() async {
    final _productosDatabase = ProductoLineaDatabase();
    final List<ReporteProductoModel> returnList = [];

    try {
      final reportDB = await _reporteProductoDB.obtenerProductoMasVendidos(_prefs.idNegocio);
      for (var i = 0; i < reportDB.length; i++) {
        final producto = await _productosDatabase.obtenerProductosPorIdProducto(reportDB[i].idProducto);

        if (producto.length > 0) {
          ReporteProductoModel report = ReporteProductoModel();

          report.idProducto = reportDB[i].idProducto;
          report.estado = reportDB[i].estado;
          report.cantidad = reportDB[i].cantidad;
          report.suma = reportDB[i].suma;
          report.idNegocio = reportDB[i].idNegocio;
          report.nombreProducto = producto[0].productoNombre;
          report.fotoProducto = producto[0].productoFoto;

          returnList.add(report);
        }
      }
      return returnList;
    } catch (e) {
      return returnList;
    }
  }

  dispose() {
    _reporteGeneralController?.close();
    _reportesLineaController?.close();
  }
}
