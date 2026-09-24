import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

// ⚠️ Cambia esta IP por la de tu PC (ipconfig -> IPv4) o emulador (10.0.2.2)
const String kBaseUrl = 'http://10.134.220.181:3000';

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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro
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
// PÁGINA PRINCIPAL CON NAVEGACIÓN INFERIOR (4 PESTAÑAS)
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
    const InformesPage(),
    const ConfiguracionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF212121), // Gris oscuro / casi negro
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
          selectedItemColor: const Color(0xFFEF5350), // Rojo claro seleccionado
          unselectedItemColor: Colors.grey,
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
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Informes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. PÁGINA DE INICIO (Con Menú Lateral / Drawer)
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
                  Text('Menú de Gestión',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('INFRAMEN · Control de Vajilla',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return_rounded, color: Color(0xFFB71C1C)),
              title: const Text('Devolución de Utensilios', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Escanear carnet y devolver'),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
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
                  BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu, size: 36, color: Colors.white),
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
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('Panel de Acceso Rápido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    icon: Icons.warning_amber_rounded,
                    titulo: 'Ver Pendientes',
                    color: Colors.grey.shade800,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
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

  void _msg(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade800 : Colors.grey.shade800,
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
        content: Text('El código "$codigo" no se encuentra en la base de datos. ¿Deseas registrar a este estudiante ahora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
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
// 3. PÁGINA DE UTENSILIOS PENDIENTES Y DEVOLUCIÓN (Búsqueda por Carnet con Desglose)
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
  String _categoriaSeleccionada = 'Plato'; // Categoría filtrada al buscar al alumno

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
    if (movimientoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: El ID del movimiento es nulo'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final url = Uri.parse('$kBaseUrl/devolucion/$movimientoId');
      print('Enviando PUT a: $url');
      
      final response = await http.put(url);
      
      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Devolución de $tipo registrada con éxito!'), backgroundColor: Colors.green.shade800),
        );
        obtenerPendientes(); // Recarga los pendientes restantes del alumno
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor (${response.statusCode}): No se pudo registrar'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Excepción en devolución: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al intentar devolver'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Filtrar los pendientes del alumno según la categoría seleccionada
    final pendientesFiltrados = pendientes.where((item) {
      final tipo = item['tipo'] ?? '';
      return tipo.toLowerCase() == _categoriaSeleccionada.toLowerCase();
    }).toList();

    // Contadores específicos de los pendientes de este estudiante
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
            // Campo de texto para ingresar o escanear el carnet
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

            // Mostrar el desglose por categoría y la lista solo si ya se buscó un carnet con datos
            if (_carnetCtrl.text.trim().isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Filtrar por categoría del alumno:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              child: Text('Utensilios pendientes:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _carnetCtrl.text.trim().isEmpty
                      ? const Center(
                          child: Text('Escanea o ingresa un carnet para ver y devolver los utensilios pendientes del alumno',
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
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
// 4. PÁGINA PARA REGISTRAR NUEVO ESTUDIANTE
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: error ? Colors.red.shade800 : Colors.grey.shade800),
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
                  decoration: const InputDecoration(labelText: 'Grado / Seccion (Ej: 2° Software)', prefixIcon: Icon(Icons.school_outlined)),
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
// 5. PÁGINA DE INFORMES DIARIOS
// ==========================================
class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
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
    _obtenerInforme();
  }

  Future<void> _obtenerInforme() async {
    setState(() => _cargando = true);
    try {
      final resp = await http.get(Uri.parse('$kBaseUrl/informe'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() => _informe = data['informe'] ?? data);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
      );
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
        title: const Text('Informe Diario', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _obtenerInforme),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Resumen del día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(
                  backgroundColor: cs.primary.withOpacity(0.1),
                  label: Text('Hoy', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _informe.isEmpty
                      ? const Center(child: Text('No hay registros para este día', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _informe.length,
                          itemBuilder: (context, index) {
                            final item = _informe[index];
                            final tipo = item['tipo'] ?? 'Utensilio';
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: cs.primary.withOpacity(0.1),
                                  child: Icon(_iconoTipo[tipo] ?? Icons.restaurant, color: cs.primary),
                                ),
                                title: Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('Entregados: ${item['entregados'] ?? 0}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Pend.: ${item['pendientes'] ?? 0}', style: const TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                                  ],
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
// 6. CONFIGURACIÓN
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
// PANTALLA DE ESCANEO DE CÁMARA (Con Animación y Marcos Rojos)
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
        backgroundColor: const Color(0xFF212121),
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
            top: BorderSide(color: Color(0xFFEF5350), width: 4), // Rojo brillante institucional
            left: BorderSide(color: Color(0xFFEF5350), width: 4),
          ),
        ),
      ),
    );
  }
}
