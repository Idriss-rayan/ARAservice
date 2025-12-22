import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModeConfectionPage extends StatefulWidget {
  final List<String> subcategories;

  const ModeConfectionPage({super.key, required this.subcategories});

  @override
  State<ModeConfectionPage> createState() => _ModeConfectionPageState();
}

class _ModeConfectionPageState extends State<ModeConfectionPage> {
  final Map<String, List<Map<String, dynamic>>> _services = {
    'Confection sur mesure': [
      {'name': 'Robe de soirée', 'price': 199.99, 'duration': '15 jours'},
      {'name': 'Costume 3 pièces', 'price': 299.99, 'duration': '10 jours'},
      {'name': 'Habil traditionnel', 'price': 149.99, 'duration': '7 jours'},
    ],
    'Retouches': [
      {'name': 'Ourlet pantalon', 'price': 15.99, 'duration': '24h'},
      {'name': 'Fermeture éclair', 'price': 12.99, 'duration': '48h'},
      {'name': 'Reprise vêtement', 'price': 25.99, 'duration': '72h'},
    ],
    'Prêt-à-porter': [
      {'name': 'Collection été', 'from': 49.99, 'to': 89.99},
      {'name': 'Collection hiver', 'from': 79.99, 'to': 129.99},
      {'name': 'Collection orientale', 'from': 99.99, 'to': 199.99},
    ],
  };

  int _selectedCategoryIndex = 0;
  String? _selectedService;
  final Map<String, dynamic> _appointmentDetails = {};

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.subcategories[_selectedCategoryIndex];
    final services = _services[currentCategory] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF004D40), Color(0xFF00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Artisan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mode & Confection',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Couture, retouches et création sur mesure',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Onglets de catégories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.subcategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategoryIndex == index,
                      selectedColor: const Color(0xFF004D40),
                      labelStyle: TextStyle(
                        color: _selectedCategoryIndex == index
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                          _selectedService = null;
                          _appointmentDetails.clear();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Services
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected = _selectedService == service['name'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected
                        ? const Color(0xFF004D40).withOpacity(0.1)
                        : Colors.white,
                    elevation: isSelected ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF004D40)
                            : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icône
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF004D40).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _selectedCategoryIndex == 0
                                  ? Icons.design_services_rounded
                                  : _selectedCategoryIndex == 1
                                  ? Icons.content_cut_rounded
                                  : Icons.storefront_rounded,
                              color: const Color(0xFF004D40),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Informations
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF004D40),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                if (service['price'] != null)
                                  Text(
                                    '${service['price']}€',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                                  )
                                else if (service['from'] != null)
                                  Text(
                                    '${service['from']}€ - ${service['to']}€',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),

                                if (service['duration'] != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_rounded,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        service['duration'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // Bouton sélection
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedService = service['name'];
                              });
                              _showServiceDetails(service);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004D40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Choisir',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms);
                },
              ),
            ),
          ),

          // Bouton de rendez-vous
          if (_selectedService != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service sélectionné',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _selectedService!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF004D40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAppointmentForm(),
                    icon: const Icon(Icons.calendar_today_rounded, size: 20),
                    label: const Text('Prendre RDV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  if (service['price'] != null)
                    Text(
                      '${service['price']}€',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF004D40),
                      ),
                    ),
                ],
              ),

              if (service['from'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'À partir de ${service['from']}€',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              if (service['duration'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded, color: Color(0xFF004D40)),
                      const SizedBox(width: 8),
                      Text('Délai: ${service['duration']}'),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _getServiceDescription(service['name']),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF004D40)),
                      ),
                      child: const Text('Fermer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAppointmentForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                      ),
                      child: const Text('Réserver'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getServiceDescription(String serviceName) {
    final descriptions = {
      'Robe de soirée':
          'Création sur mesure avec tissus de luxe et finitions artisanales.',
      'Costume 3 pièces': 'Confection artisanale avec ajustements parfaits.',
      'Habil traditionnel':
          'Réalisation de tenues traditionnelles avec broderies artisanales.',
      'Ourlet pantalon': 'Ourlet professionnel avec finition invisible.',
      'Fermeture éclair':
          'Remplacement de fermeture éclair sur tous types de vêtements.',
      'Reprise vêtement': 'Réparation et reprise des vêtements endommagés.',
      'Collection été': 'Vêtements légers et élégants pour la saison estivale.',
      'Collection hiver': 'Tenues chaudes et stylées pour l\'hiver.',
      'Collection orientale': 'Tenues traditionnelles modernisées.',
    };

    return descriptions[serviceName] ?? 'Service de couture professionnel.';
  }

  void _showAppointmentForm() {
    final currentService = _services.values
        .expand((list) => list)
        .firstWhere((service) => service['name'] == _selectedService);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rendez-vous pour ${_selectedService}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF004D40),
                    ),
                    title: const Text('Date'),
                    subtitle: Text(
                      _appointmentDetails['date'] ?? 'Choisir une date',
                    ),
                    onTap: () => _selectDate(context, setState),
                  ),

                  // Heure
                  ListTile(
                    leading: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF004D40),
                    ),
                    title: const Text('Heure'),
                    subtitle: Text(
                      _appointmentDetails['time'] ?? 'Choisir une heure',
                    ),
                    onTap: () => _selectTime(context, setState),
                  ),

                  // Détails
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Détails supplémentaires',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_rounded),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _appointmentDetails['details'] = value;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Résumé
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D40).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Service:'),
                            Text(_selectedService!),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Prix:'),
                            if (currentService['price'] != null)
                              Text('${currentService['price']}€')
                            else if (currentService['from'] != null)
                              Text('À partir de ${currentService['from']}€'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF004D40)),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_appointmentDetails['date'] != null &&
                                _appointmentDetails['time'] != null) {
                              _confirmAppointment();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Veuillez sélectionner une date et une heure',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D40),
                          ),
                          child: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, Function setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      setState(() {
        _appointmentDetails['date'] =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context, Function setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _appointmentDetails['time'] = picked.format(context);
      });
    }
  }

  void _confirmAppointment() {
    Navigator.pop(context); // Fermer le formulaire

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'RDV confirmé !',
            style: TextStyle(color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              Text('Service: $_selectedService'),
              Text('Date: ${_appointmentDetails['date']}'),
              Text('Heure: ${_appointmentDetails['time']}'),
              const SizedBox(height: 16),
              const Text(
                'Un email de confirmation vous a été envoyé.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedService = null;
                  _appointmentDetails.clear();
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
