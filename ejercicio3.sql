CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
       SELECT calls.ivr_id calls_ivr_id 
       , calls.phone_number calls_phone_number 
       , calls.ivr_result calls_ivr_result 
       , calls.vdn_label calls_vdn_label 
       , calls.start_date calls_start_date 
       , FORMAT_DATE('%Y%m%d', calls.start_date) as calls_start_date_id 
       , calls.end_date calls_end_date
       , FORMAT_DATE('%Y%m%d', calls.end_date) as calls_end_date_id
       , calls.total_duration calls_total_duration 
       , calls.customer_segment  calls_customer_segment 
       , calls.ivr_language calls_ivr_language 
       , calls.steps_module calls_steps_module 
       , calls.module_aggregation calls_module_aggregation
       , modules.module_sequece
       , modules.module_name
       , modules.module_duration
       , modules.module_result
       , steps.step_sequence
       , steps.step_name
       , steps.step_result
       , steps.step_description_error
       , steps.document_type
       , steps.document_identification
       , steps.customer_phone
       , steps.billing_account_id
    FROM `keepcoding.ivr_calls` AS calls
    LEFT
    JOIN `keepcoding.ivr_modules` AS modules
      ON calls.ivr_id = modules.ivr_id
    LEFT
    JOIN `keepcoding.ivr_steps` AS steps
      ON modules.ivr_id = steps.ivr_id
     AND modules.module_sequece = steps.module_sequece

