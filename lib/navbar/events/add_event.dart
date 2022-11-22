import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rsvp/models/event.dart';
import 'package:rsvp/services/database.dart';
import 'package:rsvp/themes/theme.dart';
import 'package:rsvp/utils/extensions.dart';
import 'package:rsvp/utils/utility.dart';
import 'package:rsvp/widgets/textfield.dart';
import 'package:rsvp/widgets/widgets.dart';

class AddEvent extends StatefulWidget {
  bool isEdit;
  AddEvent({Key? key, this.isEdit = false}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final ValueNotifier<Event> _eventNotifier = ValueNotifier(Event.init());

  @override
  void dispose() {
    _eventNotifier.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? file = await pickImageAndCrop(context);
    if (file != null) {
      setState(() {
        coverFile = XFile(file.path);
      });
      await uploadImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadImage() async {
    showCircularIndicator(context);
    File imageFile = File(coverFile!.path);
    final resp = await DatabaseService.uploadImage(imageFile);
    if (resp.didSucced) {
      imageUploadSuccess = true;
      _eventNotifier.value =
          _eventNotifier.value.copyWith(coverImage: resp.data as String);
      showMessage(context, 'Image uploaded successfully');
      stopCircularIndicator(context);
    } else {
      imageUploadSuccess = false;
      showMessage(context, resp.message);
      _eventNotifier.value = _eventNotifier.value.copyWith(coverImage: '');
      stopCircularIndicator(context);
    }
  }

  Future<void> _publishPost() async {
    showCircularIndicator(context);
    final _event = _eventNotifier.value;
    if (_event.name!.isEmpty) {
      showMessage(context, 'Title cannot be empty');
      stopCircularIndicator(context);
      return;
    }
    if (_event.description!.isEmpty) {
      showMessage(context, 'Description cannot be empty');
      stopCircularIndicator(context);
      return;
    }
    if (_event.description!.split(' ').toList().length < 10) {
      showMessage(context, 'Description should be at least 10 words long.');
      stopCircularIndicator(context);
      return;
    }
    if (_event.startsAt!.isAfter(_event.endsAt!)) {
      showMessage(context, 'Start date cannot be after end date.');
      stopCircularIndicator(context);
      return;
    }
    if (_event.address.isEmpty) {
      showMessage(context, 'Location cannot be empty');
      stopCircularIndicator(context);
      return;
    }
    stopCircularIndicator(context);
    Navigator.of(context).pop(_eventNotifier.value);
  }

  bool imageUploadSuccess = true;
  XFile? coverFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Widget _subHeading(String title) {
      return Padding(
        padding: 16.0.horizontalPadding,
        child: Text(
          title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.isEdit ? 'Edit Event' : 'Add Event'),
        actions: [
          // post button
          TextButton(
            onPressed: _publishPost,
            child: const Text(
              'Publish',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: CorsairsTheme.primaryYellow),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.red,
            ),
            CSField(
              hint: 'Whats the event title?',
              hasLabel: false,
              isTransparent: true,
              maxLines: 2,
              autoFocus: true,
              fontSize: 24,
              onChanged: (x) {
                _eventNotifier.value = _eventNotifier.value.copyWith(name: x);
              },
              controller: _titleController,
            ),
            _uploadImage(() {
              pickImage();
            }),
            ValueListenableBuilder<Event>(
                valueListenable: _eventNotifier,
                builder: (context, _event, snapshot) {
                  if (!imageUploadSuccess) {
                    return Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: uploadImage,
                            child: const Text(
                              'Retry Upload',
                              style: TextStyle(color: Colors.red),
                            )));
                  } else {
                    return const SizedBox();
                  }
                }),
            CSField(
              hint: 'In few lines explain what the event is about',
              hasLabel: false,
              isTransparent: true,
              fontSize: 16,
              maxLines: 4,
              onChanged: (x) {
                _eventNotifier.value =
                    _eventNotifier.value.copyWith(description: x);
              },
              controller: _descriptionController,
            ),
            8.0.vSpacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: _subHeading('Event Starts At'),
            ),
            ValueListenableBuilder<Event>(
                valueListenable: _eventNotifier,
                builder: (context, _event, snapshot) {
                  return ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: CorsairsTheme.primaryYellow),
                    onTap: () {
                      final now = DateTime.now();
                      showCSPickerSheet(
                          context,
                          (newDate) {
                            _eventNotifier.value = _event.copyWith(
                                startsAt: newDate, createdAt: now);
                          },
                          'Event Starts At',
                          _event.startsAt!,
                          onClosed: () {
                            print('closed');
                          });
                    },
                    title: Text(_event.startsAt!.formatDate()),
                    subtitle: Text(_event.startsAt!.standardTime()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                }),
            Align(
              alignment: Alignment.centerLeft,
              child: _subHeading('Event Ends At'),
            ),
            ValueListenableBuilder<Event>(
                valueListenable: _eventNotifier,
                builder: (context, _event, snapshot) {
                  return ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: CorsairsTheme.primaryYellow),
                    onTap: () {
                      showCSPickerSheet(
                        context,
                        (newDate) {
                          _eventNotifier.value =
                              _event.copyWith(endsAt: newDate);
                        },
                        'Event Ends At',
                        _event.startsAt!.add(
                          const Duration(hours: 1),
                        ),
                      );
                    },
                    title: Text(_event.endsAt!.formatDate()),
                    subtitle: Text(_event.endsAt!.standardTime()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                }),
            CSField(
              hint: 'Where is the event taking place?',
              hasLabel: false,
              isTransparent: true,
              fontSize: 16,
              maxLines: 4,
              controller: _locationController,
              onChanged: (x) {
                _eventNotifier.value =
                    _eventNotifier.value.copyWith(address: x);
              },
            ),
            // TODO INVITE BOTTOM SHEET
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadImage(Function onUpload) {
    return Container(
      margin: 16.0.allPadding,
      decoration: BoxDecoration(
        border: Border.all(color: CorsairsTheme.primaryYellow, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: InkWell(
        onTap: () => onUpload(),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: coverFile != null
              ? Image.file(File(coverFile!.path))
              : const Center(
                  child: Text(
                    'Upload Image',
                    style: TextStyle(
                      color: CorsairsTheme.primaryYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
