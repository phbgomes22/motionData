import  turicreate as tc


# load saved model
activityClassifier = tc.load_model('mymodel.model')

# load sessions from preprocessed data
data = tc.SFrame('motion_data.sframe')

# filter the walking data in 3 sec
walking_3_sec = data[(data['activity'] == 'walking') & (data['exp_id'] == 1)][1000:1150]

print walking_3_sec


# do predict
predicts = activityClassifier.predict(walking_3_sec, output_frequency='per_window')
print predicts
