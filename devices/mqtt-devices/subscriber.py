import random
from modules.mqtt import MQTTClient

broker = '192.168.1.195'
port = 1883
topic = "mytopic-response"
client_id = f'python-mqtt-{random.randint(0, 100)}'

def run():
    client = MQTTClient(client_id, broker, port, topic)
    client.connect_mqtt()
    client.subscribe()

if __name__ == '__main__':
    run()