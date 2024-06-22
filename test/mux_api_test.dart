import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_stream/res/string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:flutter_stream/utils/mux_client.dart';
import 'package:flutter_stream/model/asset_data.dart';
import 'package:flutter_stream/model/video_data.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late MUXClient muxClient;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter();
    dio.httpClientAdapter = dioAdapter;
    muxClient = MUXClient();
    muxClient.initializeDio();
  });

  group('MUX API mock tests', () {
    test('GET videos', () async {
      const path = '$muxServerUrl/assets';

      String testJsonResponse =
          '{"data" : [{"playback_ids" : [{"policy" : "public", "id" : "9pWt97lvZeW02LOhYpaGiKPN01XvOaK6K15QClHrVxUqs"}], "status" : "ready", "id" : "tOY008DPRz9jB5r01DpOIfKxlspNocMsDUmK3iodCMEZ00", "created_at" : "1612112341"}]}';

      dioAdapter.onGet(path).reply(200, testJsonResponse);

      final response = await dio.get(path);

      expect(await muxClient.getAssetList(), isA<AssetData>());
      expect(response.data, jsonDecode(testJsonResponse));
    });

    test('GET status', () async {
      const videoId = 'QsaseZLbz01n3hv5mJL1sB6TnB8MT3mL7CfiAhaY02MIk';
      const path = '/asset';

      String testJsonResponse =
          '{"data": {"status": "ready", "playback_ids": [{"policy": "public", "id": "tcSCm5mqYxI1Rok602o8yKJQb001zOMvFb4bW61lKSzqE"}], "id": "BIJ95sTJnI4RMwm57GTBWA00WUoZYkQdwjKPqnNAxwi00", "created_at": "1612129368"}}';

      dioAdapter.onGet(path).reply(200, testJsonResponse);

      final response = await dio.get(path);

      expect(await muxClient.checkPostStatus(videoId: videoId), isA<VideoData>());
      expect(response.data, jsonDecode(testJsonResponse));
    });

    test('POST a video', () async {
      const path = '$muxServerUrl/assets';

      String testJsonResponse =
          '{"data": {"status": "preparing", "playback_ids": [{"policy": "public", "id": "tcSCm5mqYxI1Rok602o8yKJQb001zOMvFb4bW61lKSzqE"}], "id": "BIJ95sTJnI4RMwm57GTBWA00WUoZYkQdwjKPqnNAxwi00", "created_at": "1612129368"}}';

      dioAdapter.onPost(
        path,
        data: {
          "input": demoVideoUrl,
          "playback_policy": playbackPolicy,
        },
      ).reply(200, testJsonResponse);

      final response = await dio.post(
        path,
        data: {
          "input": demoVideoUrl,
          "playback_policy": playbackPolicy,
        },
      );

      expect(await muxClient.storeVideo(videoUrl: demoVideoUrl), isA<VideoData>());
      expect(response.data, jsonDecode(testJsonResponse));
    });
  });
}
