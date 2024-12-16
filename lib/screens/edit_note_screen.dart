import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_actividad_autonoma/screens/notes_list_screen.dart';

class EditNoteScreen extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const EditNoteScreen({required this.noteId, required this.noteData, super.key});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  late DatabaseReference _noteRef;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _priceFocusNode;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.noteData['title'] ?? '';
    _descriptionController.text = widget.noteData['description'] ?? '';
    _priceController.text = widget.noteData['price']?.toString() ?? '';

    _noteRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/notes/${widget.noteId}');
    
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (title.isNotEmpty && description.isNotEmpty) {
      try {
        await _noteRef.update({'title': title, 'description': description, 'price': price});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota actualizada')));
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const NoteListScreen())
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, completa todos los campos')));
    }
  }

  Future<void> _deleteNote() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta nota?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _noteRef.remove();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota eliminada')));
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const NoteListScreen())
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteListScreen()),
          ),
        ),
        title: const Text(
          'Editar Nota',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: const TextStyle(color: Colors.white), // Color de la etiqueta
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Línea cuando no está enfocado
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF27C4D9)), // Línea cuando está enfocado
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF27C4D9),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: const TextStyle(color: Colors.white), 
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF27C4D9)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF27C4D9),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              focusNode: _priceFocusNode,
              decoration: InputDecoration(
                labelText: 'Precio',
                labelStyle: const TextStyle(color: Colors.white), // Color de la etiqueta
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Línea cuando no está enfocado
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF27C4D9)), // Línea cuando está enfocado
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF27C4D9),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateNote,
              child: const Text('Actualizar Nota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF27C4D9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
