import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

// Cambia esta IP por la de tu PC (ipconfig -> IPv4) o emulador (10.0.2.2)
const String kBaseUrl = 'http://10.134.220.181:3000';

void main() => runApp(const CocinaEscolarApp());

class CocinaEscolarApp extends StatelessWidget {
  const CocinaEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2E7D32); // Verde institucional
    return MaterialApp(
      title: 'Cocina Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _carnetCtrl = TextEditingController();
  String _tipo = 'Plato';
  bool _cargando = false;
  List<dynamic> _informe = [];

  final _tipos = const ['Plato', 'Vaso', 'Taza'];
  final _iconoTipo = const {
    'Plato': Icons.dinner_dining,
    'Vaso': Icons.local_drink,
    'Taza': Icons.coffee,
  };

  void _msg(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _abrirEscaner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscaneoPage(
          onCodigoEscaneado: (codigo) {
            // Solo coloca el código en la caja de texto y detiene el escáner
            setState(() {
              _carnetCtrl.text = codigo;
            });
            _msg('Código escaneado con éxito. Presiona Registrar Retiro.');
          },
        ),
      ),
    );
  }

  Future<void> _registrarRetiro() async {
    final codigo = _carnetCtrl.text.trim();
    if (codigo.isEmpty) {
      _msg('Por favor ingresa o escanea un carnet', error: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      // 1) Buscar estudiante por carnet o código de barras
      final est = await http.get(Uri.parse('$kBaseUrl/estudiante/$codigo'));
      if (est.statusCode != 200) {
        _msg('Estudiante no encontrado', error: true);
        return;
      }
      final estudianteId = jsonDecode(est.body)['estudiante']['id'];

      // 2) Registrar retiro en el backend
      final resp = await http.post(
        Uri.parse('$kBaseUrl/retiro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estudiante_id': estudianteId, 'tipo': _tipo}),
      );
      if (resp.statusCode == 200) {
        _msg('Retiro de $_tipo registrado correctamente');
        _carnetCtrl.clear();
      } else {
        _msg('Error al registrar retiro', error: true);
      }
    } catch (_) {
      _msg('No se pudo conectar con el servidor', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _obtenerInforme() async {
    setState(() => _cargando = true);
    try {
      final resp = await http.get(Uri.parse('$kBaseUrl/informe'));
      if (resp.statusCode == 200) {
        setState(() => _informe = jsonDecode(resp.body)['informe'] ?? []);
      } else {
        _msg('Error al obtener informe', error: true);
      }
    } catch (_) {
      _msg('No se pudo conectar con el servidor', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text('Cocina Escolar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---- Encabezado Estilizado ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.restaurant_menu,
                        size: 44, color: cs.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text('Control de Vajilla Escolar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text('INFRAMEN · Desarrollo de Software',
                      style: TextStyle(color: Colors.white.withOpacity(.85))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Tarjeta de Registro y Escaneo ----
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registrar retiro',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _carnetCtrl,
                      decoration: InputDecoration(
                        labelText: 'Carnet / Código de barras',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.green),
                          onPressed: _abrirEscaner,
                          tooltip: 'Escanear código',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de utensilio',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _tipos
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Row(children: [
                                  Icon(_iconoTipo[t], size: 20),
                                  const SizedBox(width: 8),
                                  Text(t),
                                ]),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _tipo = v!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _cargando ? null : _registrarRetiro,
                      icon: const Icon(Icons.outbox),
                      label: const Text('Registrar Retiro'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _cargando ? null : _obtenerInforme,
                      icon: const Icon(Icons.assessment_outlined),
                      label: const Text('Ver Informe Diario'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Indicador de Carga e Informe ----
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            if (_informe.isNotEmpty) _tablaInforme(cs),
          ],
        ),
      ),
    );
  }

  Widget _tablaInforme(ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informe diario',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: cs.primary)),
            const SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Entreg.')),
                DataColumn(label: Text('Devueltos')),
                DataColumn(label: Text('Pend.')),
              ],
              rows: _informe.map<DataRow>((f) {
                return DataRow(cells: [
                  DataCell(Row(children: [
                    Icon(_iconoTipo[f['tipo']] ?? Icons.circle, size: 18),
                    const SizedBox(width: 6),
                    Text('${f['tipo']}'),
                  ])),
                  DataCell(Text('${f['entregados']}')),
                  DataCell(Text('${f['devueltos'] ?? 0}')),
                  DataCell(Text('${f['pendientes'] ?? 0}')),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Pantalla de Escaneo con el Marco Estilizado ----
class EscaneoPage extends StatefulWidget {
  final ValueChanged<String> onCodigoEscaneado;
  const EscaneoPage({super.key, required this.onCodigoEscaneado});

  @override
  State<EscaneoPage> createState() => _EscaneoPageState();
}

class _EscaneoPageState extends State<EscaneoPage> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _scanned = true;
        widget.onCodigoEscaneado(code);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ESCANEAR CÓDIGO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _esquinaMarco()),
                  Positioned(top: 0, right: 0, child: _esquinaMarco(rotar: 90)),
                  Positioned(bottom: 0, left: 0, child: _esquinaMarco(rotar: 270)),
                  Positioned(bottom: 0, right: 0, child: _esquinaMarco(rotar: 180)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _esquinaMarco({double rotar = 0}) {
    return Transform.rotate(
      angle: rotar * 3.1416 / 180,
      child: Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.blueAccent, width: 4),
            left: BorderSide(color: Colors.blueAccent, width: 4),
          ),
        ),
      ),
    );
  }
}
