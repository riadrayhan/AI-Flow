import 'package:flutter/foundation.dart';
import '../models/prompt_model.dart';
import '../services/openai_service.dart';

class AIActionProvider extends ChangeNotifier {
  final OpenAIService _aiService = OpenAIService();

  String _selectedText = '';
  bool _showActionBubble = false;
  bool _showBottomSheet = false;
  AIResult? _result;
  PromptModel? _activePrompt;

  // Getters
  String get selectedText => _selectedText;
  bool get showActionBubble => _showActionBubble;
  bool get showBottomSheet => _showBottomSheet;
  AIResult? get result => _result;
  PromptModel? get activePrompt => _activePrompt;
  bool get isLoading => _result?.isLoading ?? false;
  String? get error => _result?.error;

  // Pre-built prompts
  final List<PromptModel> prompts = const [
    PromptModel(
      id: 'improve',
      title: 'Improve Writing',
      instruction: 'Improve the writing quality of this text',
      iconType: IconType.sparkle,
    ),
    PromptModel(
      id: 'plagiarism',
      title: 'Plagiarism Check',
      instruction: 'Check this text for plagiarism',
      iconType: IconType.check,
    ),
    PromptModel(
      id: 'rewrite',
      title: 'Regenerate',
      instruction: 'Rewrite this text',
      iconType: IconType.refresh,
    ),
    PromptModel(
      id: 'summarize',
      title: 'Add a summary',
      instruction: 'Summarize this text',
      iconType: IconType.summary,
    ),
    PromptModel(
      id: 'simplify',
      title: 'Simplify',
      instruction: 'Simplify this text',
      iconType: IconType.sparkle,
    ),
  ];

  void onTextSelected(String text) {
    if (text.trim().isEmpty) {
      clearSelection();
      return;
    }
    _selectedText = text;
    _showActionBubble = true;
    notifyListeners();
  }

  void clearSelection() {
    _selectedText = '';
    _showActionBubble = false;
    _showBottomSheet = false;
    _result = null;
    _activePrompt = null;
    notifyListeners();
  }

  void onActionBubbleTapped() {
    _showBottomSheet = true;
    notifyListeners();
  }

  void closeBottomSheet() {
    _showBottomSheet = false;
    _result = null;
    _activePrompt = null;
    notifyListeners();
  }

  Future<void> applyPrompt(PromptModel prompt) async {
    _activePrompt = prompt;
    _result = AIResult(
      originalText: _selectedText,
      isLoading: true,
    );
    notifyListeners();

    try {
      final processedText = await _aiService.processText(_selectedText, prompt);
      _result = AIResult(
        originalText: _selectedText,
        processedText: processedText,
        appliedPrompt: prompt,
        isLoading: false,
      );
    } catch (e) {
      _result = AIResult(
        originalText: _selectedText,
        error: 'Failed to process text. Please try again.',
        isLoading: false,
      );
    }
    notifyListeners();
  }

  Future<void> applyCustomPrompt(String instruction) async {
    if (instruction.trim().isEmpty) return;

    final customPrompt = PromptModel(
      id: 'custom',
      title: 'Custom Prompt',
      instruction: instruction,
    );
    await applyPrompt(customPrompt);
  }

  void clearActivePrompt() {
    _activePrompt = null;
    _result = null;
    notifyListeners();
  }

  void retry() {
    if (_activePrompt != null) {
      applyPrompt(_activePrompt!);
    }
  }
}
