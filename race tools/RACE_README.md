# Local Race
The files contained in this folder work with deepracer-for-cloud to run multiple evaluations of different models under the same conditions. Copy and paste these three files into your deepracer-for-cloud folder.
'''
race tools\models_to_race.txt
race tools\race.env
race tools\start-race.sh
'''
 

#### Running a race
** Collect a folder from each racer containing their model and save it into your 'bucket' where all model data is stored.
** Add the names of the model folders that you want to race into models_to_race.txt on individual lines
** Define the race conditions you want into race.env
** Make sure your deepracer minio continer is running with $ source bin/activate.sh
** run the command $ source start-race.sh
** wait for all evaluations to run before closing your terminal

### Evaluating a race
Run the notebook race_results.ipynb to get a visual output of the race results.