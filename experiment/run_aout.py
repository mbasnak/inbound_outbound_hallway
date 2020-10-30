import os
import sys
sys.path.insert(0, os.path.abspath('C:/Users/Wilson/Desktop/inbound_outbound_hallway'))
from fictrac_2d import FicTracAout

if __name__ == '__main__':
    client1 = FicTracAout()
    client1.run(1)



