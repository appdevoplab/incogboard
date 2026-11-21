// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-B. Personal shortcuts ("omw" -> "on my way"): add, edit, delete and search. The
// keyboard offers them in the suggestion strip (features/shortcuts).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/data_sections.dart';
import '../../security/shortcuts_store.dart';
import '../app_services.dart';
import 'privacy_format.dart';
import 'privacy_widgets.dart';

class ShortcutsScreen extends StatefulWidget {
  const ShortcutsScreen({super.key});

  @override
  State<ShortcutsScreen> createState() => _ShortcutsScreenState();
}

class _ShortcutsScreenState extends State<ShortcutsScreen> {
  AppServices? _services;
  ShortcutsStore? _store;
  List<PersonalShortcut> _items = const [];
  bool _loading = true;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    final services = _services = AppScope.of(context);
    _store = ShortcutsStore(services.secureStore);
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final list = await _store!.list();
    if (!mounted) return;
    setState(() {
      _items = [...list]..sort((a, b) => a.trigger.toLowerCase().compareTo(b.trigger.toLowerCase()));
      _loading = false;
    });
  }

  Future<void> _changed() async {
    await _services!.notifyDataChanged(const [DataSections.shortcuts]);
    await _refresh();
  }

  Future<void> _edit({PersonalShortcut? existing}) async {
    final draft = await showDialog<({String trigger, String expansion})>(
      context: context,
      builder: (context) => _ShortcutDialog(
        existing: existing,
        takenTriggers: {
          for (final s in _items)
            if (existing == null || s.trigger.toLowerCase() != existing.trigger.toLowerCase()) s.trigger.toLowerCase(),
        },
      ),
    );
    if (draft == null || !mounted) return;
    final store = _store!;
    final problem = existing == null
        ? await store.add(draft.trigger, draft.expansion)
        : await store.update(existing.trigger, draft.trigger, draft.expansion);
    if (!mounted) return;
    if (problem != null) {
      showPrivacyMessage(context, shortcutProblemText(problem));
      return;
    }
    await _changed();
  }

  Future<void> _delete(PersonalShortcut shortcut) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${shortcut.trigger}"?'),
        content: const Text('This removes the shortcut. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _store!.remove(shortcut.trigger);
    await _changed();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visible = [
      for (final s in _items)
        if (query.isEmpty || s.trigger.toLowerCase().contains(query) || s.expansion.toLowerCase().contains(query)) s,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Personal shortcuts')),
      floatingActionButton: _loading || _items.length >= ShortcutRules.maxShortcuts
          ? null
          : FloatingActionButton.extended(
              onPressed: () => unawaited(_edit()),
              icon: const Icon(Icons.add),
              label: const Text('Add shortcut'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const _Empty()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search shortcuts',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const Center(child: Text('No shortcuts match your search.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: visible.length,
                          itemBuilder: (context, i) {
                            final s = visible[i];
                            return ListTile(
                              title: Text(s.trigger),
                              subtitle: Text(s.expansion, maxLines: 2, overflow: TextOverflow.ellipsis),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              onTap: () => unawaited(_edit(existing: s)),
                              trailing: IconButton(
                                tooltip: 'Delete ${s.trigger}',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => unawaited(_delete(s)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PrivacyMascotSlot(size: 88),
            const SizedBox(height: 16),
            Text('No shortcuts yet', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'A shortcut turns a short form into longer text. Examples:\n'
              'omw → on my way\n'
              'addr → your address',
              textAlign: TextAlign.center,
              style: text.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Shortcuts are encrypted on this phone, like your learned words.',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Add or edit one shortcut. Validation runs as the user types, and the save button waits for it.
class _ShortcutDialog extends StatefulWidget {
  const _ShortcutDialog({required this.existing, required this.takenTriggers});

  final PersonalShortcut? existing;
  final Set<String> takenTriggers;

  @override
  State<_ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<_ShortcutDialog> {
  late final TextEditingController _trigger = TextEditingController(text: widget.existing?.trigger ?? '');
  late final TextEditingController _expansion = TextEditingController(text: widget.existing?.expansion ?? '');

  @override
  void dispose() {
    _trigger.dispose();
    _expansion.dispose();
    super.dispose();
  }

  /// Null when valid, otherwise the message to show under the field.
  String? get _triggerError {
    final t = _trigger.text;
    if (t.trim().isEmpty) return null; // the empty field is explained by the save button staying off
    final problem = ShortcutRules.checkTrigger(t);
    if (problem != null) return shortcutProblemText(problem);
    if (widget.takenTriggers.contains(t.trim().toLowerCase())) {
      return shortcutProblemText(ShortcutProblem.duplicateTrigger);
    }
    return null;
  }

  String? get _expansionError {
    final e = _expansion.text;
    if (e.trim().isEmpty) return null;
    final problem = ShortcutRules.checkExpansion(e);
    return problem == null ? null : shortcutProblemText(problem);
  }

  bool get _canSave =>
      _trigger.text.trim().isNotEmpty &&
      _expansion.text.trim().isNotEmpty &&
      _triggerError == null &&
      _expansionError == null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New shortcut' : 'Edit shortcut'),
      content: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: Listenable.merge([_trigger, _expansion]),
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _trigger,
                autofocus: widget.existing == null,
                maxLength: ShortcutRules.maxTriggerLength,
                decoration: InputDecoration(
                  labelText: 'Short form',
                  hintText: 'omw',
                  errorText: _triggerError,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _expansion,
                minLines: 1,
                maxLines: 4,
                maxLength: ShortcutRules.maxExpansionLength,
                decoration: InputDecoration(
                  labelText: 'Expands to',
                  hintText: 'on my way',
                  errorText: _expansionError,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ListenableBuilder(
          listenable: Listenable.merge([_trigger, _expansion]),
          builder: (context, _) => FilledButton(
            onPressed: _canSave
                ? () => Navigator.of(context).pop((trigger: _trigger.text.trim(), expansion: _expansion.text.trim()))
                : null,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
