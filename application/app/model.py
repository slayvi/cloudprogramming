# Importing Libraries:
import pandas as pd
from sklearn.naive_bayes import GaussianNB
import os
import joblib


# Set Filenames for better overview:
dirname = os.path.dirname(__file__)
csvfilename = os.path.join(dirname, './data.csv')
pklfilename = os.path.join(dirname, './clf.pkl')


# Read Dataset:
df = pd.read_csv(csvfilename)


# Declare Inputs and Outputs:
X = df[["mass", "width", "height"]]
y = df["fruit_name"]


# Train Model
clf = GaussianNB() 
clf.fit(X, y)


# Save Model as .pkl File:
joblib.dump(clf, pklfilename)

