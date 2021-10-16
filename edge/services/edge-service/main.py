import sys
import json
from flask import Flask, request
from modules.cloudevent import CloudEventService
from modules.mqtt import MQTTClient

print(sys.argv)
if(len(sys.argv) < 2):
    print('Missing argument: please inform the broker address, port and topic')
    exit()

#broker_address = "mosquitto"
broker_address = str(sys.argv[1])
broker_port = int(sys.argv[2])
topic = str(sys.argv[3])

source = "edge-service"
message_type = "edge-service-message"
data = { "edge-service": "edge-service-data" }
client_id = "edge-service"

#broker_address = "192.168.1.195"
#broker_port = 1883
#topic = "mytopic-response"

app = Flask(__name__)

@app.route("/", methods=["POST"])
def home():
    cloud_event = CloudEventService()
    event = cloud_event.receive_message(request)

    print(
        f"Found {event['id']} from {event['source']} with type "
        f"{event['type']} and specversion {event['specversion']}"
    )

    # Main Process

    mqtt_client.publish(json.dumps(data))

    # Return 204 - No-content
    return "", 204

if __name__ == "__main__":
    mqtt_client = MQTTClient(client_id=client_id, broker=broker_address, port=broker_port, topic=topic)
    mqtt_client.connect_mqtt()
    print('teste')
    app.run(host='0.0.0.0', port=8080)