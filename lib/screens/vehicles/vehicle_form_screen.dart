import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/vehicle_repository.dart';
import '../../models/vehicle.dart';

/// Screen for creating a new vehicle or editing an existing one.
class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit;

  const VehicleFormScreen({
    super.key,
    this.vehicleToEdit,
  });

  bool get isEditing => vehicleToEdit != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _vinController;
  late final TextEditingController _mileageController;
  late final TextEditingController _driverController;

  late VehicleType _selectedType;
  late FuelType _selectedFuelType;
  late VehicleStatus _selectedStatus;
  DateTime? _selectedServiceDate;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;

    _plateController = TextEditingController(text: v?.plateNumber ?? '');
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(
      text: v?.year.toString() ?? DateTime.now().year.toString(),
    );
    _vinController = TextEditingController(text: v?.vin ?? '');
    _mileageController = TextEditingController(
      text: v?.mileage.toString() ?? '0',
    );
    _driverController = TextEditingController(text: v?.assignedDriver ?? '');

    _selectedType = v?.type ?? VehicleType.sedan;
    _selectedFuelType = v?.fuelType ?? FuelType.gasoline;
    _selectedStatus = v?.status ?? VehicleStatus.active;
    _selectedServiceDate = v?.lastServiceDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedServiceDate = picked);
    }
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final year = int.parse(_yearController.text.trim());
    final mileage = int.parse(_mileageController.text.trim());
    final driverText = _driverController.text.trim();

    final vehicle = Vehicle(
      id: widget.vehicleToEdit?.id ??
          'veh-${DateTime.now().millisecondsSinceEpoch % 10000}',
      plateNumber: _plateController.text.trim().toUpperCase(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      vin: _vinController.text.trim().toUpperCase(),
      type: _selectedType,
      fuelType: _selectedFuelType,
      status: _selectedStatus,
      mileage: mileage,
      assignedDriver: driverText.isNotEmpty ? driverText : null,
      lastServiceDate: _selectedServiceDate,
    );

    if (widget.isEditing) {
      VehicleRepository.instance.update(vehicle);
    } else {
      VehicleRepository.instance.add(vehicle);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Vehicle ${vehicle.plateNumber} updated successfully'
              : 'New vehicle ${vehicle.plateNumber} added to fleet',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.isEditing
        ? 'Edit Vehicle (${widget.vehicleToEdit!.plateNumber})'
        : 'Register New Fleet Vehicle';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to vehicle list',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    theme,
                    icon: Icons.directions_car_outlined,
                    title: 'Vehicle Identification',
                    subtitle: 'Core manufacturing and registration identity',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _plateController,
                                  decoration: const InputDecoration(
                                    labelText: 'License Plate Number *',
                                    hintText: 'e.g. STK-4081',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Plate number is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _vinController,
                                  decoration: const InputDecoration(
                                    labelText: 'VIN (Vehicle Identification No.) *',
                                    hintText: '17-digit alphanumeric code',
                                    prefixIcon: Icon(Icons.qr_code_2),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'VIN is required';
                                    }
                                    if (val.trim().length < 8) {
                                      return 'VIN is too short';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _makeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Make *',
                                    hintText: 'e.g. Toyota, Ford, Volvo',
                                    prefixIcon: Icon(Icons.business_outlined),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty
                                      ? 'Make is required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _modelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Model *',
                                    hintText: 'e.g. Camry, F-150',
                                    prefixIcon: Icon(Icons.label_outline),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty
                                      ? 'Model is required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(
                                    labelText: 'Year *',
                                    hintText: '2024',
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final y = int.tryParse(val);
                                    if (y == null || y < 1980 || y > DateTime.now().year + 1) {
                                      return 'Invalid year';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    theme,
                    icon: Icons.tune,
                    title: 'Specifications & Classification',
                    subtitle: 'Category, powertrain, and current odometer reading',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<VehicleType>(
                                  initialValue: _selectedType,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Vehicle Body Type',
                                    prefixIcon: Icon(Icons.category_outlined),
                                  ),
                                  items: VehicleType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(type.icon, size: 18),
                                          const SizedBox(width: 8),
                                          Text(type.displayName),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedType = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<FuelType>(
                                  initialValue: _selectedFuelType,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Powertrain / Fuel Type',
                                    prefixIcon: Icon(Icons.local_gas_station_outlined),
                                  ),
                                  items: FuelType.values.map((fuel) {
                                    return DropdownMenuItem(
                                      value: fuel,
                                      child: Text(fuel.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedFuelType = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mileageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Current Mileage (km) *',
                              hintText: 'e.g. 15000',
                              prefixIcon: Icon(Icons.speed_outlined),
                              suffixText: 'km',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Mileage is required';
                              }
                              final m = int.tryParse(val);
                              if (m == null || m < 0) {
                                return 'Enter valid positive mileage';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    theme,
                    icon: Icons.assignment_ind_outlined,
                    title: 'Fleet Operations & Assignment',
                    subtitle: 'Current operational state and assigned driver',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<VehicleStatus>(
                                  initialValue: _selectedStatus,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Operational Status',
                                    prefixIcon: Icon(Icons.traffic_outlined),
                                  ),
                                  items: VehicleStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: status.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(status.displayName),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedStatus = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: _pickServiceDate,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Last Service Date',
                                      prefixIcon: Icon(Icons.calendar_today_outlined),
                                      suffixIcon: Icon(Icons.arrow_drop_down),
                                    ),
                                    child: Text(
                                      _selectedServiceDate != null
                                          ? '${_selectedServiceDate!.year}-${_selectedServiceDate!.month.toString().padLeft(2, '0')}-${_selectedServiceDate!.day.toString().padLeft(2, '0')}'
                                          : 'Not recorded',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _driverController,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Driver (Optional)',
                              hintText: 'e.g. Marcus Vance (leave blank if unassigned)',
                              prefixIcon: Icon(Icons.person_pin_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _saveVehicle,
                        icon: const Icon(Icons.check),
                        label: Text(widget.isEditing ? 'Save Changes' : 'Register Vehicle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
