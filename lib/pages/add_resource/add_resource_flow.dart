import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddResourceResult {
  final String name;
  final String url;
  final int type;

  AddResourceResult({
    required this.name,
    required this.url,
    required this.type,
  });
}

/// Pantalla inicial: elegir tipo de recurso
class AddResourceChoosePage extends StatelessWidget {
  const AddResourceChoosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text('Agregar recurso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BigOptionButton(
                    icon: Icons.add_photo_alternate_outlined,
                    label: 'Adjuntar archivo',
                    onTap: () async {
                      final result = await Get.to<AddResourceResult>(
                        () => const AddResourceFilePage(),
                      );
                      if (result != null) {
                        Get.back(result: result);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ó',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  _BigOptionButton(
                    icon: Icons.attach_file,
                    label: 'Adjuntar enlace',
                    onTap: () async {
                      final result = await Get.to<AddResourceResult>(
                        () => const AddResourceLinkPage(),
                      );
                      if (result != null) {
                        Get.back(result: result);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BigOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla para adjuntar un enlace
class AddResourceLinkPage extends StatefulWidget {
  const AddResourceLinkPage({super.key});

  @override
  State<AddResourceLinkPage> createState() => _AddResourceLinkPageState();
}

class _AddResourceLinkPageState extends State<AddResourceLinkPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool _canSubmit = false;

  void _updateState() {
    setState(() {
      _canSubmit =
          _nameController.text.trim().isNotEmpty &&
          _linkController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateState);
    _linkController.addListener(_updateState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text('Agregar recurso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre del recurso',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe el nombre del recurso',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enlace',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pega el enlace',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ElevatedButton(
            onPressed: _canSubmit
                ? () {
                    final name = _nameController.text.trim();
                    final url = _linkController.text.trim();
                    Get.back(
                      result: AddResourceResult(name: name, url: url, type: 2),
                    );
                  }
                : null,
            child: const Text('Agregar'),
          ),
        ),
      ),
    );
  }
}

/// Pantalla para adjuntar un "archivo" (se usará una URL del archivo)
class AddResourceFilePage extends StatefulWidget {
  const AddResourceFilePage({super.key});

  @override
  State<AddResourceFilePage> createState() => _AddResourceFilePageState();
}

class _AddResourceFilePageState extends State<AddResourceFilePage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  bool _canSubmit = false;

  void _updateState() {
    setState(() {
      _canSubmit =
          _nameController.text.trim().isNotEmpty && _pickedFile != null;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text('Agregar recurso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre del recurso',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe el nombre del recurso',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Archivo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  try {
                    final XFile? file = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1920,
                      imageQuality: 85,
                    );
                    if (file != null) {
                      _pickedFile = file;
                      _updateState();
                    }
                  } catch (_) {}
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _pickedFile == null
                          ? Colors.grey.shade300
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: _pickedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Toca para adjuntar archivo',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.file(
                                File(_pickedFile!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ElevatedButton(
            onPressed: _canSubmit
                ? () {
                    final name = _nameController.text.trim();
                    final url = _pickedFile!.path;
                    Get.back(
                      result: AddResourceResult(name: name, url: url, type: 1),
                    );
                  }
                : null,
            child: const Text('Agregar'),
          ),
        ),
      ),
    );
  }
}
