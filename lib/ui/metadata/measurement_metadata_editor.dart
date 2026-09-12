import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import 'tag_picker.dart';

class MeasurementMetadataEditor extends StatefulWidget {
  const MeasurementMetadataEditor({
    super.key,
    required this.controller,
    required this.deviceSequence,
  });

  final AppController controller;
  final int deviceSequence;

  @override
  State<MeasurementMetadataEditor> createState() =>
      _MeasurementMetadataEditorState();
}

class _MeasurementMetadataEditorState extends State<MeasurementMetadataEditor> {
  late final TextEditingController _note;
  late final int? _slot;
  late Set<int> _tagIds;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _slot = widget.controller.userSlot;
    final metadata =
        widget.controller.metadataBySequence[widget.deviceSequence];
    _note = TextEditingController(text: metadata?.note);
    _tagIds = {...?metadata?.tagIds};
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.saveMeasurementMetadata(
        deviceSequence: widget.deviceSequence,
        note: _note.text,
        tagIds: _tagIds,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.userSlot != _slot) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _note,
          enabled: !_saving,
          minLines: 2,
          maxLines: 6,
          maxLength: 4000,
          decoration: const InputDecoration(labelText: 'Bemerkung'),
        ),
        const SizedBox(height: 12),
        TagPicker(
          controller: widget.controller,
          selected: _tagIds,
          enabled: !_saving,
          onChanged: (value) => setState(() => _tagIds = value),
          onError: (error) => setState(() => _error = '$error'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Speichert…' : 'Speichern'),
            ),
          ],
        ),
      ],
    );
  }
}
