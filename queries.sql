SELECT SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END)::float / COUNT(*) AS fraud_rate FROM transactions;
SELECT date_trunc('week', ts) AS week_start,
       SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_count,
       COUNT(*) AS total_tx,
       SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END)::float / COUNT(*) AS fraud_rate
FROM transactions GROUP BY 1 ORDER BY 1;
WITH tx AS (
  SELECT user_id, ts,
         COUNT(*) OVER (PARTITION BY user_id ORDER BY ts
                        RANGE BETWEEN INTERVAL '2 minutes' PRECEDING AND CURRENT ROW) AS tx_in_2min
  FROM transactions)
SELECT * FROM tx WHERE tx_in_2min >= 3;
SELECT * FROM transactions WHERE seconds_since_prev <= 3600 AND distance_from_prev_km > 800;
SELECT merchant_category, channel,
       COUNT(*) FILTER (WHERE is_fraud) AS frauds,
       COUNT(*) AS total,
       ROUND(COUNT(*) FILTER (WHERE is_fraud)::numeric / NULLIF(COUNT(*),0), 4) AS rate
FROM transactions GROUP BY merchant_category, channel ORDER BY rate DESC, frauds DESC;