import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/validators/validators.dart';
import '../../../data/models/property.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/image_source_sheet.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/property_image.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../property/bloc/property_bloc.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  static const _placeholderImageUrl =
      'https://picsum.photos/seed/newprop/800/600';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedType;
  String? _selectedCity;
  int? _selectedBedrooms;
  String? _selectedStatus;
  String? _localImagePath;
  String? _existingImageUrl;
  Property? _existingProperty;
  bool _loadingProperty = false;
  String? _propertyError;
  bool _imageTouched = false;

  bool get _isEditMode => widget.propertyId != null;

  bool get _hasImage {
    final hasLocal =
        _localImagePath != null && _localImagePath!.trim().isNotEmpty;
    final hasExisting =
        _existingImageUrl != null && _existingImageUrl!.trim().isNotEmpty;
    return hasLocal || hasExisting;
  }

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const PropertyMutationStatusCleared());
    if (_isEditMode) {
      _loadingProperty = true;
      _loadProperty();
    }
  }

  Future<void> _loadProperty() async {
    try {
      final property = await context
          .read<PropertyRepository>()
          .getPropertyById(widget.propertyId!);
      if (!mounted) return;
      if (property == null) {
        setState(() {
          _loadingProperty = false;
          _propertyError = 'Property not found.';
        });
        return;
      }
      setState(() {
        _existingProperty = property;
        _nameController.text = property.name;
        _locationController.text = property.location;
        _priceController.text = property.price.toStringAsFixed(0);
        _areaController.text = property.area.toStringAsFixed(0);
        _descriptionController.text = property.description;
        _selectedType = property.type;
        _selectedCity = property.city;
        _selectedBedrooms = property.bedrooms;
        _selectedStatus = property.status;
        _existingImageUrl = property.imageUrl;
        _localImagePath = property.localImagePath;
        _loadingProperty = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProperty = false;
        _propertyError = 'Something went wrong.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showImageSourceSheet(context);
    if (source == null || !mounted) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _localImagePath = picked.path;
        _imageTouched = true;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Could not pick image. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  void _removeImage() {
    setState(() {
      _localImagePath = null;
      _existingImageUrl = null;
      _imageTouched = true;
    });
  }

  String? _validateImage() {
    if (!_hasImage) {
      return 'Property image is required';
    }
    return null;
  }

  void _submit() {
    setState(() => _imageTouched = true);
    if (!_formKey.currentState!.validate()) return;
    if (_validateImage() != null) {
      setState(() {});
      return;
    }

    final user = context.read<AuthBloc>().state.user;
    if (user == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('You must be logged in to save a property.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final area = double.parse(_areaController.text.trim());
    final imageUrl = _isEditMode && _existingImageUrl != null
        ? _existingImageUrl!
        : _placeholderImageUrl;

    final property = Property(
      id: _existingProperty?.id ?? '',
      name: _nameController.text.trim(),
      type: _selectedType!,
      location: _locationController.text.trim(),
      city: _selectedCity!,
      price: price,
      area: area,
      bedrooms: _selectedBedrooms!,
      status: _selectedStatus!,
      description: _descriptionController.text.trim(),
      imageUrl: imageUrl,
      ownerId: user.id,
      ownerName: user.name,
      localImagePath: _localImagePath,
    );

    final bloc = context.read<PropertyBloc>();
    if (_isEditMode) {
      bloc.add(
        PropertyUpdateRequested(
          property: property,
          requesterOwnerId: user.id,
        ),
      );
    } else {
      bloc.add(PropertyAddRequested(property));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Property' : 'Add Property'),
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listenWhen: (previous, current) =>
            previous.mutationStatus != current.mutationStatus,
        listener: (context, state) {
          if (state.mutationStatus == PropertyMutationStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.mutationMessage ??
                        (_isEditMode
                            ? 'Property updated successfully!'
                            : 'Property added successfully!'),
                  ),
                ),
              );
            context.pop(true);
          } else if (state.mutationStatus == PropertyMutationStatus.failure &&
              state.mutationMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.mutationMessage!),
                  backgroundColor: colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (_loadingProperty) {
            return const LoadingView(message: 'Loading property...');
          }
          if (_propertyError != null) {
            return ErrorState(message: _propertyError!, onRetry: _loadProperty);
          }

          final isDisabled = state.isMutating;

          return AbsorbPointer(
            absorbing: isDisabled,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isEditMode
                          ? 'Update property details'
                          : 'List a new property',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add a photo and fill in the property information.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ImageSection(
                      hasImage: _hasImage,
                      localImagePath: _localImagePath,
                      imageUrl: _existingImageUrl ?? _placeholderImageUrl,
                      imageError: _imageTouched ? _validateImage() : null,
                      onTap: isDisabled ? null : _pickImage,
                      onChange: isDisabled ? null : _pickImage,
                      onRemove: isDisabled || !_hasImage ? null : _removeImage,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _nameController,
                      label: 'Property Name',
                      hint: 'e.g. Sunrise Apartments',
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.home_work_outlined),
                      validator: Validators.propertyName,
                      enabled: !isDisabled,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Property Type',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: AppConstants.propertyTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: isDisabled
                          ? null
                          : (value) => setState(() => _selectedType = value),
                      validator: (value) => Validators.dropdownRequired(
                        value,
                        fieldName: 'Property type',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      items: AppConstants.locations
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                      onChanged: isDisabled
                          ? null
                          : (value) => setState(() => _selectedCity = value),
                      validator: (value) => Validators.dropdownRequired(
                        value,
                        fieldName: 'City',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'Area, landmark, or address',
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.place_outlined),
                      validator: Validators.location,
                      enabled: !isDisabled,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _priceController,
                      label: 'Price (₹)',
                      hint: 'e.g. 8500000',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.currency_rupee),
                      validator: (value) => Validators.positiveNumber(
                        value,
                        fieldName: 'Price',
                      ),
                      enabled: !isDisabled,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _areaController,
                      label: 'Area (sq.ft)',
                      hint: 'e.g. 1200',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.square_foot_outlined),
                      validator: (value) => Validators.positiveNumber(
                        value,
                        fieldName: 'Area',
                      ),
                      enabled: !isDisabled,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      // ignore: deprecated_member_use
                      value: _selectedBedrooms,
                      decoration: const InputDecoration(
                        labelText: 'Bedrooms',
                        prefixIcon: Icon(Icons.bed_outlined),
                      ),
                      items: AppConstants.bedroomOptions
                          .map(
                            (count) => DropdownMenuItem(
                              value: count,
                              child: Text('$count BHK'),
                            ),
                          )
                          .toList(),
                      onChanged: isDisabled
                          ? null
                          : (value) =>
                              setState(() => _selectedBedrooms = value),
                      validator: (value) {
                        if (value == null) {
                          return 'Bedrooms is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: AppConstants.statuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: isDisabled
                          ? null
                          : (value) => setState(() => _selectedStatus = value),
                      validator: (value) => Validators.dropdownRequired(
                        value,
                        fieldName: 'Status',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe the property, amenities, and highlights',
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      prefixIcon: const Icon(Icons.notes_outlined),
                      validator: Validators.description,
                      enabled: !isDisabled,
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: _isEditMode ? 'Save Changes' : 'Add Property',
                      isLoading: isDisabled,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.hasImage,
    required this.localImagePath,
    required this.imageUrl,
    required this.imageError,
    required this.onTap,
    required this.onChange,
    required this.onRemove,
  });

  final bool hasImage;
  final String? localImagePath;
  final String imageUrl;
  final String? imageError;
  final VoidCallback? onTap;
  final VoidCallback? onChange;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Property Photo',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: imageError != null
                      ? colorScheme.error
                      : Colors.grey.shade300,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: hasImage
                    ? _buildPreview(context)
                    : _buildPlaceholder(context),
              ),
            ),
          ),
        ),
        if (imageError != null) ...[
          const SizedBox(height: 8),
          Text(
            imageError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
        if (hasImage) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChange,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Change'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final localPath = localImagePath?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return PropertyImage(
            imageUrl: imageUrl,
            height: 200,
          );
        },
      );
    }
    return PropertyImage(
      imageUrl: imageUrl,
      height: 200,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      width: double.infinity,
      color: colorScheme.primary.withValues(alpha: 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 40,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add a photo',
            style: TextStyle(
              color: colorScheme.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Camera or gallery',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
