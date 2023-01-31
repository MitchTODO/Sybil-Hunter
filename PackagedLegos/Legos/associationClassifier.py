import sys
import requests
import coremltools as ct


model = ct.models.MLModel("/Users/mitch/Desktop/Legos/PackagedLegos/Legos/models/AssociationClassifier.mlmodel")

'''
Assocation Classifier Lego

Discription: Classification through address accociation

Input : Ethereum Address
Output : Int (raw boolean representation 1 || 0 ) 

Note: Script structure similar to behaviorRegressor.py

Features: Utilizes Trueblocks for all tx data. CoreML model requires consolidated transactions.

Examples:

    IN:
        python3 associationClassifier.py 0x94ea89d08e840fe58053bf7f059b46b6f03bdc96
    OUT:
        0 

Settable:

    trueblocks_url: TrueBlocks endpoint to request tx data from
    max_records: max amount of record to request for 

'''
trueblocks_url = 'http://192.168.1.17:8080/export'
max_records = 10

# util formates wei to eth
def amountFormate(bigN):
    if bigN != 0: 
        eth = bigN / (10**18)
        eth_str = str(eth) 
        formate = eth_str[:5]
        
        return float(formate)
    else:
        return 0


def main():
    
    address = sys.argv[1]

    # set up Trueblocks request 
    PARAMS = {'addrs':address,'maxRecords':max_records}
    # get request for transactions
    rawData = requests.get(url= trueblocks_url,params=PARAMS)
    # decode tx data
    data = rawData.json()
    tx_data = data["data"]
    
    # dict key (address communicated with) -> value (consolidated tx's)
    op_data = {}

    # dict to avarge tx times
    last_tx_time = {} 
    
    for tx in tx_data:
        # get contact address
        contact_address = ""

        # init consolidated amounts
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
        # add consolidated amounts
        op_data[contact_address]["in"] += inbound
        op_data[contact_address]["in_amount"] += in_amount 
        op_data[contact_address]["out"] += outbound
        op_data[contact_address]["out_amount"] += out_amount

        # check if contact address is a contract
        is_smart_contract = 0
        if contact_address in data["meta"]["namedTo"]:
            is_smart_contract = data["meta"]["namedTo"][contact_address]["isContract"]
            if is_smart_contract:
                op_data[contact_address]["is_contract"] = 1
        
        # get log topics and set by count
        for log in tx["receipt"]["logs"]:
            for topic in log["topics"]:
                if topic not in op_data[contact_address]["topics"]:
                    op_data[contact_address]["topics"][topic] = 1
                else:
                    op_data[contact_address]["topics"][topic] += 1


        # calculates and set average time between each tx
        if contact_address in last_tx_time:
            last_tx_time[contact_address]["times"].append((tx["timestamp"] -  last_tx_time[contact_address]["lastTime"]))
            last_tx_time[contact_address]["lastTime"] = tx["timestamp"]
 
        else:
            #init dic keys and values
            last_tx_time[contact_address] = {
                "lastTime":0,
                "times":[]
            }
            last_tx_time[contact_address]["lastTime"] = tx["timestamp"]
            last_tx_time[contact_address]["times"] = [] 

        if(len(last_tx_time[contact_address]["times"]) != 0):
            op_data[contact_address]["time_between"] = sum(last_tx_time[contact_address]["times"]) / len(last_tx_time[contact_address]["times"])


    # sybil and nonSybil counter for each address accociatied
    sybil = 0
    nonSybil = 0

    # loop through each key (address the input address accociatied with)
    for consolidedTx in op_data:
        # make predications passing consolided Tx varables
        # predictions outputs a percentage 
        predictions = model.predict({
                                        'address':consolidedTx,
                                        'ins': op_data[consolidedTx]["in"], 
                                        'outs': op_data[consolidedTx]["out"],
                                        'inAmount': amountFormate(op_data[consolidedTx]["in_amount"]),
                                        'outAmount': amountFormate(op_data[consolidedTx]["out_amount"]),
                                        'timeBetween':op_data[consolidedTx]["topics"], 
                                        'topics': round(op_data[consolidedTx]["time_between"]),
                                        'isContract':op_data[consolidedTx]["is_contract"]
                                    })

        # treat predictions more then 50% as sybil, less then as nonSybil
        if(predictions['sybil'] > .5):
            sybil += 1
        else:
            nonSybil += 1
            
    # more sybil tx return 1 (true)
    if(sybil > nonSybil):
        print(1)
        return 1
    # more nonSybil tx return 0 (false)
    else:
        print(0)
        return 0

        
        
    
if __name__ == '__main__':
    try:
        main()

    except KeyboardInterrupt:
        f.close()