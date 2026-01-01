import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_action_provider.dart';
import 'widgets/action_bubble.dart';
import 'widgets/prompt_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _textKey = GlobalKey();
  Offset _bubblePosition = Offset.zero;
  int _selectionStart = 0;
  int _selectionEnd = 0;

  String _displayText = '''Mispellings and grammatical errors can effect your credibility. The same goes for misused commas, and other types of punctuation . Not only will Grammarly underline these issues in red, it will also showed you how to correctly write the sentence.

Underlines that are blue indicate that Grammarly has spotted a sentence that is unnecessarily wordy. You'll find suggestions that can possibly help you revise a wordy sentence in an effortless manner.''';

  void _handleSelection(String selectedText, Offset position, int start, int end) {
    if (selectedText.isNotEmpty) {
      setState(() {
        _bubblePosition = position;
        _selectionStart = start;
        _selectionEnd = end;
      });
      context.read<AIActionProvider>().onTextSelected(selectedText);
    }
  }

  void _showPromptSheet() async {
    context.read<AIActionProvider>().onActionBubbleTapped();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PromptBottomSheet(),
    );

    context.read<AIActionProvider>().closeBottomSheet();

    // Handle the result
    if (result != null && result['text'] != null) {
      final action = result['action'] as String?;
      final newText = result['text'] as String;

      setState(() {
        if (action == 'replace') {
          // Replace selected text with new text
          _displayText = _displayText.substring(0, _selectionStart) +
              newText +
              _displayText.substring(_selectionEnd);
        } else if (action == 'insert') {
          // Insert new text after selection
          _displayText = _displayText.substring(0, _selectionEnd) +
              '\n\n' +
              newText +
              _displayText.substring(_selectionEnd);
        }
      });

      // Reset selection
      context.read<AIActionProvider>().clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Text Editor',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<AIActionProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: Colors.indigo.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Select any text below to see AI suggestions',
                              style: TextStyle(
                                color: Color(0xFF4338CA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Text card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SelectableText(
                        _displayText,
                        key: _textKey,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.8,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                        onSelectionChanged: (selection, cause) {
                          try {
                            final start = selection.start;
                            final end = selection.end;

                            if (start < 0 ||
                                end < 0 ||
                                start > _displayText.length ||
                                end > _displayText.length ||
                                start == end) {
                              return;
                            }

                            final safeStart = start < end ? start : end;
                            final safeEnd = start < end ? end : start;

                            final clampedStart = safeStart.clamp(0, _displayText.length);
                            final clampedEnd = safeEnd.clamp(0, _displayText.length);

                            if (clampedStart >= clampedEnd) {
                              return;
                            }

                            final selectedText = _displayText.substring(
                              clampedStart,
                              clampedEnd,
                            );

                            final RenderBox? box =
                            _textKey.currentContext?.findRenderObject() as RenderBox?;
                            if (box != null && selectedText.isNotEmpty) {
                              final position = Offset(
                                MediaQuery.of(context).size.width - 80,
                                200 + (clampedStart / 10),
                              );
                              _handleSelection(selectedText, position, clampedStart, clampedEnd);
                            }
                          } catch (e) {
                            debugPrint('Selection error: $e');
                          }
                        },
                        selectionControls: MaterialTextSelectionControls(),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Bubble
              if (provider.showActionBubble)
                Positioned(
                  right: 20,
                  bottom: 120,
                  child: ActionBubble(
                    onTap: _showPromptSheet,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
