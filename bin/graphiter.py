import graphyte
import re 
import socket
from pygtail import Pygtail
import os

class Graphiter:

    def __init__(self, file, metric):
        self.file = file
        self.metric = metric
        self.pattern = re.compile(r'\[([0-9]{1,}).*\s([0-9]{1,})')
        self.hostname = socket.gethostname()

        graphyte.init(
            os.environ.get('GRAPHITE_ENDPOINT', 'localhost'),
            port=os.environ.get('GRAPHITE_PORT', '2003'),
            log_sends=True
        )

    def start_parsing(self):
        while True:
            for line in Pygtail(self.file):
                    for (bucket, value) in re.findall(self.pattern, line):
                        print(f'{self.hostname}.{self.metric}.{bucket} {float(value)}')
                        graphyte.send(f'{self.hostname}.{self.metric}.{bucket}', float(value))

cpu_lat = Graphiter('/opt/graphiter/.staging.txt', 'cpu-lat')
cpu_lat.start_parsing()