import serial
import time
import csv

ser = serial.Serial("/dev/ttyUSB0", baudrate=115200)
ser.flushInput()
start_time = time.time()
print(start_time)
num = 0

while True:
    ser_bytes = int.from_bytes(ser.read(), "big")
    print(ser_bytes)
