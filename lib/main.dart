import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';

const String kBaseUrl = 'http://10.198.197.181:3000';

// Servicio Global de Notificaciones Locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Clave global de navegación para mostrar notificaciones flotantes superiores estilo app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const CocinaEscolarApp());
}

// Sistema de Notificación Flotante Superior (Estilo App Moderna)
void mostrarNotificacionApp(String titulo, String cuerpo, {bool esError = false}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              esError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cuerpo,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: esError ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0), // Aparece arriba simulando notificación push
      elevation: 6,
      duration: const Duration(seconds: 4),
    ),
  );
}

Future<void> mostrarNotificacionLocal(String titulo, String cuerpo) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'canal_cafetin_inframen',
    'Notificaciones Cafetín',
    channelDescription: 'Avisos en tiempo real sobre retiros y devoluciones',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    titulo,
    cuerpo,
    platformChannelSpecifics,
  );
}

class CocinaEscolarApp extends StatelessWidget {
  const CocinaEscolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFB71C1C);
    return MaterialApp(
      navigatorKey: navigatorKey,
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
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

class MainNavigatorPage extends StatefulWidget {
  const MainNavigatorPage({super.key});

  @override
  State<MainNavigatorPage> createState() => _MainNavigatorPageState();
}

class _MainNavigatorPageState extends State<MainNavigatorPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    EntregaModuloPage(),
    InventarioModuloPage(),
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
              color: Colors.black.withOpacity(0.12),
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
                  icon: Icon(Icons.restaurant_rounded),
                  label: 'Entrega',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: 'Inventario',
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
// MÓDULO 1: ENTREGA DE ALIMENTOS
// ==========================================
class EntregaModuloPage extends StatelessWidget {
  const EntregaModuloPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Módulo: Entrega de Alimentos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AccesoCard(
            icon: Icons.qr_code_scanner_rounded,
            titulo: 'Registrar Retiro',
            subtitulo: 'Escanear carnet y prestar utensilio',
            color: const Color(0xFFB71C1C),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarPage())),
          ),
          const SizedBox(height: 16),
          _AccesoCard(
            icon: Icons.assignment_return_rounded,
            titulo: 'Ver Pendientes y Devoluciones',
            subtitulo: 'Seleccionar modo de devolución del día y escanear',
            color: const Color(0xFF1E293B),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendientesPage())),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MÓDULO 2: INVENTARIO Y REPORTES
// ==========================================
class InventarioModuloPage extends StatelessWidget {
  const InventarioModuloPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Módulo: Inventario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AccesoCard(
            icon: Icons.pie_chart_rounded,
            titulo: 'Estadísticas del Día',
            subtitulo: 'Gráficos y disponibilidad actual',
            color: const Color(0xFF0284C7),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EstadisticasPage())),
          ),
          const SizedBox(height: 16),
          _AccesoCard(
            icon: Icons.picture_as_pdf_rounded,
            titulo: 'Informes Históricos (PDF y Excel)',
            subtitulo: 'Consultar fechas anteriores y exportar reportes',
            color: const Color(0xFF16A34A),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InformesPage())),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildAppLogo({double size = 85}) {
    return Image.asset(
      'assets/icon/Logo_IN.PNG',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.school_rounded, size: size, color: const Color(0xFFB71C1C));
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
        title: const Text('Cocina Escolar INFRAMEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, const Color(0xFFFFF5F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAppLogo(size: 90),
                    const SizedBox(height: 14),
                    const Text(
                      'INFRAMEN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sistema Integral de Gestión de Cafetín',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Módulos de Operación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AccesoCard(
                    icon: Icons.restaurant_rounded,
                    titulo: 'Entrega de Alimentos',
                    subtitulo: 'Retiros y devoluciones',
                    color: const Color(0xFFB71C1C),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EntregaModuloPage()));
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AccesoCard(
                    icon: Icons.inventory_2_rounded,
                    titulo: 'Inventario',
                    subtitulo: 'Informes y estadísticas',
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const InventarioModuloPage()));
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
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _AccesoCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA: REGISTRAR RETIRO (CON MODO AUTOMÁTICO/MANUAL)
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
  bool _autoGuardado = true; // Interruptor para autoguardado al escanear

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

  void _abrirEscaner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscaneoPage(
          onCodigoEscaneado: (codigo) {
            setState(() => _carnetCtrl.text = codigo);
            // Si el modo automático está activo, procesa de inmediato al escanear
            if (_autoGuardado) {
              _procesarRetiro(codigo);
            } else {
              mostrarNotificacionApp('Código Capturado', 'Carnet $codigo listo. Presiona "Registrar Retiro".');
            }
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
        mostrarNotificacionApp('Error de Servidor', 'No se pudo conectar con el servidor', esError: true);
        return;
      }

      final estudianteId = jsonDecode(estResp.body)['estudiante']['id'];

      final retResp = await http.post(
        Uri.parse('$kBaseUrl/retiro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estudiante_id': estudianteId, 'tipo': _tipo}),
      );

      if (retResp.statusCode == 200 || retResp.statusCode == 201) {
        mostrarNotificacionApp('¡Préstamo Exitoso!', 'Se registró un retiro de $_tipo para el carnet $codigo');
        await mostrarNotificacionLocal(
          'Retiro Registrado',
          'Se registró un préstamo de $_tipo para el carnet $codigo',
        );
        _carnetCtrl.clear();
      } else {
        mostrarNotificacionApp('Error', 'Error al registrar el retiro', esError: true);
      }
    } catch (_) {
      mostrarNotificacionApp('Error de Red', 'No se pudo establecer conexión con el servidor', esError: true);
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
                const SizedBox(height: 16),
                // Interruptor para alternar Modo Automático o Manual al escanear
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _autoGuardado ? Icons.bolt_rounded : Icons.touch_app_rounded,
                            color: _autoGuardado ? const Color(0xFF16A34A) : Colors.grey,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Guardado automático al escanear', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                              Text(_autoGuardado ? 'Se guarda al instante de escanear' : 'Requiere pulsar el botón manual', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _autoGuardado,
                        activeColor: const Color(0xFF16A34A),
                        onChanged: (val) => setState(() => _autoGuardado = val),
                      ),
                    ],
                  ),
                ),
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
      final radius = isTouched ? 68.0 : 58.0;
      final item = _informe[i];
      final tipo = item['tipo'] ?? 'Utensilio';
      final entregados = double.tryParse(item['entregados'].toString()) ?? 0.0;
      final porcentaje = total > 0 ? (entregados / total * 100) : 0.0;

      Color colorUtensilio;
      switch (tipo) {
        case 'Plato':
          colorUtensilio = const Color(0xFF2563EB);
          break;
        case 'Vaso':
          colorUtensilio = const Color(0xFFF59E0B);
          break;
        case 'Taza':
          colorUtensilio = const Color(0xFFEF4444);
          break;
        default:
          colorUtensilio = const Color(0xFF10B981);
      }

      return PieChartSectionData(
        color: colorUtensilio,
        value: entregados,
        title: '${porcentaje.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 15.0 : 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
        borderSide: isTouched ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
      );
    });
  }

  int _calcularTotalEntregados() {
    int total = 0;
    for (var item in _informe) {
      total += int.tryParse(item['entregados'].toString()) ?? 0;
    }
    return total;
  }

  Widget _buildLeyenda() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ItemLeyenda(color: Color(0xFF2563EB), texto: 'Platos'),
          _ItemLeyenda(color: Color(0xFFF59E0B), texto: 'Vasos'),
          _ItemLeyenda(color: Color(0xFFEF4444), texto: 'Tazas'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalEntregados = _calcularTotalEntregados();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_fechaHoy.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 8),
                    Text('Fecha actual: $_fechaHoy',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 13)),
                  ],
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Distribución de Vajilla Entregada',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      child: _cargando
                          ? const Center(child: CircularProgressIndicator())
                          : _informe.isEmpty
                              ? const Center(
                                  child: Text('No hay registros para hoy',
                                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                              : Stack(
                                  children: [
                                    PieChart(
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
                                        sectionsSpace: 4,
                                        centerSpaceRadius: 55,
                                        sections: _generarDatosPastel(),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$totalEntregados',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const Text(
                                            'Total',
                                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                    const SizedBox(height: 20),
                    _buildLeyenda(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Detalle por Utensilio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
            const SizedBox(height: 12),
            _cargando
                ? const Center(child: CircularProgressIndicator())
                : _informe.isEmpty
                    ? const Center(
                        child: Text('Sin detalles de movimientos para hoy',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _informe.length,
                        itemBuilder: (context, index) {
                          final item = _informe[index];
                          final tipo = item['tipo'] ?? 'Utensilio';
                          final entregados = item['entregados'] ?? 0;
                          final devueltos = item['devueltos'] ?? 0;
                          final pendientes = item['pendientes'] ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: cs.primary.withOpacity(0.08),
                                    child: Icon(_iconoTipo[tipo] ?? Icons.analytics, color: cs.primary, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 4),
                                        Text('Entregados: $entregados', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Devueltos: $devueltos', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                                      const SizedBox(height: 2),
                                      Text('Pendientes: $pendientes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      ],
    );
  }
}

// ==========================================
// PANTALLA: DEVOLUCIÓN DE PENDIENTES (FILTRA SOLO DEL DÍA ACTUAL)
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
  
  final List<String> _modosSeleccionados = ['Plato']; 
  final List<String> _tiposDisponibles = const ['Plato', 'Vaso', 'Taza'];
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

  void _escanearParaDevolver() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscaneoPage(
          onCodigoEscaneado: (codigo) {
            setState(() {
              _carnetCtrl.text = codigo; 
            });
            _procesarDevolucionMasivaPorEscaneo(codigo);
          },
        ),
      ),
    );
  }

  Future<void> _consultarPendientesManual() async {
    final carnet = _carnetCtrl.text.trim();
    if (carnet.isEmpty) return;
    
    setState(() => _cargando = true);
    try {
      final url = Uri.parse('$kBaseUrl/pendientes/$carnet');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> listaCruda = data is List ? data : (data['pendientes'] ?? []);
        
        // Filtro estricto: Solo se muestran los pendientes prestados el día de HOY
        final hoyStr = DateTime.now().toString().split(' ')[0]; // Formato YYYY-MM-DD
        final listaDeHoy = listaCruda.where((item) {
          final fechaRetiro = (item['fecha_retiro'] ?? '').toString();
          return fechaRetiro.startsWith(hoyStr);
        }).toList();

        setState(() {
          pendientes = listaDeHoy;
        });
      } else {
        setState(() => pendientes = []);
        mostrarNotificacionApp('Aviso', 'No se encontraron pendientes para este carnet', esError: true);
      }
    } catch (_) {
      setState(() => pendientes = []);
      mostrarNotificacionApp('Error', 'Error de conexión con el servidor', esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Escaneo y devolución automática restringida EXCLUSIVAMENTE a los préstamos de HOY
  Future<void> _procesarDevolucionMasivaPorEscaneo(String carnet) async {
    if (carnet.isEmpty) return;
    if (_modosSeleccionados.isEmpty) {
      mostrarNotificacionApp('Aviso', 'Selecciona al menos un modo de utensilio a devolver', esError: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      final url = Uri.parse('$kBaseUrl/pendientes/$carnet');
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        mostrarNotificacionApp('Error', 'Estudiante no encontrado o sin conexión', esError: true);
        return;
      }

      final data = jsonDecode(response.body);
      final List<dynamic> listaCruda = data is List ? data : (data['pendientes'] ?? []);

      if (listaCruda.isEmpty) {
        mostrarNotificacionApp('Aviso', 'El estudiante no tiene utensilios pendientes', esError: true);
        setState(() => pendientes = []);
        return;
      }

      // Filtrar únicamente los del día de HOY
      final hoyStr = DateTime.now().toString().split(' ')[0];
      final pendientesDeHoy = listaCruda.where((item) {
        final fechaRetiro = (item['fecha_retiro'] ?? '').toString();
        return fechaRetiro.startsWith(hoyStr);
      }).toList();

      if (pendientesDeHoy.isEmpty) {
        mostrarNotificacionApp('Aviso', 'El alumno no tiene préstamos pendientes del día de hoy (los anteriores no aplican)', esError: true);
        setState(() => pendientes = []);
        return;
      }

      // Filtrar por los modos seleccionados en pantalla
      final aDevolver = pendientesDeHoy.where((item) {
        final tipoItem = (item['tipo'] ?? '').toString().toLowerCase();
        return _modosSeleccionados.any((modo) => modo.toLowerCase() == tipoItem);
      }).toList();

      if (aDevolver.isEmpty) {
        mostrarNotificacionApp('Aviso', 'No hay pendientes de hoy para los modos seleccionados (${_modosSeleccionados.join(", ")})', esError: true);
        setState(() => pendientes = pendientesDeHoy);
        return;
      }

      // Procesar la devolución de cada uno de los elementos de hoy
      int devueltosExitosos = 0;
      for (var item in aDevolver) {
        final movimientoId = item['id'];
        if (movimientoId != null) {
          final devResp = await http.put(Uri.parse('$kBaseUrl/devolucion/$movimientoId'));
          if (devResp.statusCode == 200) {
            devueltosExitosos++;
          }
        }
      }

      if (devueltosExitosos > 0) {
        mostrarNotificacionApp('¡Devolución Exitosa!', 'Se devolvieron $devueltosExitosos utensilio(s) del día actual.');
        await mostrarNotificacionLocal(
          'Devolución Automática',
          'Se procesó la devolución de: ${_modosSeleccionados.join(", ")} para el carnet $carnet',
        );
      }

      // Actualizar vista restante
      _consultarPendientesManual();

    } catch (_) {
      mostrarNotificacionApp('Error', 'Error al procesar la devolución automática', esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Devolución por Modo Activo (Solo Hoy)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('1. Selecciona el tipo(s) a devolver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
            ),
            const SizedBox(height: 10),
            Row(
              children: _tiposDisponibles.map((tipo) {
                final seleccionado = _modosSeleccionados.contains(tipo);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (seleccionado) {
                          if (_modosSeleccionados.length > 1) {
                            _modosSeleccionados.remove(tipo);
                          }
                        } else {
                          _modosSeleccionados.add(tipo);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: seleccionado ? cs.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: seleccionado ? cs.primary : const Color(0xFFE2E8F0)),
                        boxShadow: seleccionado ? [BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : [],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_iconoTipo[tipo], color: seleccionado ? Colors.white : cs.primary, size: 24),
                          const SizedBox(height: 6),
                          Text(tipo, style: TextStyle(color: seleccionado ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Icon(
                            seleccionado ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            size: 14,
                            color: seleccionado ? Colors.white70 : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('2. Ingresa o escanea el carnet del alumno:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _carnetCtrl,
              decoration: InputDecoration(
                labelText: 'Carnet del Alumno',
                prefixIcon: const Icon(Icons.badge_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: cs.primary, size: 26),
                  onPressed: _escanearParaDevolver,
                  tooltip: 'Escanear para devolver automáticamente',
                ),
              ),
              onSubmitted: (_) => _consultarPendientesManual(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _consultarPendientesManual,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Consultar Hoy'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _escanearParaDevolver,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Escanear y Devolver'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Utensilios pendientes del día de hoy:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _carnetCtrl.text.trim().isEmpty
                      ? const Center(
                          child: Text('Selecciona el tipo de utensilio arriba y escanea o consulta el carnet',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                      : pendientes.isEmpty
                          ? const Center(
                              child: Text('No hay utensilios pendientes registrados para este alumno en el día de hoy',
                                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold)))
                          : ListView.builder(
                              itemCount: pendientes.length,
                              itemBuilder: (context, index) {
                                final item = pendientes[index];
                                final tipo = item['tipo'] ?? 'Utensilio';
                                final fechaRetiro = item['fecha_retiro'] ?? '';
                                final esModoActivo = _modosSeleccionados.any((m) => m.toLowerCase() == tipo.toLowerCase());

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  color: esModoActivo ? const Color(0xFFFFF5F5) : Colors.white,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    leading: CircleAvatar(
                                      backgroundColor: esModoActivo ? const Color(0xFFFFEBEE) : Colors.grey.shade100,
                                      child: Icon(_iconoTipo[tipo] ?? Icons.restaurant, color: esModoActivo ? const Color(0xFFC62828) : Colors.grey),
                                    ),
                                    title: Text(tipo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: esModoActivo ? Colors.black87 : Colors.grey)),
                                    subtitle: Text('Retirado hoy: $fechaRetiro', style: const TextStyle(fontSize: 12)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: esModoActivo ? const Color(0xFF16A34A).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        esModoActivo ? 'A devolver' : 'Fuera de modo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: esModoActivo ? const Color(0xFF16A34A) : Colors.grey,
                                        ),
                                      ),
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

  Future<void> _guardarEstudiante() async {
    if (_nombreCtrl.text.trim().isEmpty || _carnetCtrl.text.trim().isEmpty || _codigoCtrl.text.trim().isEmpty) {
      mostrarNotificacionApp('Aviso', 'Por favor completa todos los campos obligatorios', esError: true);
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
        mostrarNotificacionApp('Éxito', 'Estudiante registrado exitosamente');
        if (mounted) Navigator.pop(context);
      } else {
        mostrarNotificacionApp('Error', 'Error al registrar estudiante en el servidor', esError: true);
      }
    } catch (_) {
      mostrarNotificacionApp('Error de Red', 'No se pudo conectar con el servidor backend', esError: true);
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
          crossAxisAlignment: pw.CrossAxisAlignment.start,
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
        excel_pkg.TextCellValue("Pendientes"),
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
        mostrarNotificacionApp('Archivo Guardado', 'Excel almacenado en: informe_cocina_${_fechaController.text}.xlsx');
        OpenFile.open(path);
      }
    } catch (e) {
      if (!mounted) return;
      mostrarNotificacionApp('Error', 'Error al guardar archivo Excel: $e', esError: true);
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
                  subtitle: Text('1.1.0 (Notificaciones Top y Devolución del Día)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

        Future.delayed(const Duration(milliseconds: 400), () {
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
                    color: const Color(0xFF16A34A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
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
