import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/post_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getFeed();
  Future<PostModel> createPost(String content, {XFile? imageFile, int? locationId});
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<List<CommentModel>> getPostComments(String postId);
  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PostModel>> getFeed() async {
    try {
      final response = await dio.get('/api/v1/posts');
      if (response.statusCode == 200) {
        // Backend returns PagedResult, so we need 'items'
        final List<dynamic> data = response.data['items'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch feed');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<PostModel> createPost(String content, {XFile? imageFile, int? locationId}) async {
    try {
      String? remoteImageUrl;
      
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: imageFile.name),
        });
        
        final uploadResponse = await dio.post('/api/v1/posts/image', data: formData);
        if (uploadResponse.statusCode == 200) {
          remoteImageUrl = uploadResponse.data['url'];
        } else {
          throw const ServerFailure('Failed to upload image to server');
        }
      }

      final response = await dio.post('/api/v1/posts', data: {
        'content': content,
        'locationId': locationId,
        // The API maps 'mediaURL' based on the DTO. Use exactly what the DTO expects.
        'media': remoteImageUrl != null ? [{'mediaURL': remoteImageUrl, 'mediaType': 'Image'}] : null,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create post');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      final response = await dio.post('/api/v1/posts/$postId/like');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to like post');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    // Backend ToggleLike handles both on same endpoint
    await likePost(postId);
  }

  @override
  Future<List<CommentModel>> getPostComments(String postId) async {
    try {
      final response = await dio.get('/api/v1/posts/$postId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['comments'];
        return data.map((json) => CommentModel.fromJson(json, postId)).toList();
      } else {
        throw const ServerFailure('Failed to fetch comments');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId}) async {
    try {
      final data = <String, dynamic>{'content': content};
      if (parentCommentId != null) {
        data['parentCommentId'] = int.tryParse(parentCommentId);
      }
      final response = await dio.post('/api/v1/posts/$postId/comment', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommentModel.fromJson(response.data, postId);
      } else {
        throw const ServerFailure('Failed to add comment');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
