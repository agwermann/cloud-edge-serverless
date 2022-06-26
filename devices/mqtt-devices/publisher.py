import random
import sys
from modules.mqtt import MQTTClient

if len(sys.argv) < 4:
    print("Missing paremeters: TOPIC_NAME, NUM_MESSAGES, MESSAGE_PERIOD")
    exit()

broker = '192.168.1.153'
port = 1883
topic = sys.argv[1]
n_messages = int(sys.argv[2])
message_period = float(sys.argv[3])
client_id = f'python-mqtt-{random.randint(0, 1000)}'

def run():
    client = MQTTClient(client_id, broker, port, topic)
    client.connect_mqtt()
    client.publish(n_messages=n_messages, message_period=message_period)

if __name__ == '__main__':
    run()