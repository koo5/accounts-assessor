
import logging
import os

import paho.mqtt.client as mqtt

class MqttHandler(logging.Handler):
    def __init__(self, topic='robust/debug', hostname='localhost', port=1883):
        super().__init__()
        self.topic = topic
        self.client = mqtt.Client(callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
        self.client.connect(hostname, port)

    def emit(self, record):
        msg = self.format(record)
        self.client.publish(self.topic, msg)

    def close(self):
        self.client.disconnect()
        super().close()


mqtt_handler = MqttHandler()
mqtt_handler.setLevel(logging.DEBUG)

logging.basicConfig()
root_logger = logging.getLogger()
root_logger.setLevel(logging.DEBUG)
# this should be the only and default, stderr, handler of root logger:
root_logger.handlers[0].setLevel(logging.INFO)
root_logger.addHandler(mqtt_handler)
mqtt_handler.setFormatter(logging.Formatter('%(asctime)s - '+ os.environ.get('APPDIR','') +' - %(name)s - %(levelname)s - %(message)s'))
