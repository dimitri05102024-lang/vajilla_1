import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fl_chart/fl_chart.dart'; // <--- Paquete para gráficas

// ⚠️ IP actualizada correctamente según tu red
const String kBaseUrl = 'http://10.198.197.181:3000';

void main() => runApp(const CocinaEscolarApp());

class CocinaEscolarApp extends StatelessWidget {
  const CocinaEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFB71C1C); // Rojo institucional profundo
    return MaterialApp(
      title: 'Cocina Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
      home: const MainNavigatorPage(),
    );
  }
}

// ==========================================
// NAVEGACIÓN PRINCIPAL (5 PESTAÑAS)
// ==========================================
class MainNavigatorPage extends StatefulWidget {
  const MainNavigatorPage({super.key});

  @override
  State<MainNavigatorPage> createState() => _MainNavigatorPageState();
}

class _MainNavigatorPageState extends State<MainNavigatorPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const RegistrarPage(),
    const EstadisticasPage(),
    const InformesPage(),
    const ConfiguracionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFEF5350),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Registrar'),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Gráficas'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Informes'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. PÁGINA DE INICIO
// ==========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Cocina Escolar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, const Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.restaurant_menu, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Menú de Gestión', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('INFRAMEN · Control de Vajilla', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return_rounded, color: Color(0xFFB71C1C)),
              title: const Text('Devolución de Utensilios', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Escanear carnet y devolver'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PendientesPage()));
              },
            ),
            const Divider(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, const Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.restaurant_menu, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¡Bienvenido al Sistema!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('INFRAMEN · Control Inteligente', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('Panel de Acceso Rápido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _AccesoCard(
                    icon: Icons.qr_code_scanner,
                    titulo: 'Escanear Retiro',
                    color: const Color(0xFFC62828),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarPage())),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _AccesoCard(
                    icon: Icons.warning_amber_rounded,
                    titulo: 'Ver Pendientes',
                    color: Colors.grey.shade800,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendientesPage())),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccesoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _AccesoCard({required this.icon, required this.titulo, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 26, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 12),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. REGISTRO DE RETIRO
// ==========================================
class RegistrarPage extends StatefulWidget {
  const RegistrarPage({super.key});

  @override
  State<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  final _carnetCtrl = TextEditingController();
  String _tipo = 'Plato';
  bool _cargando = false;

  final _tipos = const ['Plato', 'Vaso', 'Taza'];
  final _iconoTipo = const {
    'Plato': Icons.dinner_dining,
    'Vaso': Icons.local_drink,
    'Taza': Icons.coffee,
  };

  void _msg(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: error ? Colors.red.shade800 : Colors.grey.shade800, behavior: SnackBarBehavior.floating),
    );
  }

  void _abrirEscaner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscaneoPage(
          onCodigoEscaneado: (codigo) {
            setState(() => _carnetCtrl.text = codigo);
            _procesarRetiro(codigo);
          },
        ),
      ),
    );
  }

  Future<void> _procesarRetiro(String codigo) async {
    if (codigo.trim().isEmpty) return;
    setState(() => _cargando = true);
    try {
      final estResp = await http.get(Uri.parse('$kBaseUrl/estudiante/$codigo'));
      if (estResp.statusCode == 404) {
        if (!mounted) return;
        _mostrarDialogoEstudianteNoEncontrado(codigo);
        return;
      }
      if (estResp.statusCode != 200) {
        _msg('Error al conectar con el servidor', error: true);
        return;
      }

      final estudianteId = jsonDecode(estResp.body)['estudiante']['id'];
      final retResp = await http.post(
        Uri.parse('$kBaseUrl/retiro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estudiante_id': estudianteId, 'tipo': _tipo}),
      );

      if (retResp.statusCode == 200) {
        _msg('¡Retiro de $_tipo registrado con éxito!');
        _carnetCtrl.clear();
      } else {
        _msg('Error al registrar el retiro', error: true);
      }
    } catch (_) {
      _msg('No se pudo establecer conexión con el servidor', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarDialogoEstudianteNoEncontrado(String codigo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estudiante no registrado'),
        content: Text('El código "$codigo" no se encuentra en la base de datos. ¿Deseas registrar al alumno ahora?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrarEstudiantePage(codigoInicial: codigo)));
            },
            child: const Text('Registrar Alumno'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Registrar Retiro de Vajilla', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Control de Préstamo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Escanea el carnet o ingresa el código del alumno.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                TextField(
                  controller: _carnetCtrl,
                  decoration: InputDecoration(
                    labelText: 'Carnet / Código de barras',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.camera_alt, color: cs.primary),
                      onPressed: _abrirEscaner,
                      tooltip: 'Escanear con cámara',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo de Utensilio', prefixIcon: Icon(Icons.category_outlined)),
                  items: _tipos.map((t) => DropdownMenuItem(
                    value: t,
                    child: Row(children: [Icon(_iconoTipo[t], size: 20, color: cs.primary), const SizedBox(width: 8), Text(t)]),
                  )).toList(),
                  onChanged: (v) => setState(() => _tipo = v!),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _cargando ? null : () => _procesarRetiro(_carnetCtrl.text.trim()),
                    icon: _cargando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.outbox_rounded),
                    label: Text(_cargando ? 'Procesando...' : 'Registrar Retiro', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. PÁGINA DE ESTADÍSTICAS (Con Selector de Gráfica: Pastel o Barras)
// ==========================================
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  bool _cargando = false;
  List<dynamic> _informe = [];
  String _fechaHoy = '';
  bool _mostrarBarras = false; // Alternar entre estilo pastel y barras

  final _iconoTipo = const {
    'Plato': Icons.dinner_dining,
    'Vaso': Icons.local_drink,
    'Taza': Icons.coffee,
  };

  @override
  void initState() {
    super.initState();
    _obtenerEstadisticasHoy();
  }

  Future<void> _obtenerEstadisticasHoy() async {
    setState(() => _cargando = true);
    try {
      final url = Uri.parse('$kBaseUrl/informe');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _informe = data is List ? data : (data['informe'] ?? []);
          _fechaHoy = data['fecha'] ?? '';
        });
      } else {
        setState(() => _informe = []);
      }
    } catch (_) {
      setState(() => _informe = []);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Estilo Gráfica Pastel Mejorado
  List<PieChartSectionData> _generarDatosPastel() {
    return _informe.map((item) {
      final tipo = item['tipo'] ?? 'Utensilio';
      final entregados = double.tryParse(item['entregados'].toString()) ?? 0.0;
      
      Color colorUtensilio = Colors.blue;
      if (tipo == 'Plato') colorUtensilio = const Color(0xFF1976D2);
      if (tipo == 'Vaso') colorUtensilio = const Color(0xFF00897B);
      if (tipo == 'Taza') colorUtensilio = const Color(0xFF8E24AA);

      return PieChartSectionData(
        value: entregados,
        title: "$tipo\n($entregados)",
        color: colorUtensilio,
        radius: 70,
        badgeWidget: Icon(_iconoTipo[tipo], color: Colors.white, size: 16),
        badgePositionPercentageOffset: .75,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // Estilo Gráfica de Barras Modernas
  BarChartData _generarDatosBarras() {
    int index = 0;
    List<Color> colores = [const Color(0xFF2E7D32), const Color(0xFF00897B), const Color(0xFF8E24AA), const Color(0xFFD32F2F)];

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _informe.fold(5.0, (max, item) {
        double val = double.tryParse(item['entregados'].toString()) ?? 0.0;
        return val > max ? val + 2 : max;
      }),
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              int idx = value.toInt();
              if (idx >= 0 && idx < _informe.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_informe[idx]['tipo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      barGroups: _informe.map((item) {
        final val = double.tryParse(item['entregados'].toString()) ?? 0.0;
        final color = colores[index % colores.length];
        final rod = BarChartRodData(
          toY: val,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: Colors.grey.shade200),
        );
        index++;
        return BarChartGroupData(x: index - 1, barRods: [rod]);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Estadísticas del Día', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_mostrarBarras ? Icons.pie_chart : Icons.bar_chart),
            onPressed: () => setState(() => _mostrarBarras = !_mostrarBarras),
            tooltip: 'Cambiar estilo de gráfica',
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _obtenerEstadisticasHoy, tooltip: 'Actualizar'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_fechaHoy.isNotEmpty)
                  Text('Fecha: $_fechaHoy', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(_mostrarBarras ? 'Estilo: Barras' : 'Estilo: Pastel', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 220,
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(child: Text('No hay registros estadísticos para hoy', style: TextStyle(color: Colors.grey)))
                      : _mostrarBarras
                          ? BarChart(_generarDatosBarras())
                          : PieChart(
                              PieChartData(
                                sections: _generarDatosPastel(),
                                centerSpaceRadius: 40,
                                sectionsSpace: 3,
                              ),
                            ),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 5),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(child: Text('Sin detalles de movimientos para hoy', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _informe.length,
                          itemBuilder: (context, index) {
                            final item = _informe[index];
                            final tipo = item['tipo'] ?? 'Utensilio';
                            final entregados = item['entregados'] ?? 0;
                            final devueltos = item['devueltos'] ?? 0;
                            final pendientes = item['pendientes'] ?? 0;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: cs.primary.withOpacity(0.1),
                                  child: Icon(_iconoTipo[tipo] ?? Icons.analytics, color: cs.primary),
                                ),
                                title: Text("Utensilio: $tipo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Text("Entregados: $entregados | Devueltos: $devueltos | Pendientes: $pendientes", style: const TextStyle(fontSize: 12)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. UTENSILIOS PENDIENTES Y DEVOLUCIÓN
// ==========================================
class PendientesPage extends StatefulWidget {
  const PendientesPage({super.key});

  @override
  State<PendientesPage> createState() => _PendientesPageState();
}

class _PendientesPageState extends State<PendientesPage> {
  final _carnetCtrl = TextEditingController();
  List<dynamic> pendientes = [];
  bool _cargando = false;
  String _categoriaSeleccionada = 'Plato';

  final List<String> _tipos = const ['Plato', 'Vaso', 'Taza'];
  final Map<String, IconData> _iconoTipo = const {
    'Plato': Icons.dinner_dining,
    'Vaso': Icons.local_drink,
    'Taza': Icons.coffee,
  };

  void _escanearCarnet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscaneoPage(
          onCodigoEscaneado: (codigo) {
            setState(() => _carnetCtrl.text = codigo);
            obtenerPendientes();
          },
        ),
      ),
    );
  }

  Future<void> obtenerPendientes() async {
    final carnet = _carnetCtrl.text.trim();
    if (carnet.isEmpty) return;
    
    setState(() => _cargando = true);
    try {
      final url = Uri.parse('$kBaseUrl/pendientes/$carnet');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pendientes = data is List ? data : (data['pendientes'] ?? []);
        });
      } else {
        setState(() => pendientes = []);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontraron pendientes para este carnet'), backgroundColor: Colors.red));
      }
    } catch (_) {
      setState(() => pendientes = []);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión con el servidor'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _registrarDevolucion(dynamic movimientoId, String tipo) async {
    if (movimientoId == null) return;
    try {
      final url = Uri.parse('$kBaseUrl/devolucion/$movimientoId');
      final response = await http.put(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Devolución de $tipo registrada con éxito!'), backgroundColor: Colors.green.shade800));
        obtenerPendientes();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo registrar la devolución'), backgroundColor: Colors.red));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al intentar devolver'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pendientesFiltrados = pendientes.where((item) {
      final tipo = item['tipo'] ?? '';
      return tipo.toLowerCase() == _categoriaSeleccionada.toLowerCase();
    }).toList();

    Map<String, int> contadores = {
      'Plato': pendientes.where((i) => (i['tipo'] ?? '').toString().toLowerCase() == 'plato').length,
      'Vaso': pendientes.where((i) => (i['tipo'] ?? '').toString().toLowerCase() == 'vaso').length,
      'Taza': pendientes.where((i) => (i['tipo'] ?? '').toString().toLowerCase() == 'taza').length,
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Devolución de Utensilios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _carnetCtrl,
              decoration: InputDecoration(
                labelText: 'Carnet del Alumno',
                prefixIcon: const Icon(Icons.badge_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.camera_alt, color: cs.primary),
                  onPressed: _escanearCarnet,
                  tooltip: 'Escanear Carnet',
                ),
              ),
              onSubmitted: (_) => obtenerPendientes(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: obtenerPendientes,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Buscar Pendientes del Alumno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 20),
            if (_carnetCtrl.text.trim().isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Filtrar por categoría:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 10),
              Row(
                children: _tipos.map((tipo) {
                  final seleccionado = _categoriaSeleccionada == tipo;
                  final cantidad = contadores[tipo] ?? 0;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _categoriaSeleccionada = tipo),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color: seleccionado ? cs.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: seleccionado ? cs.primary : Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_iconoTipo[tipo], color: seleccionado ? Colors.white : cs.primary, size: 22),
                            const SizedBox(height: 4),
                            Text(tipo, style: TextStyle(color: seleccionado ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: seleccionado ? Colors.white.withOpacity(0.2) : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                              child: Text('$cantidad', style: TextStyle(color: seleccionado ? Colors.white : Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
            ],
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Utensilios pendientes:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _carnetCtrl.text.trim().isEmpty
                      ? const Center(child: Text('Escanea o ingresa un carnet para ver pendientes', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                      : pendientesFiltrados.isEmpty
                          ? Center(child: Text('Este estudiante no tiene $_categoriaSeleccionada(s) pendientes', textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))
                          : ListView.builder(
                              itemCount: pendientesFiltrados.length,
                              itemBuilder: (context, index) {
                                final item = pendientesFiltrados[index];
                                final tipo = item['tipo'] ?? 'Utensilio';
                                final movimientoId = item['id'];
                                final fechaRetiro = item['fecha_retiro'] ?? '';

                                return Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFFFEBEE),
                                      child: Icon(_iconoTipo[tipo] ?? Icons.restaurant, color: const Color(0xFFC62828)),
                                    ),
                                    title: Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    subtitle: Text('Retirado: $fechaRetiro', style: const TextStyle(fontSize: 12)),
                                    trailing: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade900,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: () => _registrarDevolucion(movimientoId, tipo),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Devolver', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. REGISTRAR NUEVO ESTUDIANTE
// ==========================================
class RegistrarEstudiantePage extends StatefulWidget {
  final String codigoInicial;
  const RegistrarEstudiantePage({super.key, this.codigoInicial = ''});

  @override
  State<RegistrarEstudiantePage> createState() => _RegistrarEstudiantePageState();
}

class _RegistrarEstudiantePageState extends State<RegistrarEstudiantePage> {
  late final TextEditingController _codigoCtrl;
  final _nombreCtrl = TextEditingController();
  final _carnetCtrl = TextEditingController();
  final _gradoCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _codigoCtrl = TextEditingController(text: widget.codigoInicial);
    _carnetCtrl.text = widget.codigoInicial;
  }

  void _msg(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), backgroundColor: error ? Colors.red.shade800 : Colors.grey.shade800));
  }

  Future<void> _guardarEstudiante() async {
    if (_nombreCtrl.text.trim().isEmpty || _carnetCtrl.text.trim().isEmpty || _codigoCtrl.text.trim().isEmpty) {
      _msg('Por favor completa todos los campos obligatorios', error: true);
      return;
    }

    setState(() => _guardando = true);
    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/estudiante'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombreCtrl.text.trim(),
          'carnet': _carnetCtrl.text.trim(),
          'codigo_barra': _codigoCtrl.text.trim(),
          'grado': _gradoCtrl.text.trim(),
        }),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _msg('Estudiante registrado exitosamente');
        if (mounted) Navigator.pop(context);
      } else {
        _msg('Error al registrar estudiante en el servidor', error: true);
      }
    } catch (_) {
      _msg('No se pudo conectar con el servidor backend', error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: cs.primary, foregroundColor: Colors.white, title: const Text('Registrar Nuevo Estudiante', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información del Alumno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 15),
                TextField(controller: _carnetCtrl, decoration: const InputDecoration(labelText: 'Número de Carnet', prefixIcon: Icon(Icons.badge_outlined))),
                const SizedBox(height: 15),
                TextField(controller: _codigoCtrl, decoration: const InputDecoration(labelText: 'Código de barras', prefixIcon: Icon(Icons.qr_code))),
                const SizedBox(height: 15),
                TextField(controller: _gradoCtrl, decoration: const InputDecoration(labelText: 'Grado / Sección (Ej: 2° Software)', prefixIcon: Icon(Icons.school_outlined))),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: _guardando ? null : _guardarEstudiante,
                    child: Text(_guardando ? 'Guardando...' : 'Guardar Estudiante', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. INFORMES HISTÓRICOS (Con selector de fecha y gráficas)
// ==========================================
class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
  final _fechaController = TextEditingController();
  bool _cargando = false;
  List<dynamic> _informe = [];
  bool _mostrarBarras = false;

  final _iconoTipo = const {
    'Plato': Icons.dinner_dining,
    'Vaso': Icons.local_drink,
    'Taza': Icons.coffee,
  };

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaController.text = fechaSeleccionada.toIso8601String().split('T')[0];
      });
      _obtenerInformeHistorico();
    }
  }

  Future<void> _obtenerInformeHistorico() async {
    final fecha = _fechaController.text.trim();
    if (fecha.isEmpty) return;

    setState(() => _cargando = true);
    try {
      final url = Uri.parse('$kBaseUrl/informe/$fecha');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _informe = data is List ? data : (data['informe'] ?? []);
        });
      } else {
        setState(() => _informe = []);
      }
    } catch (_) {
      setState(() => _informe = []);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<PieChartSectionData> _generarDatosPastel() {
    return _informe.map((item) {
      final tipo = item['tipo'] ?? 'Utensilio';
      final entregados = double.tryParse(item['entregados'].toString()) ?? 0.0;
      return PieChartSectionData(
        value: entregados,
        title: "$tipo\n($entregados)",
        color: tipo == 'Plato' ? Colors.blue : (tipo == 'Vaso' ? Colors.teal : Colors.purple),
        radius: 65,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Informe Histórico', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_mostrarBarras ? Icons.pie_chart : Icons.bar_chart),
            onPressed: () => setState(() => _mostrarBarras = !_mostrarBarras),
            tooltip: 'Cambiar vista de gráfica',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha (YYYY-MM-DD)',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.event_note, color: cs.primary),
                  onPressed: () => _seleccionarFecha(context),
                  tooltip: 'Calendario',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: _cargando ? null : _obtenerInformeHistorico,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Consultar Informe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 180,
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(child: Text('Selecciona una fecha para ver la gráfica', style: TextStyle(color: Colors.grey)))
                      : _mostrarBarras
                          ? BarChart(
                              BarChartData(
                                barGroups: _informe.asMap().entries.map((e) {
                                  double val = double.tryParse(e.value['entregados'].toString()) ?? 0.0;
                                  return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: val, color: Colors.teal, width: 20)]);
                                }).toList(),
                                titlesData: const FlTitlesData(
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                ),
                              ),
                            )
                          : PieChart(PieChartData(sections: _generarDatosPastel(), centerSpaceRadius: 35)),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(child: Text('No hay registros detallados para mostrar', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _informe.length,
                          itemBuilder: (context, index) {
                            final item = _informe[index];
                            final tipo = item['tipo'] ?? 'Utensilio';
                            final entregados = item['entregados'] ?? 0;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: cs.primary.withOpacity(0.1), child: Icon(_iconoTipo[tipo] ?? Icons.history, color: cs.primary)),
                                title: Text("Utensilio: $tipo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Text("Entregados: $entregados", style: const TextStyle(fontSize: 13)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. CONFIGURACIÓN
// ==========================================
class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: cs.primary, foregroundColor: Colors.white, title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Conexión con el Servidor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const ListTile(
              leading: Icon(Icons.dns_rounded, color: Color(0xFFB71C1C)),
              title: Text('URL Base del Backend'),
              subtitle: Text(kBaseUrl),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Información del Sistema', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                ListTile(leading: Icon(Icons.school, color: Color(0xFFB71C1C)), title: Text('Institución'), subtitle: Text('INFRAMEN · Desarrollo de Software')),
                Divider(height: 1),
                ListTile(leading: Icon(Icons.info_outline, color: Color(0xFFB71C1C)), title: Text('Versión de la App'), subtitle: Text('1.0.1+2')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PANTALLA DE ESCANEO
// ==========================================
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
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        _scanned = true;
        setState(() {});
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onCodigoEscaneado(code);
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('ESCANEAR CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), backgroundColor: const Color(0xFF212121), foregroundColor: Colors.white, centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
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
          if (_scanned)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFFC62828), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 64),
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
            top: BorderSide(color: Color(0xFFEF5350), width: 4),
            left: BorderSide(color: Color(0xFFEF5350), width: 4),
          ),
        ),
      ),
    );
  }
}
