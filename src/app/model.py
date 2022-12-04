import pandas as pd
from sklearn.naive_bayes import GaussianNB
import os
dirname = os.path.dirname(__file__)
csvfilename = os.path.join(dirname, './data.csv')
pklfilename = os.path.join(dirname, './clf.pkl')


df = pd.read_csv(csvfilename)

X = df[["Height", "Weight"]]
y = df["Species"]

clf = GaussianNB() 
clf.fit(X, y)

import joblib

joblib.dump(clf, pklfilename)

