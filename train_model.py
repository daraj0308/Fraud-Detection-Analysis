import json, pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import precision_recall_fscore_support, roc_auc_score

df = pd.read_csv('data/transactions.csv', parse_dates=['timestamp'])
features = ['amount','hour','is_new_device','seconds_since_prev','distance_from_prev_km','channel','merchant_category','state']
X = df[features].copy()
y = df['is_fraud'].astype(int)
X['seconds_since_prev'] = X['seconds_since_prev'].fillna(36000)
X['distance_from_prev_km'] = X['distance_from_prev_km'].fillna(0.0)

pre = ColumnTransformer([('num','passthrough',['amount','hour','is_new_device','seconds_since_prev','distance_from_prev_km']),
                         ('cat',OneHotEncoder(handle_unknown='ignore'),['channel','merchant_category','state'])])
pipe = Pipeline([('pre',pre),('clf',LogisticRegression(max_iter=300, class_weight='balanced'))])
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
pipe.fit(Xtr, ytr)
yprob = pipe.predict_proba(Xte)[:,1]
yhat = (yprob >= 0.5).astype(int)
p,r,f,_ = precision_recall_fscore_support(yte, yhat, average='binary', zero_division=0)
auc = roc_auc_score(yte, yprob)
with open('metrics.json','w') as f: json.dump({'precision':float(p),'recall':float(r),'f1':float(f),'roc_auc':float(auc)}, f, indent=2)
df['model_fraud_score'] = pipe.predict_proba(X)[:,1]
df.sort_values('model_fraud_score', ascending=False).head(200).to_csv('data/top_suspicious_transactions.csv', index=False)
print('Training complete.')