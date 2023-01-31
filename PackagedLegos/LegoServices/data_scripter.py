
import sys
import requests
import json
import os
import csv
import random


import numpy as np
from scipy.stats import poisson
import matplotlib.pyplot as plt

def dataExtractor(work_dir):
    #address = sys.argv[1]
    sybil_path = os.listdir(work_dir)
    associated_address = []
    for address_file in sybil_path:
        address = address_file[:42]
        
        raw_data = open(work_dir+"/"+address_file)
        data = json.load(raw_data)
        tx_data = data["data"]
        op_data = {}

        last_tx_time = {} # used to avarge tx times
        
        for tx in tx_data:
            # get contact address
            contact_address = ""

            in_amount = 0
            out_amount = 0
            inbound = 0
            outbound = 0

            if address == tx["to"]:
                # inbound tx
                contact_address = tx["from"]
                in_amount = tx["value"]
                inbound = 1
            else:
                # outbound tx
                contact_address = tx["to"]
                out_amount = tx["value"]
                outbound = 1

            # init keys and values
            if contact_address not in op_data:
                op_data[contact_address] = {
                    "in":0,
                    "out":0,
                    "in_amount":0,
                    "out_amount":0,
                    "time_between":0,
                    "is_contract":0,
                    "topics":{}
                }

            op_data[contact_address]["in"] += inbound
            op_data[contact_address]["in_amount"] += in_amount 
            op_data[contact_address]["out"] += outbound
            op_data[contact_address]["out_amount"] += out_amount

            is_smart_contract = 0
            
            if contact_address in data["meta"]["namedTo"]:
                is_smart_contract = data["meta"]["namedTo"][contact_address]["isContract"]
                if is_smart_contract:
                    op_data[contact_address]["is_contract"] = 1
            
      
            for log in tx["receipt"]["logs"]:
                for topic in log["topics"]:
                    if topic not in op_data[contact_address]["topics"]:
                        op_data[contact_address]["topics"][topic] = 1
                    else:
                        op_data[contact_address]["topics"][topic] += 1
   

            # Time
            if contact_address in last_tx_time:
                last_tx_time[contact_address]["times"].append((tx["timestamp"] -  last_tx_time[contact_address]["lastTime"]))
                last_tx_time[contact_address]["lastTime"] = tx["timestamp"]
                #Update value
            else:
                #init dic keys and values
                last_tx_time[contact_address] = {
                    "lastTime":0,
                    "times":[]
                }
                last_tx_time[contact_address]["lastTime"] = tx["timestamp"]
                last_tx_time[contact_address]["times"] = [] 

                # new key value
            if(len(last_tx_time[contact_address]["times"]) != 0):
                op_data[contact_address]["time_between"] = sum(last_tx_time[contact_address]["times"]) / len(last_tx_time[contact_address]["times"])

        
        associated_address.append(op_data)
        #associated_address[address] = op_data
    return associated_address

def amountFormate(bigN):
    if bigN != 0: 
        eth = bigN / (10**18)
        eth_str = str(eth) 
        formate = eth_str[:5]
        
        return formate
    else:
        return 0

#def timeFormat(time):
#    strTime = str(time)
#    print(strTime[])


def formats(data,is_sybil):
    rows = []
    for address in data:
        for result in address:
            
            rows.append([result,address[result]["in"],
            address[result]["out"],
            amountFormate(address[result]["in_amount"]),
            amountFormate( address[result]["out_amount"]),
            address[result]["topics"],
            round(address[result]["time_between"]),
            address[result]["is_contract"],
            is_sybil
        ])
    return(rows)

def main():

    header =  ["address","ins","outs","inAmount","outAmount","timeBetween","topics","isContract","sybil"]

    likey_sybil = dataExtractor("../data/sybil")
    rows_sybil = formats(likey_sybil,1)
    unlikey_sybil = dataExtractor("../data/notSybil")
    rows_nonsybil = formats(unlikey_sybil,0)

    rows_sybil.extend(rows_nonsybil)
    random.shuffle(rows_sybil)

    with open('topContributors.csv', 'w', encoding='UTF8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows_sybil)
  

    #with open("sybilTx.json","w") as outfile:
    #    json.dump(associated_address,outfile)

  

    '''
    header = ["address","amount","to","from","time_between","is_contract"]
    rows = []
    for key in cont_data:
        rows.append(
            [key,cont_data[key]["amount"],
            str(cont_data[key]["to"]),
            str(cont_data[key]["from"]),
            str(cont_data[key]["time_between"]),
            str(cont_data[key]["is_contract"])

        ])
        #print(key)
        #print(cont_data[key])
        #print("\n")

    filename = "sybil_address.csv"

    with open(filename,"w") as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(header)
        csvwriter.writerow(rows)
    '''
    '''
    for i in range(len(all_transactions)):
        # stop before index 
        if i + 1 == len(all_transactions):
            break

        firstTxTime = all_transactions[i]["timestamp"]
        secondTxTime = all_transactions[i + 1]["timestamp"]

        timeElapsed = secondTxTime - firstTxTime
        elapsed_time.append(timeElapsed)

    mean_elape_time = sum(elapsed_time) / len(elapsed_time)
    print(((mean_elape_time / 60) / 60) )
    '''

    




if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        f.close()