import 'dart:convert';
import 'dart:io';

import 'package:flutter_text/global/global.dart';
import 'package:flutter_text/utils/api_exception.dart';
import 'package:flutter_text/utils/date_format.dart';
import 'package:flutter_text/utils/log_utils.dart';
import 'package:flutter_text/widget/chat/helper/global/event.dart';
import 'package:flutter_text/widget/chat/helper/message/message_control.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'chat_listener.dart';
part 'chat_state.dart';

class ChatHelper {
  static MqttServerClient client;

  static MqttConnectMessage message = MqttConnectMessage()
      .withClientIdentifier('${GlobalStore.user.name.hashCode}')
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      .startClean()
      .withWillQos(MqttQos.exactlyOnce);

  static void init() async {
    // client = MqttServerClient('ws://172.31.41.83/mqtt', '');
    client ??= MqttServerClient.withPort('broker.emqx.io', '', 1883);
    client.logging(on: false);
    // client.port = 8888;
    // client.useWebSocket = true;
    client.keepAlivePeriod = 20;
    client.onConnected = ChatState.onConnected;
    client.onDisconnected = ChatState.onDisconnected;
    client.onUnsubscribed = ChatState.onUnsubscribed;
    client.onSubscribed = ChatState.onSubscribed;
    client.onSubscribeFail = ChatState.onSubscribeFail;
    client.pongCallback = ChatState.pong;
    client.connectionMessage = message;

    try {
      await client.connect();

      final List<String> topics = getSubscribe();

      topics.forEach((String element) {
        setSubscribe(element);
      });

      ChatMsgConduit.listener();
    } on SocketException catch (e) {
      print(e);
      client.disconnect();
    } catch (e) {
      print(e);
      client.disconnect();
    }
  }

  static List<String> getSubscribe() {
    if (GlobalStore.user != null && GlobalStore.user.name.isNotEmpty == true) {
      final List<String> topics = <String>['topic/test2', 'topic/test3'];
      return topics;
    }
    return <String>[];
  }

  //设置主题
  static void setSubscribe(String topic) {
    client.subscribe(topic, MqttQos.exactlyOnce);
  }
}
