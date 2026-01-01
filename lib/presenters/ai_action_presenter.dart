import '../providers/ai_action_provider.dart';
import '../models/prompt_model.dart';

abstract class AIActionView {
  void showActionBubble(double x, double y);
  void hideActionBubble();
  void showPromptSheet();
  void hidePromptSheet();
  void showResult(AIResult result);
  void showError(String message);
}

class AIActionPresenter {
  final AIActionProvider _provider;
  AIActionView? _view;

  AIActionPresenter(this._provider);

  void attachView(AIActionView view) {
    _view = view;
  }

  void detachView() {
    _view = null;
  }

  void onTextSelected(String text, double x, double y) {
    _provider.onTextSelected(text);
    if (text.isNotEmpty) {
      _view?.showActionBubble(x, y);
    }
  }

  void onSelectionCleared() {
    _provider.clearSelection();
    _view?.hideActionBubble();
  }

  void onActionBubbleTapped() {
    _provider.onActionBubbleTapped();
    _view?.showPromptSheet();
  }

  void onPromptSelected(PromptModel prompt) {
    _provider.applyPrompt(prompt);
  }

  void onCustomPromptSubmitted(String instruction) {
    _provider.applyCustomPrompt(instruction);
  }

  void onPromptCleared() {
    _provider.clearActivePrompt();
  }

  void onBottomSheetDismissed() {
    _provider.closeBottomSheet();
    _view?.hidePromptSheet();
  }

  void onRetry() {
    _provider.retry();
  }
}
