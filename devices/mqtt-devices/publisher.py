import random
from modules.mqtt import MQTTClient

broker = '192.168.1.195'
port = 1883
topic = "mytopic"
client_id = f'python-mqtt-{random.randint(0, 1000)}'

def run():
    client = MQTTClient(client_id, broker, port, topic)
    client.connect_mqtt()
    client.publish(n_messages=1, message_period=1, high_priority_frequency=0.1)

if __name__ == '__main__':
    run()