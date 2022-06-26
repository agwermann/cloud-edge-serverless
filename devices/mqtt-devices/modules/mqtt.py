import time
import datetime
import json
from paho.mqtt import client as paho_mqtt_client


class MQTTClient:

    def __init__(self, client_id, broker, port, topic) -> None:
        self.mqttclient = paho_mqtt_client.Client(client_id)
        self.broker = broker
        self.port = port
        self.topic = topic
        self.message = { "timestamp": 1, "message": "", "priority": 1}

    def connect_mqtt(self):
        def on_connect(client, userdata, flags, rc) -> None:
            if rc == 0:
                print("Connected to MQTT Broker on topic %s", self.topic)
            else:
                print("Failed to connect to topic %s, return code %d\n", self.topic, rc)

        self.mqttclient.on_connect = on_connect
        self.mqttclient.connect(self.broker, self.port)
        return self.mqttclient

    def generate_payload_size(self, nbytes):
        payload = "-"
        for i in range(nbytes):
            payload += "a"
        return payload

    def build_message(self, msg_count):
        msg = self.message
        msg["message"] = str(msg_count) + self.generate_payload_size(500)
        msg["timestamp"] = datetime.datetime.now().isoformat()
        return json.dumps(msg)

    # n_messages: total amount of messages
    # message_period: period of time between each message (seconds)
    # high_priority_frequency: [0,1], percentage of priority 1 against priority 2 messages
    def publish(self, n_messages, message_period):
        msg_count = 0
        while n_messages > msg_count:
            time.sleep(message_period)
            msg = self.build_message(msg_count=msg_count)
            result = self.mqttclient.publish(self.topic, msg)
            status = result[0]
            if status == 0:
                print(f"Send `{msg}` to topic `{self.topic}`")
            else:
                print(f"Failed to send message to topic {self.topic}")
            msg_count += 1

    def subscribe(self):
        def on_message(client, userdata, msg):
            print(f"Received `{msg.payload.decode()}` from `{msg.topic}` topic")
        self.mqttclient.subscribe(self.topic)
        self.mqttclient.on_message = on_message
        self.mqttclient.loop_forever()