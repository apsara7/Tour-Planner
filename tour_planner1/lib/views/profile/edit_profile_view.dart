import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/user_provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    if (user != null) {
      _firstName.text = user['firstName'] ?? "";
      _lastName.text = user['lastName'] ?? "";
      _email.text = user['email'] ?? "";
      _mobile.text = user['mobile'] ?? "";
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateUserProfile({
      "firstName": _firstName.text.trim(),
      "lastName": _lastName.text.trim(),
      "email": _email.text.trim(),
      "mobile": _mobile.text.trim(),
    });

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile updated!" : "Update failed"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) context.go('/edit-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar (non-editable)
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: theme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),

              // Fields
              _textField(_firstName, "First Name", Icons.person_outline),
              const SizedBox(height: 16),
              _textField(_lastName, "Last Name", Icons.person_outline),
              const SizedBox(height: 16),
              _textField(_email, "Email", Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _textField(_mobile, "Mobile", Icons.phone_outlined,
                  type: TextInputType.phone),

              const SizedBox(height: 30),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? type}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: (v) => v!.isEmpty ? "$label is required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
