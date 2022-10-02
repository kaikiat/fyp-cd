import os
import logging
import subprocess
import time
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__file__)
logger.setLevel(logging.INFO)

def main():
    cmd = r"kubectl get svc sgdecoding-online-scaled-master -n ntuasr-production-google --output jsonpath='{.status.loadBalancer.ingress[0].ip}'"
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell = True)
    output, error = process.communicate()
    ip_address = output.decode('utf-8')
    logger.info(f'Ip Address : {ip_address}')
    
    min = 60
    duration = min * 8
    sleep_duration = min * 3
    logger.info('Sleeping for '+ str(sleep_duration) + ' seconds')
    time.sleep(sleep_duration)
    end = int(time.time()) + duration
    
    cmd = f"python3 client/client_3_ssl.py -u ws://{ip_address}/client/ws/speech -r 32000 -t abc --model='SingaporeCS_0519NNET3' client/audio/34.WAV"
    while int(time.time()) < end:
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell = True)
        output, error = process.communicate()
        logger.info(output)
        time.sleep(3)

if __name__ == "__main__":
    main()