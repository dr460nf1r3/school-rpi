#!/usr/bin/env python3
# Pythonskript zur Steuerung von Lichtsequenzen v1.0

sortList = list("OHMega.IT")
length = len(sortList) - 1  # Arrays in Python sind nullbasiert.
i=0                         # zählt die Anzahl der Tauschvorgänge
unsorted=True               # ist die Liste noch unsortiert?
while unsorted:
    getauscht = False
    for element in range(0,length):
        unsorted = True
        if sortList[element] > sortList[element + 1]:
            getauscht = True  # Wurden zwei Elemente getauscht?
            # Paarvergleich: Element[i] wird mit Element[i+1] verglichen.
            # wenn das linke Element größer ist als das rechte, wird die Position
            # der beiden Elemente vertauscht.
            hold = sortList[element + 1]
            sortList[element + 1] = sortList[element]
            sortList[element] = hold
       
    if not getauscht: 
        unsorted = False  # Abbruch der while-Schleife, wenn kein
                          # Tausch stattfand.
    i=i+1
    str1=""
    for x in sortList:  # in PAP als For Each-Schleife abbilden!
        str1 += x
   
    print(str(i) + str1)

