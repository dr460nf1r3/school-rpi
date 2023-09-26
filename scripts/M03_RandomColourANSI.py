#!/usr/bin/env python3

import random
def prRed(prt): 
    print("\033[91m {}\033[00m" .format(prt))
def prGreen(prt):
     print("\033[92m {}\033[00m" .format(prt))
def prYellow(prt):
     print("\033[93m {}\033[00m" .format(prt))
def prLightPurple(prt):
     print("\033[94m {}\033[00m" .format(prt))
def prPurple(prt):
     print("\033[95m {}\033[00m" .format(prt)) 
def prCyan(prt):
     print("\033[96m {}\033[00m" .format(prt))
def prLightGray(prt):
     print("\033[97m {}\033[00m" .format(prt))
def prBlack(prt):
     print("\033[98m {}\033[00m" .format(prt))

def random_coloured_letter(letter):
    zufall=random.randrange(91,97)
    ansi="\033["+str(zufall)+"m"+letter+"\033[00m"
    return ansi
ausgabe="OHMega.IT und BlitzLicht"

for letter in ausgabe:
    print (random_coloured_letter(letter)," ",end='')
print()    
