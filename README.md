# Local Deepracer Analysis

This is a modification of the AWS deepracer analysis repo that was created specifically to make it easier for people new to DeepRacer running local training on their windows machine through WSL.

To use the notebooks make sure that you have run $source bin/activate.sh in your WSL deepracer-for-cloud folder so the minio container that interprets your stored model data is accessible.

## Running the Notebooks
#### Environment Setup
Use a virtual environment the run the notebooks in. Once your environment has all the packages installed you can run jupyter lab as a command to run jupyter in a browser or use vs code to run the notebook.
```
python3 -m venv venv
source venv/bin/activate
pip install --upgrade -r requirements.txt
jupyter lab
```
#### Run bin/activate.sh in your deepracer-for-cloud folder
To use the file handlers in these notebooks you need to activate the minio docker container so minio can act like the s3 file storage service.

## Race tools
The race tools folder contains a few scripts that can act as a virtual race for models on your computer. Look at the readme file contained within for more details