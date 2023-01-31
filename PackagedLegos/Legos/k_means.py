
import sys

import requests
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.metrics import silhouette_score, adjusted_rand_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder, MinMaxScaler

#import numpy as np
#import json
#import pandas as pd
#import seaborn as sns
#import matplotlib.pyplot as plt

'''
Kmeans Clustering Lego

Discription: Detection of sybil behavior by clustering transactions based on
             high frequency / low amount. The timing between transactions is high with the same low amount.

Input : Ethereum Address
Output : Int (raw boolean representation 1 || 0 ) 

Features: Utilizes Trueblocks for all tx data. Predetermined SSE using the silhousette coefficient, if silhouette_score is 
too 

Examples:

    IN:
        python3 k_means.py 0x94ea89d08e840fe58053bf7f059b46b6f03bdc96
    OUT:
        0 

Settable:

    trueblocks_url: TrueBlocks endpoint to request tx data from
    max_records: max amount of record to request for 

'''
trueblocks_url = 'http://192.168.1.17:8080/export'
max_records = 11

def main():

    # pass input wallet address
    address = sys.argv[1]
 
    # get request for transactions
    PARAMS = {'addrs':address,'maxRecords':max_records}
    rawData = requests.get(url = trueblocks_url, params = PARAMS)
   
    # decode tx data
    data = rawData.json()
    tx = data["data"]

    # init time between transactions and labels
    timeBetweenAndAmount = []
    labels = []

    # loop though tx data by index
    for i in range(len(data["data"])):
        # check if we are on the last tx
        if i + 1 == len(data["data"]):
            break
        
        # get timestamps between transactions
        firstTxTime = tx[i]["timestamp"]
        secondTxTime = tx[i + 1]["timestamp"]

        # get time difference between timestamsp 
        timeElapsed = secondTxTime - firstTxTime

        # get eth amount for 
        amount = tx[i]["value"]

        # Remove transactions that have no amount
        if(amount != 0 and address == tx[i]["from"]):
            labels.append(i)
            timeBetweenAndAmount.append([timeElapsed,amount])
    
    # if less then 10 txs consider nonSybil (not enough data to cluster) 
    if(len(timeBetweenAndAmount) < 10):
        print(0)
        return(False)
    
    # setup preprocessor pipeline
    preprocessor = Pipeline([
        ("scaler",MinMaxScaler()),
        ("pca",PCA(n_components=2,random_state=42))
    ])

    # Cluster pipline with predetermined parameters
    clusterer = Pipeline([
        ("kmeans",
        KMeans(
            n_clusters=5,
            init="k-means++",
            n_init=50,
            max_iter=500,
            random_state=42
        ))
    ])

    # combine prepocessor and cluster
    pipe = Pipeline(
        [
            ("preprocessor",preprocessor),
            ("clusterer",clusterer)
        ]
    )

    # fit time data to pipeline
    pipe.fit(timeBetweenAndAmount)
   
    # preprocess and predict time between / amount
    preprocessed_data = pipe["preprocessor"].transform(timeBetweenAndAmount)
    predicted_labels = pipe["clusterer"]["kmeans"].labels_

    # A silhouette coefficient of 0 indicates that clusters are significantly overlapping one another,
    # and a silhouette coefficient of 1 indicates clusters are well-separated
    quality_of_cluster = silhouette_score(preprocessed_data,predicted_labels)

    # if are cluster quality are around 0.0 consider the address to have no sybil
    if quality_of_cluster < 0.5 and quality_of_cluster > -0.5:   
        print(0)
        return(False)

    # cluster label is less then 1 this could be a sign of sybil behaivor
    p_labels = sorted(predicted_labels)
   
    # get the most amount of clusters per label 
    m_label = 6 # out of range of number of labels 
    m_number = 0
    
    # loop through each label cluster
    for label in range(5):
        # get amount of cluster for the label
        label_amount = p_labels.count(label)
        # check if cluster amount is greater then previous cluster
        if label_amount > m_number:
            m_label = label
            m_number = label_amount

    # looking at cluster group 0 
    # if label group 0 has the most cluster consider sybil 
    if(m_label == 0):
        # return 1 (true)
        print(1)
        return(True)
    
    else:
        # return 0 (false)
        print(0)
        return(False)

    # For chart visuals uncomment 
    '''
    pcadf = pd.DataFrame(
        pipe["preprocessor"].transform(timeBetweenAndAmount),
        columns=["Amount","Time_elapsed"],
    )
    pcadf["predicted_cluster"] = pipe["clusterer"]["kmeans"].labels_
  
    plt.style.use("fivethirtyeight")
    plt.figure(figsize=(8, 8))

    scat = sns.scatterplot(
            data=pcadf,
            x = "Amount",
            y = "Time_elapsed",
            s=50,
            hue="predicted_cluster",
            
            palette="Set2",
    )
    scat.set_title("Title")
    plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0)
    plt.show()
    '''


if __name__ == '__main__':
    try:
        main()
      
    except KeyboardInterrupt:
        f.close()