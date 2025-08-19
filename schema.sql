CREATE TABLE users (
  user_id INT PRIMARY KEY,
  home_state CHAR(2),
  avg_amount DECIMAL(10,2),
  primary_device VARCHAR(32)
);
CREATE TABLE transactions (
  transaction_id INT PRIMARY KEY,
  user_id INT REFERENCES users(user_id),
  ts TIMESTAMP,
  amount DECIMAL(10,2),
  state CHAR(2),
  lat DECIMAL(9,6),
  lon DECIMAL(9,6),
  channel VARCHAR(16),
  merchant_category VARCHAR(32),
  device_id VARCHAR(32),
  is_new_device BOOLEAN,
  seconds_since_prev INT,
  distance_from_prev_km DECIMAL(10,2),
  is_fraud BOOLEAN,
  model_fraud_score DECIMAL(6,5)
);
CREATE INDEX idx_tx_user_ts ON transactions(user_id, ts);
CREATE INDEX idx_tx_state ON transactions(state);
CREATE INDEX idx_tx_is_fraud ON transactions(is_fraud);