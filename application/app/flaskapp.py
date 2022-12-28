from flask import Flask, request, render_template
import pandas as pd
import joblib
from model import pklfilename
# susanli2016
# Declare a Flask app
app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def main():
    
    # If a form is submitted
    if request.method == "POST":
        
        # Unpickle classifier
        clf = joblib.load(pklfilename)

        # Get values through input bars
        mass = request.form.get("mass")
        width = request.form.get("width")
        height = request.form.get("height")

        # Put inputs to dataframe
        X = pd.DataFrame([[mass, width, height]], columns = ["mass", "width", "height"])
        
        # Get prediction
        prediction = clf.predict(X)[0]
        
    else:
        prediction = ""
        
    return render_template("./overlay.html", output = prediction)

# Running the app
if __name__ == '__main__':
    app.run(debug = True, host='0.0.0.0', port=5000)