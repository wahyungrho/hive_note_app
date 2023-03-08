import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:notes_app_hive/main.dart';

class FormNote extends StatefulWidget {
  final int? index;
  final VoidCallback? callback;
  const FormNote({Key? key, this.index, this.callback}) : super(key: key);

  @override
  State<FormNote> createState() => _FormNoteState();
}

class _FormNoteState extends State<FormNote> {
  int colorID = Random().nextInt(cardsColor.length), id = 0;
  String date =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  FocusNode mainFocus = FocusNode();
  final box = Hive.box('notes');

  Future<void> getNotes() async {
    if (widget.index != null) {
      setState(() {
        id = box.getAt(widget.index!)['id'] ?? 0;
        titleController.text = box.getAt(widget.index!)['title'] ?? '';
        contentController.text = box.getAt(widget.index!)['content'] ?? '';
      });
    }
  }

  void addNote(Map<String, dynamic> data) async {
    try {
      if (widget.index != null) {
        data['id'] = id;
        await box.putAt(widget.index!, data).then((value) {
          Navigator.pop(context);
          widget.callback!();
          _showMyDialog("Succes", 'Data added successfully');
        });
      } else {
        await box.add(data).then((value) {
          Navigator.pop(context);
          widget.callback!();
          _showMyDialog("Succes", 'Data added successfully');
        });
      }
    } catch (e) {
      _showMyDialog('Warning !!', e.toString());
    }
  }

  Future<void> _showMyDialog(String title, message) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text(message)],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  Future deleteData(int index) async {
    box.deleteAt(index).then((value) {
      Navigator.pop(context);
      widget.callback!();
      _showMyDialog("Succes", 'Data delete successfully');
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardsColor[colorID],
      appBar: AppBar(
          backgroundColor: cardsColor[colorID],
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Add a new Note',
            style: TextStyle(color: Colors.black87),
          )),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(mainFocus);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(date),
            const SizedBox(height: 8.0),
            TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Title'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87)),
            TextField(
                focusNode: mainFocus,
                controller: contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Content',
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (titleController.text.isNotEmpty &&
                contentController.text.isNotEmpty) {
              addNote({
                "id": box.values.length + 1,
                "title": titleController.text,
                "content": contentController.text,
                "created_at": date
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text("Save")),
    );
  }
}
