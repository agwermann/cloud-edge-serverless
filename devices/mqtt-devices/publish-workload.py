import random
import time
import threading
import sys
from modules.mqtt import MQTTClient

# This code generates multiple publishers
# python3 publish-workload.py mytopic 10 1 10 0.1

n_args = 5

if len(sys.argv) < n_args+1:
    print("Missing paremeters: TOPIC_NAME, NUM_MESSAGES, MESSAGE_PERIOD, NUMBER_OF_PUBLISHERS, TIME_BETWEEN_PUBLISHERS")
    exit()

broker = 'localhost'
port = 1883
topic = sys.argv[1]
n_messages = int(sys.argv[2])
message_period = float(sys.argv[3])
n_publishers = int(sys.argv[4])
time_between_publishers = float(sys.argv[5])

def run():
    client_id = f'python-mqtt-{random.randint(0, 1000)}'
    client = MQTTClient(client_id, broker, port, topic)
    client.connect_mqtt()
    client.publish(n_messages=n_messages, message_period=message_period)
    client.disconnect_mqtt()

threads = []

if __name__ == '__main__':
    for i in range(1, n_publishers):
        thread = threading.Thread(target=run)
        thread.start()
        threads.append(thread)
        time.sleep(time_between_publishers)

    for thread in threads:
        thread.join()