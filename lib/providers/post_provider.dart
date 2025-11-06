import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/post_service.dart';

class PostFormState {
  final String title;
  final String description;
  final String category;
  final File? mediaFile;
  final bool isLoading;
  final String? error;

  PostFormState({
    this.title = '',
    this.description = '',
    this.category = '',
    this.mediaFile,
    this.isLoading = false,
    this.error,
  });

  PostFormState copyWith({
    String? title,
    String? description,
    String? category,
    File? mediaFile,
    bool? isLoading,
    String? error,
  }) {
    return PostFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      mediaFile: mediaFile ?? this.mediaFile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PostFormNotifier extends StateNotifier<PostFormState> {
  PostFormNotifier() : super(PostFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title, error: null);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description, error: null);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category, error: null);
  }

  void setMediaFile(File? file) {
    state = state.copyWith(mediaFile: file, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  bool validateForm() {
    final title = state.title.trim();
    final description = state.description.trim();
    final category = state.category.trim();

    if (title.isEmpty) {
      state = state.copyWith(error: 'Title is required');
      return false;
    }
    if (title.length < 3) {
      state = state.copyWith(error: 'Title must be at least 3 characters');
      return false;
    }
    if (description.isEmpty) {
      state = state.copyWith(error: 'Description is required');
      return false;
    }
    if (description.length < 10) {
      state = state.copyWith(error: 'Description must be at least 10 characters');
      return false;
    }
    if (category.isEmpty) {
      state = state.copyWith(error: 'Category is required');
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>> submitPost() async {
    if (!validateForm()) {
      return {'success': false, 'message': state.error};
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await PostService.createPost(
        title: state.title.trim(),
        description: state.description.trim(),
        category: state.category.trim(),
        mediaFile: state.mediaFile,
      );

      state = state.copyWith(isLoading: false);

      if (result['success']) {
        state = PostFormState();
        return {
          'success': true,
          'message': 'Post created successfully!',
        };
      } else {
        state = state.copyWith(error: result['message']);
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      final errorMsg = 'Error: $e';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  void resetForm() {
    state = PostFormState();
  }
}

final postFormProvider = StateNotifierProvider<PostFormNotifier, PostFormState>((ref) {
  return PostFormNotifier();
});
