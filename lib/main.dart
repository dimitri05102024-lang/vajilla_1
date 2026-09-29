import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';

// ⚠️ IP configurada hacia el Backend Node.js
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          primary: const Color(0xFFB71C1C),
          secondary: const Color(0xFFD32F2F),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.5),
          ),
        ),
      ),
      home: const MainNavigatorPage(),
    );
  }
}

// ==========================================
// NAVEGACIÓN PRINCIPAL DE LA APLICACIÓN
// ==========================================
class MainNavigatorPage extends StatefulWidget {
  const MainNavigatorPage({super.key});

  @override
  State<MainNavigatorPage> createState() => _MainNavigatorPageState();
}

class _MainNavigatorPageState extends State<MainNavigatorPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RegistrarPage(),
    EstadisticasPage(),
    InformesPage(),
    ConfiguracionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFFEF5350),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  label: 'Registrar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_rounded),
                  label: 'Gráficas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.picture_as_pdf_rounded),
                  label: 'Informes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Ajustes',
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
// 1. PÁGINA DE INICIO
// ==========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildAppLogo({double size = 45}) {
    return Image.asset(
      'assets/icon/Logo_IN.PNG',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/icon/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.restaurant_menu, size: size, color: Colors.white),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppLogo(size: 32),
            const SizedBox(width: 10),
            const Text('Cocina Escolar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
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
                  colors: [cs.primary, const Color(0xFF8C0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildAppLogo(size: 48),
                  ),
                  const SizedBox(height: 10),
                  const Text('Menú de Gestión',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('INFRAMEN · Control de Vajilla',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return_rounded, color: Color(0xFFB71C1C)),
              title: const Text('Devolución de Utensilios', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Escanear carnet y devolver'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PendientesPage()),
                );
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
                boxShadow: [
                  BoxShadow(color: cs.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: _buildAppLogo(size: 42),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('¡Bienvenido al Sistema!',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('INFRAMEN · Control de Vajilla',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('Panel de Acceso Rápido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _AccesoCard(
                    icon: Icons.qr_code_scanner,
                    titulo: 'Escanear Retiro',
                    color: const Color(0xFFC62828),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarPage()));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _AccesoCard(
                    icon: Icons.assignment_return_rounded,
                    titulo: 'Ver Pendientes',
                    color: const Color(0xFF1E293B),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PendientesPage()));
                    },
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. PÁGINA DE REGISTRO DE RETIRO Y ESCANEO
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

  @override
  void dispose() {
    _carnetCtrl.dispose();
    super.dispose();
  }

  void _msg(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
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

      if (retResp.statusCode == 200 || retResp.statusCode == 201) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Estudiante no registrado'),
        content: Text('El código "$codigo" no se encuentra en la base de datos. ¿Deseas registrar a este estudiante ahora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegistrarEstudiantePage(codigoInicial: codigo)),
              );
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
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Control de Préstamo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Utensilio',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _tipos.map((t) => DropdownMenuItem(
                    value: t,
                    child: Row(children: [
                      Icon(_iconoTipo[t], size: 20, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(t),
                    ]),
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
                      elevation: 2,
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
// 3. PÁGINA DE ESTADÍSTICAS
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
  int _touchedIndex = -1;

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
          _fechaHoy = data['fecha'] ?? DateTime.now().toString().split(' ')[0];
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
    double total = 0;
    for (var item in _informe) {
      total += double.tryParse(item['entregados'].toString()) ?? 0.0;
    }

    return List.generate(_informe.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 75.0 : 65.0;
      final item = _informe[i];
      final tipo = item['tipo'] ?? 'Utensilio';
      final entregados = double.tryParse(item['entregados'].toString()) ?? 0.0;
      final porcentaje = total > 0 ? ((entregados / total) * 100).toStringAsFixed(1) : '0';

      Color colorUtensilio;
      switch (tipo) {
        case 'Plato':
          colorUtensilio = const Color(0xFF1E88E5);
          break;
        case 'Vaso':
          colorUtensilio = const Color(0xFFFB8C00);
          break;
        case 'Taza':
          colorUtensilio = const Color(0xFFE53935);
          break;
        default:
          colorUtensilio = const Color(0xFF43A047);
      }

      return PieChartSectionData(
        color: colorUtensilio,
        value: entregados,
        title: '$porcentaje%',
        radius: radius,
        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                child: Text('$tipo: ${entregados.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 11)),
              )
            : null,
        badgePositionPercentageOffset: 1.2,
      );
    });
  }

  Widget _buildLeyenda() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ItemLeyenda(color: Color(0xFF1E88E5), texto: 'Platos'),
        SizedBox(width: 15),
        _ItemLeyenda(color: Color(0xFFFB8C00), texto: 'Vasos'),
        SizedBox(width: 15),
        _ItemLeyenda(color: Color(0xFFE53935), texto: 'Tazas'),
      ],
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
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _obtenerEstadisticasHoy,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_fechaHoy.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Fecha de hoy: $_fechaHoy',
                    style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 13)),
              ),
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Proporción de Vajilla Entregada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200,
                      child: _cargando
                          ? const Center(child: CircularProgressIndicator())
                          : _informe.isEmpty
                              ? const Center(
                                  child: Text('No hay registros para hoy',
                                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                              : PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event.isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection == null) {
                                            _touchedIndex = -1;
                                            return;
                                          }
                                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                        });
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 40,
                                    sections: _generarDatosPastel(),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 15),
                    _buildLeyenda(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(
                          child: Text('Sin detalles de movimientos para hoy',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _informe.length,
                          itemBuilder: (context, index) {
                            final item = _informe[index];
                            final tipo = item['tipo'] ?? 'Utensilio';
                            final entregados = item['entregados'] ?? 0;
                            final devueltos = item['devueltos'] ?? 0;
                            final pendientes = item['pendientes'] ?? 0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: cs.primary.withOpacity(0.1),
                                  child: Icon(_iconoTipo[tipo] ?? Icons.analytics, color: cs.primary),
                                ),
                                title: Text("Utensilio: $tipo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Text("Entregados: $entregados | Devueltos: $devueltos | Pendientes: $pendientes",
                                    style: const TextStyle(fontSize: 12)),
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

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _ItemLeyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ==========================================
// 4. PÁGINA DE UTENSILIOS PENDIENTES Y DEVOLUCIÓN
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

  @override
  void dispose() {
    _carnetCtrl.dispose();
    super.dispose();
  }

  void _escanearCarnet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscaneoPage(
          onCodigoEscaneado: (codigo) {
            setState(() {
              _carnetCtrl.text = codigo; 
            });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron pendientes para este carnet'), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      setState(() => pendientes = []);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión con el servidor'), backgroundColor: Colors.red),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Devolución de $tipo registrada con éxito!'), backgroundColor: Colors.green.shade800),
        );
        obtenerPendientes();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo registrar la devolución'), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al intentar devolver'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pendientesFiltrados = pendientes.where((item) {
      final tipo = item['tipo'] ?? '';
      return tipo.toString().toLowerCase() == _categoriaSeleccionada.toLowerCase();
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
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
                          border: Border.all(color: seleccionado ? cs.primary : const Color(0xFFE2E8F0)),
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
                              decoration: BoxDecoration(
                                color: seleccionado ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
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
              child: Text('Utensilios pendientes:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _carnetCtrl.text.trim().isEmpty
                      ? const Center(
                          child: Text('Escanea o ingresa un carnet para ver y devolver los utensilios pendientes',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                      : pendientesFiltrados.isEmpty
                          ? Center(
                              child: Text('Este estudiante no tiene $_categoriaSeleccionada(s) pendientes',
                                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))
                          : ListView.builder(
                              itemCount: pendientesFiltrados.length,
                              itemBuilder: (context, index) {
                                final item = pendientesFiltrados[index];
                                final tipo = item['tipo'] ?? 'Utensilio';
                                final movimientoId = item['id'];
                                final fechaRetiro = item['fecha_retiro'] ?? '';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFFFEBEE),
                                      child: Icon(_iconoTipo[tipo] ?? Icons.restaurant, color: const Color(0xFFC62828)),
                                    ),
                                    title: Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    subtitle: Text('Retirado: $fechaRetiro', style: const TextStyle(fontSize: 12)),
                                    trailing: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E293B),
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
// 5. PÁGINA PARA REGISTRAR NUEVO ESTUDIANTE
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

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _carnetCtrl.dispose();
    _gradoCtrl.dispose();
    super.dispose();
  }

  void _msg(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
      ),
    );
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
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Registrar Nuevo Estudiante', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información del Alumno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _carnetCtrl,
                  decoration: const InputDecoration(labelText: 'Número de Carnet', prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _codigoCtrl,
                  decoration: const InputDecoration(labelText: 'Código de barras', prefixIcon: Icon(Icons.qr_code)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _gradoCtrl,
                  decoration: const InputDecoration(labelText: 'Grado / Sección (Ej: 2° Software)', prefixIcon: Icon(Icons.school_outlined)),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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
// 6. PÁGINA DE INFORMES Y EXPORTACIÓN
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

  final _iconoTipo = const {
    'Plato': Icons.dinner_dining,
    'Vaso': Icons.local_drink,
    'Taza': Icons.coffee,
  };

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }

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

  Future<void> _exportarPDF() async {
    if (_informe.isEmpty) return;

    final pdf = pw.Document();
    final fecha = _fechaController.text;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          cross: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Informe Diario - Cocina Escolar INFRAMEN", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text("Fecha del reporte: $fecha", style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Utensilio', 'Entregados', 'Devueltos', 'Pendientes'],
              data: _informe.map((item) => [
                item['tipo'].toString(),
                item['entregados'].toString(),
                (item['devueltos'] ?? 0).toString(),
                (item['pendientes'] ?? 0).toString()
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'informe_cocina_$fecha.pdf',
    );
  }

  Future<void> _exportarExcel() async {
    if (_informe.isEmpty) return;

    try {
      var excel = excel_pkg.Excel.createExcel();
      excel_pkg.Sheet sheet = excel['Informe'];
      excel.setDefaultSheet('Informe');

      sheet.appendRow([
        excel_pkg.TextCellValue("Utensilio"),
        excel_pkg.TextCellValue("Entregados"),
        excel_pkg.TextCellValue("Devueltos"),
        excel_pkg.TextCellValue("Pendientes")
      ]);

      for (var item in _informe) {
        sheet.appendRow([
          excel_pkg.TextCellValue(item['tipo'].toString()),
          excel_pkg.IntCellValue(int.tryParse(item['entregados'].toString()) ?? 0),
          excel_pkg.IntCellValue(int.tryParse((item['devueltos'] ?? 0).toString()) ?? 0),
          excel_pkg.IntCellValue(int.tryParse((item['pendientes'] ?? 0).toString()) ?? 0),
        ]);
      }

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/informe_cocina_${_fechaController.text}.xlsx";
        final file = File(path);
        await file.writeAsBytes(fileBytes, flush: true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guardado en teléfono: informe_cocina_${_fechaController.text}.xlsx'),
            backgroundColor: const Color(0xFF2E7D32),
            action: SnackBarAction(
              label: 'ABRIR',
              textColor: Colors.white,
              onPressed: () => OpenFilePlus.open(path),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar archivo Excel: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Exportación de Informes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                  tooltip: 'Abrir Calendario',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _cargando ? null : _obtenerInformeHistorico,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Obtener Informe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _informe.isEmpty ? null : _exportarPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportar PDF'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _informe.isEmpty ? null : _exportarExcel,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Exportar Excel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(
                          child: Text('Consulta una fecha para ver el detalle del informe',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _informe.length,
                          itemBuilder: (context, index) {
                            final item = _informe[index];
                            final tipo = item['tipo'] ?? 'Utensilio';
                            final entregados = item['entregados'] ?? 0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: cs.primary.withOpacity(0.1),
                                  child: Icon(_iconoTipo[tipo] ?? Icons.history, color: cs.primary),
                                ),
                                title: Text("Utensilio: $tipo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text('Conexión con el Servidor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.dns_rounded, color: Color(0xFFB71C1C)),
              title: Text('URL Base del Backend'),
              subtitle: Text(kBaseUrl),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          SizedBox(height: 20),
          Text('Información del Sistema', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school, color: Color(0xFFB71C1C)),
                  title: Text('Institución'),
                  subtitle: Text('INFRAMEN · Desarrollo de Software'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFFB71C1C)),
                  title: Text('Versión de la App'),
                  subtitle: Text('1.0.0+1'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PANTALLA DE ESCANEO DE CÁMARA
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
      appBar: AppBar(
        title: const Text('ESCANEAR CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 280,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.transparent,
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
          if (_scanned)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 64,
                  ),
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
