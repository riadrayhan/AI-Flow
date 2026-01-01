class PromptModel {
  final String id;
  final String title;
  final String instruction;
  final IconType iconType;

  const PromptModel({
    required this.id,
    required this.title,
    required this.instruction,
    this.iconType = IconType.sparkle,
  });
}

enum IconType { sparkle, check, refresh, summary }

class AIResult {
  final String originalText;
  final String processedText;
  final PromptModel? appliedPrompt;
  final bool isLoading;
  final String? error;

  const AIResult({
    required this.originalText,
    this.processedText = '',
    this.appliedPrompt,
    this.isLoading = false,
    this.error,
  });

  AIResult copyWith({
    String? originalText,
    String? processedText,
    PromptModel? appliedPrompt,
    bool? isLoading,
    String? error,
  }) {
    return AIResult(
      originalText: originalText ?? this.originalText,
      processedText: processedText ?? this.processedText,
      appliedPrompt: appliedPrompt ?? this.appliedPrompt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
