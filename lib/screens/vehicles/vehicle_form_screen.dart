import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/mock_data.dart';
import '../../data/vehicle_repository.dart';
import '../../models/vehicle.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/confirmation_dialog.dart';

/// Reusable form screen for both Registering a new vehicle and Editing an existing vehicle.
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

  late final TextEditingController _numberController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;

  final _numberFocusNode = FocusNode();
  final _brandFocusNode = FocusNode();
  final _modelFocusNode = FocusNode();

  String? _selectedCompany;
  String? _selectedType;
  VehicleStatus _selectedStatus = VehicleStatus.active;

  bool _isSaving = false;
  String? _duplicateNumberError;

  // Track initial values to determine whether form is dirty
  late final String _initialNumber;
  late final String? _initialCompany;
  late final String? _initialType;
  late final String _initialBrand;
  late final String _initialModel;
  late final VehicleStatus _initialStatus;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;

    _initialNumber = v?.vehicleNumber ?? '';
    _initialCompany = v?.company ?? mockCompanies.first;
    _initialType = v?.type ?? mockVehicleTypes.first;
    _initialBrand = v?.brand ?? '';
    _initialModel = v?.model ?? '';
    _initialStatus = v?.status ?? VehicleStatus.active;

    _numberController = TextEditingController(text: _initialNumber);
    _selectedCompany = _initialCompany;
    _selectedType = _initialType;
    _brandController = TextEditingController(text: _initialBrand);
    _modelController = TextEditingController(text: _initialModel);
    _selectedStatus = _initialStatus;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _numberFocusNode.dispose();
    _brandFocusNode.dispose();
    _modelFocusNode.dispose();
    super.dispose();
  }

  bool get _isDirty {
    return _numberController.text.trim() != _initialNumber.trim() ||
        _selectedCompany != _initialCompany ||
        _selectedType != _initialType ||
        _brandController.text.trim() != _initialBrand.trim() ||
        _modelController.text.trim() != _initialModel.trim() ||
        _selectedStatus != _initialStatus;
  }

  Future<void> _handleCancel() async {
    if (_isDirty) {
      final discard = await ConfirmationDialog.showDiscard(context);
      if (!discard) return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() {
      _duplicateNumberError = null;
    });

    final trimmedNumber = _numberController.text.trim();

    // Check duplicate vehicle number
    final repo = VehicleRepository.instance;
    final isDuplicate = repo.isVehicleNumberDuplicate(
      trimmedNumber,
      excludeId: widget.vehicleToEdit?.id,
    );

    if (isDuplicate) {
      setState(() {
        _duplicateNumberError = 'Vehicle Number "$trimmedNumber" is already registered. Vehicle numbers must be unique.';
      });
      _numberFocusNode.requestFocus();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final vehicle = Vehicle(
      id: widget.vehicleToEdit?.id ?? 'veh-${DateTime.now().millisecondsSinceEpoch % 100000}',
      vehicleNumber: trimmedNumber,
      company: _selectedCompany ?? mockCompanies.first,
      type: _selectedType ?? mockVehicleTypes.first,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      status: _selectedStatus,
    );

    if (widget.isEditing) {
      repo.update(vehicle);
    } else {
      repo.add(vehicle);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Vehicle ${vehicle.vehicleNumber} successfully updated.'
              : 'Vehicle ${vehicle.vehicleNumber} successfully registered.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Vehicle' : 'Register Vehicle';
    final isDesktop = Responsive.isDesktop(context);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final discard = await ConfirmationDialog.showDiscard(context);
        if (discard && mounted) {
          nav.pop();
        }
      },
      child: AppShell(
        title: title,
        showBackButton: true,
        onBack: _handleCancel,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFormHeader(title),
                    const SizedBox(height: AppTheme.space24),
                    _buildIdentityCard(isDesktop),
                    const SizedBox(height: AppTheme.space20),
                    _buildDetailsCard(isDesktop),
                    const SizedBox(height: AppTheme.space20),
                    _buildStatusCard(),
                    const SizedBox(height: AppTheme.space24),
                    _buildFormActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: _handleCancel,
              child: const Text(
                'Vehicles',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text('/', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          widget.isEditing
              ? 'Update specifications and status for vehicle ${widget.vehicleToEdit!.vehicleNumber}.'
              : 'Add a new vehicle record to the Stark Group fleet registry.',
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildIdentityCard(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Vehicle Identity', 'Registration number and owning subsidiary'),
            const SizedBox(height: AppTheme.space16),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildVehicleNumberField()),
                  const SizedBox(width: AppTheme.space16),
                  Expanded(child: _buildCompanyField()),
                ],
              )
            else ...[
              _buildVehicleNumberField(),
              const SizedBox(height: AppTheme.space16),
              _buildCompanyField(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('2. Vehicle Details', 'Category, manufacturer brand, and model designation'),
            const SizedBox(height: AppTheme.space16),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTypeField()),
                  const SizedBox(width: AppTheme.space16),
                  Expanded(child: _buildBrandField()),
                  const SizedBox(width: AppTheme.space16),
                  Expanded(child: _buildModelField()),
                ],
              )
            else ...[
              _buildTypeField(),
              const SizedBox(height: AppTheme.space16),
              _buildBrandField(),
              const SizedBox(height: AppTheme.space16),
              _buildModelField(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('3. Operational State', 'Current deployment status within the fleet'),
            const SizedBox(height: AppTheme.space16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _buildStatusField(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildVehicleNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Number *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: AppTheme.space4),
        TextFormField(
          controller: _numberController,
          focusNode: _numberFocusNode,
          decoration: InputDecoration(
            hintText: 'e.g. STK-1001',
            errorText: _duplicateNumberError,
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Vehicle Number is required.';
            }
            return null;
          },
          onChanged: (_) {
            if (_duplicateNumberError != null) {
              setState(() => _duplicateNumberError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCompanyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: AppTheme.space4),
        DropdownButtonFormField<String>(
          initialValue: _selectedCompany,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: mockCompanies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCompany = val);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Company is required.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: AppTheme.space4),
        DropdownButtonFormField<String>(
          initialValue: _selectedType,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: mockVehicleTypes.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Text(t, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedType = val);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vehicle Type is required.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBrandField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brand *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: AppTheme.space4),
        TextFormField(
          controller: _brandController,
          focusNode: _brandFocusNode,
          decoration: const InputDecoration(
            hintText: 'e.g. Toyota, Ford, Volvo',
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Brand is required.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Model *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: AppTheme.space4),
        TextFormField(
          controller: _modelController,
          focusNode: _modelFocusNode,
          decoration: const InputDecoration(
            hintText: 'e.g. Camry, F-150',
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Model is required.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        const SizedBox(height: AppTheme.space4),
        DropdownButtonFormField<VehicleStatus>(
          initialValue: _selectedStatus,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: VehicleStatus.values.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: s.dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(s.label, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedStatus = val);
          },
        ),
      ],
    );
  }

  Widget _buildFormActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _handleCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppTheme.space12),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(widget.isEditing ? 'Save changes' : 'Register vehicle'),
        ),
      ],
    );
  }
}
