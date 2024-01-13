CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH document_ty_id
    AS (SELECT ivr_id
           , document_type
           , document_identification 
        FROM `keepcoding.ivr_steps` 
       WHERE document_type <> 'UNKNOWN' 
         AND document_identification <> 'UNKNOWN' 
         AND document_type <> 'DESCONOCIDO')
    , cust_phone
    AS (SELECT ivr_id
             , customer_phone 
          FROM `keepcoding.ivr_steps` 
         WHERE customer_phone <> 'UNKNOWN')
    , bill_acc_id
    AS (SELECT ivr_id
             , billing_account_id
          FROM `keepcoding.ivr_steps`
         WHERE billing_account_id <> 'UNKNOWN')
    , rep_phone_24
    AS (SELECT ivr_id
             , phone_number
             , start_date
             , LAG(start_date) OVER(PARTITION BY phone_number ORDER BY start_date, ivr_id) AS previous_call
             , DATETIME_DIFF(start_date, LAG(start_date) OVER(PARTITION BY phone_number ORDER BY start_date, ivr_id), HOUR) AS hour_diff
             , IF (DATETIME_DIFF(start_date, LAG(start_date) OVER(PARTITION BY phone_number ORDER BY start_date, ivr_id), HOUR) > 24, 1, 0) AS prevous_24_hours_lg
          FROM `keepcoding.ivr_calls`)   
    , ca_phone_24
    AS (SELECT ivr_id
             , phone_number
             , start_date
             , LEAD(start_date) OVER(PARTITION BY phone_number ORDER BY start_date, ivr_id) AS previous_call
             , DATETIME_DIFF(start_date, LEAD(start_date) OVER(PARTITION BY phone_number ORDER BY start_date, ivr_id), HOUR) AS hour_diff
             , IF (DATETIME_DIFF(start_date, LEAD(start_date) OVER(PARTITION BY phone_number ORDER BY start_date, ivr_id), HOUR) < 24, 1, 0) AS following_24_hours_lg
          FROM `keepcoding.ivr_calls`)    

SELECT detail.calls_ivr_id ivr_id
     , detail.calls_phone_number phone_number
     , detail.calls_ivr_result ivr_result
     , CASE WHEN calls_vdn_label='ATC%' THEN 'FRONT'
            WHEN calls_vdn_label='TECH%' THEN 'TECH'
            WHEN calls_vdn_label='ABSORPTION' THEN 'ABSORPTION'
            ELSE 'RESTO'
            END AS vdn_aggregation
     , detail.calls_start_date start_date
     , detail.calls_end_date end_date
     , detail.calls_total_duration total_duration
     , detail.calls_customer_segment customer_segment
     , detail.calls_ivr_language ivr_language
     , detail.calls_steps_module steps_module
     , detail.calls_module_aggregation module_aggregation
     , MAX(document_ty_id.document_type) document_type
     , MAX(document_ty_id.document_identification) document_identification
     , MAX(cust_phone.customer_phone) customer_phone
     , MAX(bill_acc_id.billing_account_id) billing_account_id
     , MAX(IF (module_name = 'AVERIA_MASIVA', 1, 0)) AS masiva_lg
     , MAX(IF (step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_description_error = 'UNKNOWN', 1, 0)) AS info_by_phone_lg
     , MAX(IF (step_name = 'CUSTOMERINFOBYDNI.TX' AND step_description_error = 'UNKNOWN', 1, 0)) AS info_by_dni_lg
     , rep_phone_24.prevous_24_hours_lg
     , ca_phone_24.following_24_hours_lg
     FROM `keepcoding.ivr_detail` AS detail
     LEFT
     JOIN document_ty_id
       ON detail.calls_ivr_id = document_ty_id.ivr_id
     LEFT 
     JOIN cust_phone
       ON detail.calls_ivr_id = cust_phone.ivr_id
     LEFT
     JOIN bill_acc_id
       ON detail.calls_ivr_id = bill_acc_id.ivr_id
     LEFT
     JOIN rep_phone_24
       ON detail.calls_ivr_id = rep_phone_24.ivr_id
     LEFT
     JOIN ca_phone_24
       ON detail.calls_ivr_id = ca_phone_24.ivr_id
 GROUP BY ivr_id
        , phone_number
        , ivr_result
        , vdn_aggregation
        , start_date
        , end_date
        , total_duration
        , customer_segment
        , ivr_language
        , steps_module
        , module_aggregation
        , prevous_24_hours_lg
        , following_24_hours_lg
