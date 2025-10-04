import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AforoCozumelApp());
}

class AforoCozumelApp extends StatelessWidget {
  const AforoCozumelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Aforo Ferry Cozumel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaAforoCozumel(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PantallaAforoCozumel extends StatefulWidget {
  const PantallaAforoCozumel({super.key});

  @override
  State<PantallaAforoCozumel> createState() => _PantallaAforoCozumelState();
}

class _PantallaAforoCozumelState extends State<PantallaAforoCozumel> {
  // Variables principales
  int capacidadMaxima = 800;
  int aforoActual = 0;
  bool capacidadEditable = true; // para permitir solo un cambio en la capacidad
  List<String> historial = [];

  // Controlador para el campo de texto
  TextEditingController capacidadController = TextEditingController();
  FocusNode capacidadFocus = FocusNode();

  // Cambiar el aforo (sumar o restar personas)
  void cambiarAforo(int cantidad) {
    int nuevoAforo = aforoActual + cantidad;

    // Validar límites
    if (nuevoAforo < 0) {
      mostrarMensaje('El aforo no puede ser negativo');
      return;
    }
    if (nuevoAforo > capacidadMaxima) {
      mostrarMensaje('¡Capacidad máxima alcanzada!');
      return;
    }

    // Actualizar aforo y agregar al historial
    setState(() {
      aforoActual = nuevoAforo;
      String tipo = cantidad > 0 ? "Entraron" : "Salieron";
      historial.insert(0, "$tipo ${cantidad.abs()} → Aforo: $aforoActual/$capacidadMaxima");
    });
  }

  // Aplicar nueva capacidad
 void aplicarCapacidad() {
  // Validar si ya se ha editado
  if (!capacidadEditable) {
    mostrarMensaje('La capacidad solo puede configurarse una vez. Reinicia el sistema para cambiarla.');
    return;
  }

  int? nueva = int.tryParse(capacidadController.text);
  
  if (nueva == null || nueva <= 0) {
    mostrarMensaje('Ingresa una capacidad válida');
    return;
  }

  if (aforoActual > nueva) {
    mostrarMensaje('El aforo actual supera la nueva capacidad');
    return;
  }

  setState(() {
    capacidadMaxima = nueva;
    capacidadEditable = false; // ya no se puede cambiar
    historial.insert(0, "Capacidad actualizada a: $capacidadMaxima");
  });
  
  capacidadController.clear();
  capacidadFocus.unfocus();
} 

  // Reiniciar todo
  void reiniciar() {
  setState(() {
    aforoActual = 0;
    capacidadEditable = true; // se puede volver a editar
    historial.clear();
    historial.add("Sistema reiniciado");
  });
}


  // Calcular porcentaje
  double calcularPorcentaje() {
    if (capacidadMaxima == 0) return 0;
    return aforoActual / capacidadMaxima;
  }

  // Obtener color del semáforo
  Color obtenerColor() {
    double porcentaje = calcularPorcentaje();
    if (porcentaje >= 0.90) return Colors.red;
    if (porcentaje >= 0.60) return Colors.yellow;
    return Colors.green;
  }

  // Mostrar mensaje
  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    double porcentaje = calcularPorcentaje();
    Color colorActual = obtenerColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Aforo – Ferry Cozumel'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 129),
        foregroundColor: const Color.fromARGB(255, 223, 224, 159),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen ilustrativa
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              //Se realiza la carga de la imagen desde una URL usando Image.network
              child: Image.network(
                'https://imgs.search.brave.com/fshpzay1teMZtIbtB81VQ_TLEuUeW9z21M-_fuO4CC0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9haXJw/b3J0LWNvenVtZWwu/Y29tL3dwLWNvbnRl/bnQvdXBsb2Fkcy8y/MDIzLzA0L0NvenVt/ZWwtRmVycnktR3Vp/ZGUuanBn',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de capacidad
            Wrap(
              children: [
                Expanded(
                  child: TextField(
                    controller: capacidadController,
                    focusNode: capacidadFocus,
                    decoration: InputDecoration(
                      labelText: 'Capacidad Máxima',
                      hintText: 'Ej: $capacidadMaxima',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: aplicarCapacidad,
                  child: const Text('Aplicar'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Panel de estado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aforo: $aforoActual / $capacidadMaxima',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: porcentaje,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(colorActual),
                        ),
                        const SizedBox(height: 4),
                        Text('${(porcentaje * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Semáforo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(221, 3, 3, 78),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        crearLuz(Colors.red, porcentaje >= 0.90),
                        const SizedBox(height: 4),
                        crearLuz(Colors.yellow, porcentaje >= 0.60 && porcentaje < 0.90),
                        const SizedBox(height: 4),
                        crearLuz(Colors.green, porcentaje < 0.60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botones de control
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                crearBoton(1, const Color.fromARGB(255, 51, 209, 56)),
                crearBoton(2, const Color.fromARGB(255, 37, 158, 41)),
                crearBoton(5, const Color.fromARGB(255, 20, 115, 23)),
                crearBoton(-1, const Color.fromARGB(255, 220, 137, 12)),
                crearBoton(-5, const Color.fromARGB(255, 194, 118, 3)),
                ElevatedButton.icon(
                  onPressed: reiniciar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reiniciar Sistema'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 149, 12, 12),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Historial
            const Text(
              'Historial de cambios realizados:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 157, 189, 237)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(historial[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Crear luz del semáforo
  Widget crearLuz(Color color, bool encendida) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: encendida ? color : const Color.fromARGB(255, 175, 175, 175),
        border: Border.all(color: const Color.fromARGB(57, 196, 194, 194)),
      ),
    );
  }

  // Crear botón de control
  Widget crearBoton(int valor, Color color) {
    return ElevatedButton(
      onPressed: () => cambiarAforo(valor),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(valor > 0 ? '+$valor' : '$valor'),
    );
  }
}