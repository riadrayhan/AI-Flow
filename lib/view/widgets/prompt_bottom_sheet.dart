import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_action_provider.dart';
import '../../models/prompt_model.dart';
import 'prompt_chip.dart';
import 'result_view.dart';

class PromptBottomSheet extends StatefulWidget {
  const PromptBottomSheet({super.key});

  @override
  State<PromptBottomSheet> createState() => _PromptBottomSheetState();
}

class _PromptBottomSheetState extends State<PromptBottomSheet> {
  final TextEditingController _customPromptController = TextEditingController();

  @override
  void dispose() {
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<AIActionProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom prompt input
                          _buildCustomPromptInput(provider),
                          const SizedBox(height: 20),

                          // Active prompt indicator
                          if (provider.activePrompt != null)
                            _buildActivePromptIndicator(provider),

                          // Result view
                          if (provider.result != null)
                            ResultView(result: provider.result!),

                          // Prompt chips
                          if (provider.result == null) ...[
                            _buildPromptChips(provider),
                            const SizedBox(height: 20),
                            _buildActionButtons(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomPromptInput(AIActionProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customPromptController,
              decoration: const InputDecoration(
                hintText: 'Write a prompt here...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_customPromptController.text.isNotEmpty) {
                provider.applyCustomPrompt(_customPromptController.text);
                _customPromptController.clear();
              }
            },
            icon: Icon(
              Icons.send_rounded,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePromptIndicator(AIActionProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            '${provider.activePrompt!.title} Applied',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => provider.clearActivePrompt(),
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChips(AIActionProvider provider) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: provider.prompts.map((prompt) {
        return PromptChip(
          prompt: prompt,
          onTap: () => provider.applyPrompt(prompt),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            // Insert action
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Insert'),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {
            // Replace action
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: Colors.blue),
          ),
          child: const Text('Replace'),
        ),
      ],
    );
  }
}
