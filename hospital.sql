-- Show all appointments with doctor and patient names-- 
SELECT 
  a.appointment_id,
  concat(p.first_name, ' ', p.last_name)AS patient_name,
  concat(d.first_name,' ' , d.last_name) AS doctor_name,
  a.appointment_date,
  a.appointment_time,
  a.reason_for_visit,
  a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date, a.appointment_time;

-- appointments for last month of 2023-- 
SELECT 
  a.appointment_id, 
  concat(p.first_name, ' ' , p.last_name) AS patient_name,
  a.appointment_date,
  a.appointment_time
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
WHERE a.appointment_date between "2023-12-01" and "2023-12-31"
ORDER BY a.appointment_time;

-- Find all patients treated by a specific doctor
SELECT DISTINCT 
  a.doctor_id, p.patient_id, 
  concat(p.first_name,' ', p.last_name) as patient_name
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.doctor_id = "D001"; -- Replace with doctor ID

-- Patients by insurance provider
SELECT first_name, last_name, insurance_provider
FROM patients
WHERE insurance_provider = 'HealthIndia';-- Replace with insurance_provider

-- Show all treatments with related appointment and doctor
SELECT 
  t.treatment_id,
  t.treatment_type,
  t.description,
  t.cost,
  t.treatment_date,
  concat(p.first_name, ' ', p.last_name)AS patient_name,
  concat(d.first_name,' ' , d.last_name) AS doctor_name
FROM treatments t
JOIN appointments a ON t.appointment_id = a.appointment_id
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

-- Total treatment cost per patient
SELECT 
  p.patient_id,
  concat(p.first_name, ' ', p.last_name)AS patient_name,
  SUM(t.cost) AS total_treatment_cost
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY p.patient_id, patient_name
ORDER BY total_treatment_cost DESC;

-- View billing details with patient name and treatment type
SELECT 
  b.bill_id,
  concat(p.first_name, ' ', p.last_name)AS patient_name,
  t.treatment_type,
  b.bill_date,
  b.amount,
  b.payment_status
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
JOIN treatments t ON b.treatment_id = t.treatment_id
ORDER BY b.bill_date DESC;

-- Total revenue (sum of all bills)
SELECT 
  SUM(amount) AS total_revenue
FROM billing;

-- Number of appointments per doctor
SELECT 
  CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
  COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY doctor_name
ORDER BY total_appointments DESC;

-- Number of patients per branch
SELECT 
  d.hospital_branch,
  COUNT(DISTINCT a.patient_id) AS total_patients
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.hospital_branch;

-- Monthly income (billing report)
SELECT 
  EXTRACT(YEAR FROM bill_date) AS year,
  EXTRACT(MONTH FROM bill_date) AS month,
  SUM(amount) AS total_income
FROM billing
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- Doctor’s average treatment cost
SELECT 
  concat(d.first_name , ' ' , d.last_name) AS doctor_name,
  ROUND(AVG(t.cost),2) AS avg_treatment_cost
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY doctor_name
ORDER BY avg_treatment_cost DESC;

-- Full patient visit summary
SELECT 
  p.patient_id,
  concat(p.first_name , ' ' , p.last_name) AS patient_name,
  a.appointment_date,
  concat(d.first_name ,' ' , d.last_name) AS doctor_name,
  t.treatment_type,
  t.cost,
  b.amount AS billed_amount,
  b.payment_status
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN treatments t ON a.appointment_id = t.appointment_id
LEFT JOIN billing b ON t.treatment_id = b.treatment_id
ORDER BY a.appointment_date DESC;

-- Top 5 doctors by total billing
SELECT 
  concat(d.first_name ,' ' , d.last_name) AS doctor_name,
  SUM(b.amount) AS total_earned
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id
WHERE b.payment_status = 'Paid'
GROUP BY doctor_name
ORDER BY total_earned DESC
LIMIT 5;

-- Patient outstanding bills
SELECT 
  concat(p.first_name , ' ' , p.last_name) AS patient_name,
  SUM(b.amount) AS unpaid_amount
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
WHERE b.payment_status = 'Pending'
GROUP BY patient_name
ORDER BY unpaid_amount DESC;

