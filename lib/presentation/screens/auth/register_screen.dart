import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final String initialRole;

  const RegisterScreen({super.key, this.initialRole = 'patient'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _specializationController = TextEditingController();
  final _clinicController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  DateTime? _selectedDOB;
  String _role = 'patient';
  String _gender = 'Female';

  bool get _isDoctor => _role == 'doctor';

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole == 'doctor' ? 'doctor' : 'patient';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    _clinicController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDOB() async {
    final maxDate = DateTime.now().subtract(const Duration(days: 12 * 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1950),
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDOB = picked);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isDoctor && _selectedDOB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
        dob: _selectedDOB,
        gender: _isDoctor ? '' : _gender,
        role: _role,
        specialization: _specializationController.text.trim(),
        clinic: _clinicController.text.trim(),
        location: _addressController.text.trim(),
        qualification: _qualificationController.text.trim(),
        experience: int.tryParse(_experienceController.text.trim()) ?? 0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created. Please verify your email.'),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyAuthError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final compact = MediaQuery.sizeOf(context).height < 760;
    final narrow = MediaQuery.sizeOf(context).width < 420;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: compact ? 16.0 : 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                  const Icon(Icons.person_add_alt_1,
                      size: 56, color: Colors.white),
                  const SizedBox(height: 14),
                  Text(
                    _isDoctor ? 'Doctor Sign Up' : 'Patient Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _roleDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                  SizedBox(height: compact ? 18 : 24),
                  _RoleSelector(
                    selectedRole: _role,
                    onChanged: (role) => setState(() => _role = role),
                  ),
                  SizedBox(height: compact ? 18 : 24),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _sectionTitle('Account details'),
                            narrow
                                ? Column(
                                    children: [
                                      _field(
                                        _firstNameController,
                                        'First Name',
                                        icon: Icons.person_outline,
                                        validator: _requiredName,
                                      ),
                                      const SizedBox(height: 16),
                                      _field(
                                        _lastNameController,
                                        'Last Name',
                                        validator: _requiredName,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _field(
                                          _firstNameController,
                                          'First Name',
                                          icon: Icons.person_outline,
                                          validator: _requiredName,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _field(
                                          _lastNameController,
                                          'Last Name',
                                          validator: _requiredName,
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 16),
                            _field(
                              _emailController,
                              'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: _emailValidator,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _contactController,
                              'Contact Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: _contactValidator,
                            ),
                            const SizedBox(height: 16),
                            if (_isDoctor) ...[
                              _sectionTitle('Doctor profile'),
                              _field(
                                _specializationController,
                                'Specialization',
                                icon: Icons.medical_services_outlined,
                                validator: _requiredText,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                _clinicController,
                                'Clinic / Hospital',
                                icon: Icons.local_hospital_outlined,
                                validator: _requiredText,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                _addressController,
                                'Location',
                                icon: Icons.location_on_outlined,
                                validator: _requiredText,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                _qualificationController,
                                'Qualification (optional)',
                                icon: Icons.school_outlined,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                _experienceController,
                                'Experience in years (optional)',
                                icon: Icons.work_outline,
                                keyboardType: TextInputType.number,
                                validator: _optionalNumberValidator,
                              ),
                            ] else ...[
                              _sectionTitle('Patient profile'),
                              _field(
                                _addressController,
                                'Address',
                                icon: Icons.location_on_outlined,
                                validator: _requiredText,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _gender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon:
                                      const Icon(Icons.person_pin_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Female', child: Text('Female')),
                                  DropdownMenuItem(
                                      value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (value) =>
                                    setState(() => _gender = value ?? 'Female'),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _pickDOB,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: const Icon(Icons.cake_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  child: Text(
                                    _selectedDOB != null
                                        ? '${_selectedDOB!.day}/${_selectedDOB!.month}/${_selectedDOB!.year}'
                                        : 'Select your date of birth',
                                    style: TextStyle(
                                      color: _selectedDOB != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _sectionTitle('Security'),
                            _passwordField(),
                            const SizedBox(height: 16),
                            _confirmPasswordField(),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("Already have an account?",
                          style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Log In',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: validator,
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon:
              Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your password';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm password';
        if (value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  String? _requiredName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Only alphabets';
    }
    return null;
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter email';
    if (!value.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? _contactValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter contact number';
    if (value.trim().length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? _optionalNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) return 'Enter a number';
    return null;
  }

  String get _roleDescription {
    if (_isDoctor) {
      return 'Create your doctor profile. Admin approval is required before patients can book.';
    }
    return 'Create a patient account. A verification link will be sent to your email.';
  }

  String _friendlyAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email already has an account. Log in instead.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Use a stronger password with at least 6 characters.';
        case 'network-request-failed':
          return 'Check your internet connection and try again.';
      }
    }
    return 'Registration failed. Please check the details and try again.';
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _roleButton('patient', 'User', Icons.person),
          _roleButton('doctor', 'Doctor', Icons.medical_services),
        ],
      ),
    );
  }

  Widget _roleButton(String role, String label, IconData icon) {
    final selected = selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(role),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? AppColors.primary : Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
