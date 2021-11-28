import sys
import logging
import datetime
from flask import Flask, request
from modules.cloudevent import CloudEventService

app = Flask(__name__)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)

if(len(sys.argv) < 2):
    print('Missing argument: please inform the broker address')
    exit()

broker_address = sys.argv[1]
source = "cloud-event-handler"
message_type = "edge-to-cloud"

@app.route("/", methods=["POST"])
def home():
    cloud_event = CloudEventService()
    event = cloud_event.receive_message(request)

    print(event.data)

    #broker_address = 'http://localhost:8080'
    #broker_address = "broker-ingress.knative-eventing.svc.cluster.local/default/default"

    cloud_event = CloudEventService()
    cloud_event.send_message(broker_address, source, message_type, event.data)

    # Process event

    # app.logger.info(
    #    f"Found {event['id']} from {event['source']} with type "
    #    f"{event['type']} and specversion {event['specversion']}"
    #)

    now = datetime.datetime.now()
    sent_datetime = datetime.datetime.strptime(event.data['timestamp'], "%Y-%m-%dT%H:%M:%S.%f")
    latency = str(now - sent_datetime)

    app.logger.info(
        f"Event Priority: {event.data['priority']} | "
        #f"Data Content: {event.data['message']} bytes - "
        f"Data Length: {len(event.data['message'])} bytes | "
        f"Sent time: {sent_datetime} -"
        f"Now: {now} -"
        f"Latency: {latency}"
    )

    # app.logger.info(
    #    f"Event Data Content: {event.data}"
    # )

    # Return 204 - No-content
    return "", 204

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)