// ignore_for_file: prefer_const_constructors
import 'package:infinite_list_state_machine/posts/posts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostEvent', () {
    group('PostFetched', () {
      test('supports value comparison', () {
        expect(PostFetchRequested(), PostFetchRequested());
      });
    });
  });
}
