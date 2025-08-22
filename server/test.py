import sys
import threading

print("RLock already loaded:", "threading" in sys.modules)
print("Existing RLock objects:", [k for k in dir(threading) if "RLock" in k])
