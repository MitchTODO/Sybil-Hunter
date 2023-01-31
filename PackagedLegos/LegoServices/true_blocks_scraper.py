
import time
import sys
import csv 
import requests
import json


def main():

    #PARAMS = {'addrs':address,'maxRecords':100}
    URL = 'http://192.168.1.17:8080/export'
    PARAMS5 = {'addrs':"0x7cd9353471bd97bc63f1ae0e11bfefcc52a22275",'maxRecords':70}
    rawDataMore = requests.get(url = URL, params = PARAMS5)
    jrw = rawDataMore.json()
    print(jrw)

    '''
    with open("Gitcoin-Bulk-Checkout.csv") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        topDonate = {}

        morethen5 = []
        lessThen5 = []

        for row in csv_reader:
            if line_count == 0:
                print(f'Column names are {", ".join(row)}')
                line_count += 1
            else:
                try:
                    topDonate[row[4]] += 1
                except:
                    topDonate[row[4]] = 1
               
                #print(f'\t{row[0]} works in the {row[1]} department, and was born in {row[2]}.')
                line_count += 1
        print(f'Processed {line_count} lines.')

        for top in topDonate:
            if topDonate[top] >= 10:
                morethen5.append(top)
            elif topDonate[top] < 5:
     
                lessThen5.append(top)

        
        topSybil = morethen5[0:15]
        for address in topSybil:
            PARAMS5 = {'addrs':address,'maxRecords':70}
            rawDataMore = requests.get(url = URL, params = PARAMS5)
            jrw = rawDataMore.json()
            with open("sybil/"+address+".json", "w") as outfile:
                outfile.write(json.dumps(jrw))

        bottomNSybil = lessThen5[0:15] 
        for address in bottomNSybil:
            PARAMS3 = {'addrs':address,'maxRecords':70}
            rawDataLess = requests.get(url = URL, params = PARAMS3)
            jrws = rawDataLess.json()
            with open("notSybil/"+address+".json", "w") as outfile2:
                outfile2.write(json.dumps(jrws))
    '''
    '''
        for a in morethen5[0:15]:
        
            #rawData = open('trueBlocksTx.json')
            #data = json.load(rawData)
            data = rawData.json()

        print("\n")
        for b in lessThen5[0:15]:
            print(b)
    '''
  

    print(0)
    




if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        f.close()