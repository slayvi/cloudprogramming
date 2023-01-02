# Importing Libraries:
from flask import Flask, request, render_template
import pandas as pd
import joblib
from model import pklfilename


# Declare the Flask app:
app = Flask(__name__)


# Create Main Function:
@app.route('/', methods=['GET', 'POST'])
def main():

    # If submitted:
    if request.method == "POST":
        
        # Load the model:
        clf = joblib.load(pklfilename)

        # Get values from input by user:
        mass = request.form.get("mass")
        width = request.form.get("width")
        height = request.form.get("height")

        # Put inputs to dataframe:
        X = pd.DataFrame([[mass, width, height]], columns = ["mass", "width", "height"])
        
        # Get prediction:
        prediction = clf.predict(X)[0]
        
    else:
        prediction = ""


    # Return template:    
    return render_template("./overlay.html", output = prediction)


# Running the app on port 5000 localhost:
if __name__ == '__main__':
    app.run(debug = True, host='0.0.0.0', port=5000)