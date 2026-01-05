-- ======================================= CREATE TABLE STATEMENTS =======================================
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    staff_fname VARCHAR(50) NOT NULL,
    staff_lname VARCHAR(50) NOT NULL,
    staff_phone VARCHAR(15) NOT NULL UNIQUE CHECK (staff_phone ~ '^[0-9]+$'),
    staff_email VARCHAR(150) NOT NULL UNIQUE CHECK (staff_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    staff_addr1 VARCHAR(100) NOT NULL,
    staff_addr2 VARCHAR(100),
    staff_postcode VARCHAR(7) NOT NULL,
    staff_city VARCHAR(50) NOT NULL 
);

-- STAFF CERTIFICATION AND INTERSECT TABLE
CREATE TABLE certifications (
    cert_id SERIAL PRIMARY KEY,
    cert_name VARCHAR(100) NOT NULL,
    cert_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE staff_certifications (
    staff_id INT NOT NULL,
    cert_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (cert_id) REFERENCES certifications(cert_id)
);


-- STAFF ROLES AND INTERSECT TABLE
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50)
);
CREATE TABLE staff_roles (
    role_id INT NOT NULL,
    staff_id INT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);


-- STAFF SHIFTS AND INTERSECT TABLE
CREATE TABLE shifts (
    shift_id SERIAL PRIMARY KEY,
    shift_start TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shift_end TIMESTAMP NOT NULL,
    CHECK (shift_end > shift_start)
);
CREATE TABLE staff_shifts (
    staff_id INT NOT NULL,
    shift_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (shift_id) REFERENCES shifts(shift_id)
);


-- BRANCH AND STAFF_BRANCH INTERSECT
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    manager_id INT NOT NULL,
    branch_phone VARCHAR(15) NOT NULL UNIQUE CHECK (branch_phone ~ '^[0-9]+$'),
    branch_email VARCHAR(150) NOT NULL UNIQUE CHECK (branch_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    branch_addr1 VARCHAR(100) NOT NULL,
    bbranch_addr2 VARCHAR(100),
    branch_postcode VARCHAR(7) NOT NULL,
    branch_city VARCHAR(50) NOT NULL,
    workshop_size SMALLINT NOT NULL,
    FOREIGN KEY (manager_id) REFERENCES staff(staff_id)
);

CREATE TABLE branch_staff (
    branch_id INT NOT NULL,
    staff_id INT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

 CREATE TABLE branch_compliance(
    record_id  SERIAL PRIMARY KEY,
    branch_id INT NOT NULL,
    branch_inspection_date TIMESTAMP NOT NULL,
    branch_inspection_passed BOOL NOT NULL,
    FOREIGN KEY(branch_id) REFERENCES branches(branch_id)
 );

CREATE TABLE service_bays(
    bay_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL,
    occupied BOOL NOT NULL,
    FOREIGN KEY(branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE bay_compliance(
    bay_record_id SERIAL PRIMARY KEY,
    bay_id INT NOT NULL,
    bay_inspection_date TIMESTAMP NOT NULL,
    bay_inspection_passed BOOL NOT NULL,
    FOREIGN KEY(bay_id) REFERENCES service_bays(bay_id)
);


CREATE TYPE member_enum AS ENUM ('None', 'Bronze', 'Silver', 'Gold');
CREATE TABLE memberships (
    member_id SERIAL PRIMARY KEY,
    member_tier member_enum NOT NULL,
    member_price DECIMAL(5,2) NOT NULL,
    member_discount DECIMAL(4,2) NOT NULL
);

CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    member_join_date DATE DEFAULT CURRENT_DATE,
    cust_fname VARCHAR(50) NOT NULL,
    cust_lname VARCHAR(50) NOT NULL,
    cust_phone VARCHAR(15) NOT NULL UNIQUE CHECK (cust_phone ~ '^[0-9]+$'),
    cust_email VARCHAR(150) NOT NULL UNIQUE CHECK (cust_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    cust_addr1 VARCHAR(100) NOT NULL,
    cust_addr2 VARCHAR(100),
    cust_postcode VARCHAR(7) NOT NULL,
    cust_city VARCHAR(50) NOT NULL ,
    FOREIGN KEY (member_id) REFERENCES memberships(member_id)
);

CREATE TYPE fuel_type_enum AS ENUM ('Petrol', 'Diesel', 'Electric', 'Hybrid');
CREATE TYPE transmission_enum AS ENUM ('Manual', 'Automatic');
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL,
    vehicle_registration VARCHAR(7) NOT NULL UNIQUE,
    vehicle_vin VARCHAR(17) NOT NULL UNIQUE,
    vehicle_make VARCHAR(50) NOT NULL,
    vehicle_model VARCHAR(50) NOT NULL,
    vehicle_year SMALLINT NOT NULL,
    vehicle_colour VARCHAR(30) NOT NULL,
    vehicle_fuel_type fuel_type_enum NOT NULL,
    vehicle_transmission transmission_enum NOT NULL,
    vehicle_mileage INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TABLE vehicle_mot (
    mot_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    mot_date DATE NOT NULL,
    mot_due_date DATE DEFAULT CURRENT_DATE + INTERVAL '1 Year',
    passed BOOL NOT NULL,
    advisories TEXT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

CREATE TABLE vehicle_history (
    history_id SERIAL PRIMARY KEY,
    vehicle_id INT UNIQUE NOT NULL,
    last_service DATE,
    service_due DATE NOT NULL,
    external_services TEXT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

CREATE TABLE packages(
    package_id SERIAL PRIMARY KEY,
    package_price DECIMAL(10,2) NOT NULL CHECK (package_price >= 0),
    package_desc TEXT
);

CREATE TABLE service_type(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_price DECIMAL(10,2) NOT NULL CHECK (service_price >= 0)
);


CREATE TABLE service_packages (
    service_id INT NOT NULL,
    package_id INT NOT NULL,
    FOREIGN KEY (service_id) REFERENCES service_type(service_id),
    FOREIGN KEY (package_id) REFERENCES packages(package_id)
);

CREATE TYPE status_enum AS ENUM ('Not Started', 'In Progress', 'Completed', 'Missed', 'Rescheduled');
CREATE TABLE appointments (
    appt_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    package_id INT NOT NULL,
    appt_start TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (appt_start >= CURRENT_TIMESTAMP),
    appt_end TIMESTAMP CHECK (appt_end > appt_start),
    status status_enum NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (package_id) REFERENCES packages(package_id)
);

CREATE TABLE appt_history(
    appt_id INT UNIQUE NOT NULL,
    history_id INT NOT NULL,
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id),
    FOREIGN KEY (history_id) REFERENCES vehicle_history(history_id)
);


CREATE TABLE bay_allocation(
    allocation_id SERIAL PRIMARY KEY,
    appt_id INT NOT NULL,
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id)
);

CREATE TABLE service_assignments(
    service_asgn_id  SERIAL PRIMARY KEY,
    allocation_id INT NOT NULL,
    service_id INT NOT NULL,
    time_taken DECIMAL(3,1),
    FOREIGN KEY(service_id) REFERENCES service_type(service_id),
    FOREIGN KEY(allocation_id) REFERENCES bay_allocation(allocation_id)
);


CREATE TABLE staff_assignments (
    staff_id INT NOT NULL,
    service_asgn_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (service_asgn_id) REFERENCES service_assignments(service_asgn_id)
);


CREATE TABLE parts(
    part_id SERIAL PRIMARY KEY,
    part_name VARCHAR(50) NOT NULL,
    part_description VARCHAR(50),
    part_price DECIMAL(7,2) NOT NULL
 );

CREATE TABLE parts_usage(
    part_id INT NOT NULL,
    allocation_id INT NOT NULL,
    FOREIGN KEY(part_id) REFERENCES parts(part_id),
    FOREIGN KEY(allocation_id) REFERENCES bay_allocation(allocation_id)
);
 
CREATE TABLE payment_plans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    plan_duration INT NOT NULL,
    plan_installments SMALLINT NOT NULL
);

CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    appt_id INT NOT NULL,
    plan_id INT NOT NULL,
    cust_id INT NOT NULL,
    invoice_total DECIMAL(7,2),
    invoice_created DATE NOT NULL DEFAULT CURRENT_DATE,
    invoice_due_date DATE NOT NULL,
    invoice_amount_due DECIMAL(7,2),
    invoice_discount_total DECIMAL(7,2),
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id),
    FOREIGN KEY (plan_id) REFERENCES payment_plans(plan_id),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TYPE pay_type_enum AS ENUM ('In Full', 'Installment');
CREATE TABLE payments (
    pay_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    pay_amount DECIMAL(6,2) NOT NULL,
    pay_method VARCHAR(50) NOT NULL,
    pay_date DATE NOT NULL DEFAULT CURRENT_DATE,
    pay_type pay_type_enum,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    appt_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 and 5),
    description TEXT,
    feedback_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (feedback_date >= CURRENT_TIMESTAMP),
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id)
);

CREATE TABLE feedback_replies (
    reply_id SERIAL PRIMARY KEY,
    feedback_id INT NOT NULL,
    reply_text TEXT,
    reply_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (reply_date >= CURRENT_TIMESTAMP),
    FOREIGN KEY (feedback_id) REFERENCES feedback(feedback_id)
);





-- ======================================= FUNCIONS =======================================



-- Automatically create bay_compliance record when a new service_bays row is inserted
CREATE OR REPLACE FUNCTION fn_service_bays_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a corresponding compliance row for the new bay
    INSERT INTO bay_compliance (bay_id, bay_inspection_date, bay_inspection_passed)
    VALUES (NEW.bay_id, CURRENT_TIMESTAMP, true);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_service_bays_after_insert ON service_bays;
CREATE TRIGGER 
    trg_service_bays_after_insert AFTER 
INSERT 
    ON service_bays
FOR EACH ROW
EXECUTE
    FUNCTION fn_service_bays_after_insert();



-- Automatically create brance_compliance record when a new branch row is inserted
CREATE OR REPLACE FUNCION fn_branch_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a corresponding compliance row for the new branch
    INSERT INTO brance_compliance (branch_id, branch_inspection_date, branch_inspection_passed)
    VALUES (NEW.branch_id, TIMESTAMP, true);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql

DROP TRIGGER IF EXISTS trg_branch_after_insert ON branches;
CREATE TRIGGER
    trg_branch_after_insert AFTER
INSERT
    ON branch
FOR EACH ROW
EXECUTE
    FUNCION fn_branch_after_insert();



-- Automatically update vehicle history whenever an insert is made into appt_history when the appt has been completed
CREATE OR REPLACE FUNCTION fn_upt_vehicle_history()
RETURNS TRIGGER AS $$
DECLARE
    v_appt_end TIMESTAMP;
    v_appt_status status_enum;
BEGIN
    -- Get the appointment end date and status
    SELECT appt_end, status 
    INTO v_appt_end, v_appt_status
    FROM appointments 
    WHERE appt_id = NEW.appt_id;
    
    -- Only update if appointment is completed
    IF v_appt_status = 'Completed' AND v_appt_end IS NOT NULL THEN
        UPDATE vehicle_history
        SET last_service = v_appt_end::DATE,
            service_due = (v_appt_end + INTERVAL '6 months')::DATE
        WHERE history_id = NEW.history_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_upt_vehicle_history ON appt_history;
CREATE TRIGGER trg_upt_vehicle_history
AFTER INSERT OR UPDATE
ON appt_history
FOR EACH ROW
EXECUTE FUNCTION fn_upt_vehicle_history(); 



-- If an appointment has an MOT service in it, create new insert for  vehicle_mot table. mot_due_date created based on mot_date
CREATE OR REPLACE FUNCTION fn_create_mot_record()
RETURNS TRIGGER AS $$
DECLARE
    v_has_mot BOOLEAN;
    v_mot_date DATE;
BEGIN
    -- Check if the appointment's package contains an MOT service
    SELECT EXISTS(
        SELECT 1
        FROM service_packages sp
        JOIN service_type st ON sp.service_id = st.service_id
        WHERE sp.package_id = NEW.package_id
        AND LOWER(st.service_name) LIKE '%mot%'
    ) INTO v_has_mot;
    
    -- If MOT service found and appointment is completed, create MOT record
    IF v_has_mot AND NEW.status = 'Completed' AND NEW.appt_end IS NOT NULL THEN
        v_mot_date := NEW.appt_end::DATE;
        
        INSERT INTO vehicle_mot (vehicle_id, mot_date, mot_due_date, passed, advisories)
        VALUES (
            NEW.vehicle_id,
            v_mot_date,
            v_mot_date + INTERVAL '1 year',
            true,
            NULL
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_create_mot_record ON appointments;
CREATE TRIGGER trg_create_mot_record
AFTER INSERT OR UPDATE
ON appointments
FOR EACH ROW
EXECUTE FUNCTION fn_create_mot_record();


-- Automatically calculate the package price when package mappings change
CREATE OR REPLACE FUNCTION fn_calc_package_price()
RETURNS TRIGGER AS $$
DECLARE
    target_package_ids INT[] := ARRAY[]::INT[];
BEGIN
    IF TG_OP = 'INSERT' THEN
        target_package_ids := ARRAY[NEW.package_id];
    ELSIF TG_OP = 'UPDATE' THEN
        target_package_ids := ARRAY(
            SELECT DISTINCT unnest(ARRAY[OLD.package_id, NEW.package_id])
        );
    ELSE
        target_package_ids := ARRAY[OLD.package_id];
    END IF;

    UPDATE packages p
    SET package_price = COALESCE((
        SELECT SUM(st.service_price)
        FROM service_packages sp
        JOIN service_type st ON st.service_id = sp.service_id
        WHERE sp.package_id = p.package_id
    ), 0)
    WHERE p.package_id = ANY(target_package_ids);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calc_package_price ON service_packages;
CREATE TRIGGER trg_calc_package_price
AFTER INSERT OR UPDATE OR DELETE
ON service_packages
FOR EACH ROW
EXECUTE FUNCTION fn_calc_package_price();


-- ======================================= TEST DATA =======================================

-- Membership tiers
INSERT INTO memberships (member_tier, member_price, member_discount) VALUES
    ('None',   0.00, 0.00),
    ('Bronze', 50.00, 0.05),
    ('Silver', 100.00, 0.10),
    ('Gold',   150.00, 0.15);

-- Core staff
INSERT INTO staff (staff_fname, staff_lname, staff_phone, staff_email, staff_addr1, staff_addr2, staff_postcode, staff_city) VALUES
    ('John',   'Turner', '07123456780', 'john.turner@example.com',   '12 Oak Street',      NULL,          'AB12CD', 'Bristol'),
    ('Priya',  'Nair',   '07123456781', 'priya.nair@example.com',    '9 Willow Close',     'Flat 2',       'BC23DE', 'Bristol'),
    ('Elena',  'Morales','07123456782', 'elena.morales@example.com', '45 Park Lane',       NULL,          'CD34EF', 'Bath'),
    ('Sam',    'Nguyen', '07123456783', 'sam.nguyen@example.com',    '3 Station Road',     'Suite 5',     'DE45FG', 'Cardiff'),
    ('Luke',   'Hughes', '07123456784', 'luke.hughes@example.com',   '77 River View',      NULL,          'EF56GH', 'Newport');

-- Roles and role assignments
INSERT INTO roles (role_name) VALUES
    ('Manager'),
    ('Technician'),
    ('Service Advisor');

INSERT INTO staff_roles (role_id, staff_id) VALUES
    (1, 1),  -- John is Manager
    (2, 2),  -- Priya is Technician
    (2, 3),  -- Elena is Technician
    (3, 4),  -- Sam is Service Advisor
    (2, 5);  -- Luke is Technician

-- Certifications and staff mappings
INSERT INTO certifications (cert_name, cert_date) VALUES
    ('MOT Tester',        CURRENT_DATE - INTERVAL '2 years'),
    ('EV Level 2',        CURRENT_DATE - INTERVAL '1 year'),
    ('Hybrid Systems',    CURRENT_DATE - INTERVAL '6 months');

INSERT INTO staff_certifications (staff_id, cert_id) VALUES
    (2, 1),
    (3, 2),
    (5, 3),
    (5, 2);

-- Shifts and staff assignment to shifts
INSERT INTO shifts (shift_start, shift_end) VALUES
    ('2026-01-06 08:00:00', '2026-01-06 16:00:00'),
    ('2026-01-07 08:00:00', '2026-01-07 16:00:00'),
    ('2026-01-08 10:00:00', '2026-01-08 18:00:00');

INSERT INTO staff_shifts (staff_id, shift_id) VALUES
    (2, 1),
    (3, 1),
    (4, 2),
    (5, 3);

-- Branch and staffing
INSERT INTO branches (manager_id, branch_phone, branch_email, branch_addr1, bbranch_addr2, branch_postcode, branch_city, workshop_size) VALUES
    (1, '02070000001', 'bristol@garage.example.com', '100 Harbour Road', NULL, 'BS14AB', 'Bristol', 6);

INSERT INTO branch_staff (branch_id, staff_id) VALUES
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5);

INSERT INTO branch_compliance (branch_id, branch_inspection_date, branch_inspection_passed) VALUES
    (1, CURRENT_TIMESTAMP - INTERVAL '30 days', true);

-- Bays (bay_compliance rows created by trigger)
INSERT INTO service_bays (branch_id, occupied) VALUES
    (1, false),
    (1, false),
    (1, true);

-- Customers and memberships
INSERT INTO customers (member_id, member_join_date, cust_fname, cust_lname, cust_phone, cust_email, cust_addr1, cust_addr2, cust_postcode, cust_city) VALUES
    (2, CURRENT_DATE - INTERVAL '200 days', 'Alice', 'Wong',   '07110000001', 'alice.wong@example.com',   '4 Maple Grove', NULL,      'BS15CD', 'Bristol'),
    (1, CURRENT_DATE - INTERVAL '50 days',  'Brian', 'Carter', '07110000002', 'brian.carter@example.com', '22 Hill View',  'Apt 3',   'BS26DE', 'Bath'),
    (4, CURRENT_DATE - INTERVAL '400 days', 'Chloe', 'Smith',  '07110000003', 'chloe.smith@example.com',  '19 River Way',  NULL,      'CF37EF', 'Cardiff');

-- Vehicles
INSERT INTO vehicles (cust_id, vehicle_registration, vehicle_vin, vehicle_make, vehicle_model, vehicle_year, vehicle_colour, vehicle_fuel_type, vehicle_transmission, vehicle_mileage) VALUES
    (1, 'AB12CDE', '1HGCM82633A004352', 'Toyota',  'Corolla', 2018, 'Blue',  'Hybrid',    'Automatic', 52000),
    (2, 'CD34EFG', '1HGCM82633A004353', 'Ford',    'Focus',   2016, 'Red',   'Petrol',    'Manual',    68000),
    (3, 'EF56GHI', '1HGCM82633A004354', 'Nissan',  'Leaf',    2020, 'White', 'Electric', 'Automatic', 24000),
    (1, 'GH78IJK', '1HGCM82633A004355', 'Vauxhall','Astra',   2015, 'Black', 'Diesel',   'Manual',    95000);

-- Vehicle history
INSERT INTO vehicle_history (vehicle_id, last_service, service_due, external_services) VALUES
    (1, CURRENT_DATE - INTERVAL '7 months', CURRENT_DATE + INTERVAL '5 months', 'Previous oil change at 45k'),
    (2, CURRENT_DATE - INTERVAL '4 months', CURRENT_DATE + INTERVAL '8 months', 'Brake pads changed at 60k'),
    (3, CURRENT_DATE - INTERVAL '9 months', CURRENT_DATE + INTERVAL '3 months', 'Battery health check at dealer'),
    (4, CURRENT_DATE - INTERVAL '14 months', CURRENT_DATE - INTERVAL '8 months', 'Last serviced at 85k miles');

-- Services and packages
INSERT INTO service_type (service_name, service_price) VALUES
    ('MOT',             54.99),
    ('Oil Change',      79.99),
    ('Brake Inspection',59.99),
    ('Tyre Rotation',   29.99),
    ('Battery Check',   39.99);

INSERT INTO packages (package_price, package_desc) VALUES
    (0.00, 'Basic Service'),
    (0.00, 'MOT Package'),
    (0.00, 'EV Care');

INSERT INTO service_packages (service_id, package_id) VALUES
    (2, 1), -- Oil Change in Basic Service
    (3, 1), -- Brake Inspection in Basic Service
    (1, 2), -- MOT in MOT Package
    (5, 3), -- Battery Check in EV Care
    (4, 3); -- Tyre Rotation in EV Care

-- Appointments (start dates kept >= now by construction)
INSERT INTO appointments (vehicle_id, package_id, appt_start, appt_end, status) VALUES
    (1, 1, CURRENT_TIMESTAMP + INTERVAL '1 day', CURRENT_TIMESTAMP + INTERVAL '1 day 2 hours', 'Not Started'),
    (2, 2, CURRENT_TIMESTAMP + INTERVAL '2 hours', CURRENT_TIMESTAMP + INTERVAL '3 hours', 'Completed'),
    (3, 3, CURRENT_TIMESTAMP + INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '3 days 2 hours', 'In Progress');

-- Appointment to history mapping
INSERT INTO appt_history (appt_id, history_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3);

-- Bay allocations
INSERT INTO bay_allocation (appt_id) VALUES
    (1),
    (2),
    (3);

-- Service assignments per appointment
INSERT INTO service_assignments (allocation_id, service_id, time_taken) VALUES
    (1, 2, 1.5),  -- Oil Change for appt 1
    (1, 3, 1.0),  -- Brake Inspection for appt 1
    (2, 1, 1.0),  -- MOT for appt 2
    (3, 5, 0.7),  -- Battery Check for appt 3
    (3, 4, 0.8);  -- Tyre Rotation for appt 3

-- Staff assigned to services
INSERT INTO staff_assignments (staff_id, service_asgn_id) VALUES
    (2, 1),
    (3, 2),
    (5, 3),
    (2, 4),
    (5, 5);

-- Parts and usage
INSERT INTO parts (part_name, part_description, part_price) VALUES
    ('Oil Filter',    'Standard oil filter', 12.50),
    ('Brake Pads',    'Front axle pads',     74.00),
    ('Wiper Blades',  '22 inch pair',        18.00);

INSERT INTO parts_usage (part_id, allocation_id) VALUES
    (1, 1),
    (2, 1),
    (3, 3);

-- Payment plans
INSERT INTO payment_plans (plan_name, plan_duration, plan_installments) VALUES
    ('Single Payment', 1, 1),
    ('3-Month Plan',   3, 3),
    ('6-Month Plan',   6, 6);

-- Invoices
INSERT INTO invoices (appt_id, plan_id, cust_id, invoice_total, invoice_created, invoice_due_date, invoice_amount_due, invoice_discount_total) VALUES
    (1, 2, 1, 139.98, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 132.98, 6.99),
    (2, 1, 2, 54.99,  CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days', 54.99, 0.00),
    (3, 3, 3, 69.98,  CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 59.48, 10.50);

-- Payments
INSERT INTO payments (invoice_id, pay_amount, pay_method, pay_date, pay_type) VALUES
    (1, 44.33, 'Card', CURRENT_DATE, 'Installment'),
    (1, 44.33, 'Card', CURRENT_DATE + INTERVAL '30 days', 'Installment'),
    (2, 54.99, 'Card', CURRENT_DATE, 'In Full'),
    (3, 29.74, 'Bank Transfer', CURRENT_DATE, 'Installment');

-- Feedback and replies
INSERT INTO feedback (appt_id, rating, description) VALUES
    (2, 5, 'Quick MOT and friendly team'),
    (1, 4, 'Service was thorough, small wait time');

INSERT INTO feedback_replies (feedback_id, reply_text) VALUES
    (1, 'Thanks for visiting, Brian!'),
    (2, 'Appreciate the feedback, Alice.');


-- ======================================= INDEXES =======================================





-- ======================================= QUERIES =======================================

-- Upcoming appointments in the next 7 days with customer, vehicle, and package details
SELECT
    a.appt_id AS "Appointment ID",
    a.appt_start AS "Appointment Start",
    a.status AS "Appointment Status",
    c.cust_fname || ' ' || c.cust_lname AS "Customer",
    v.vehicle_registration AS "Vehicle Registration",
    p.package_desc AS "Package Description"
FROM appointments a
JOIN vehicles v ON a.vehicle_id = v.vehicle_id
JOIN customers c ON v.cust_id = c.cust_id
JOIN packages p ON a.package_id = p.package_id
WHERE a.appt_start < CURRENT_TIMESTAMP + INTERVAL '7 days'
ORDER BY a.appt_start;

-- Invoice balances with paid amount and overdue flag
SELECT
    i.invoice_id AS "Invoice ID",
    c.cust_fname || ' ' || c.cust_lname AS "Customer",
    i.invoice_total  AS "Invoice Total",
    COALESCE(SUM(pay.pay_amount), 0) AS "Total Paid",
    i.invoice_total - COALESCE(SUM(pay.pay_amount), 0) AS "Balance Due",
    (CURRENT_DATE > i.invoice_due_date) AS "Is Overdue"
FROM invoices i
JOIN customers c ON i.cust_id = c.cust_id
LEFT JOIN payments pay ON pay.invoice_id = i.invoice_id
GROUP BY i.invoice_id, c.cust_fname, c.cust_lname, i.invoice_total, i.invoice_due_date
ORDER BY i.invoice_due_date;

-- Staff workload for the next 7 days (count of service tasks and scheduled hours)
SELECT
    s.staff_id AS "Staff ID",
    s.staff_fname || ' ' || s.staff_lname AS "Staff",
    COUNT(sa.service_asgn_id) AS "Assigned Tasks",
    SUM(sa.time_taken) AS "Scheduled Hours"
FROM staff s
JOIN staff_assignments ss ON s.staff_id = ss.staff_id
JOIN service_assignments sa ON ss.service_asgn_id = sa.service_asgn_id
JOIN bay_allocation ba ON sa.allocation_id = ba.allocation_id
JOIN appointments a ON ba.appt_id = a.appt_id
WHERE a.appt_start BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '7 days'
GROUP BY s.staff_id, s.staff_fname, s.staff_lname
ORDER BY "Assigned Tasks" DESC, "Scheduled Hours" DESC;

-- Vehicles overdue for service
SELECT
    v.vehicle_registration AS "Vehicle Registration",
    v.vehicle_make AS "Vehicle Make",
    v.vehicle_model AS "Vehicle Model",
    vh.service_due AS "Service Due",
    c.cust_fname || ' ' || c.cust_lname AS "Owner Name"
FROM vehicle_history vh
JOIN vehicles v ON vh.vehicle_id = v.vehicle_id
JOIN customers c ON v.cust_id = c.cust_id
WHERE vh.service_due < CURRENT_DATE
ORDER BY vh.service_due;

-- Latest compliance snapshot per branch with failing bay count
WITH latest_branch AS (
    SELECT
        bc.branch_id,
        bc.branch_inspection_date,
        bc.branch_inspection_passed,
        ROW_NUMBER() OVER (PARTITION BY bc.branch_id ORDER BY bc.branch_inspection_date DESC) AS rn
    FROM branch_compliance bc
), latest_bay AS (
    SELECT
        sb.branch_id,
        sb.bay_id,
        bc.bay_inspection_date,
        bc.bay_inspection_passed,
        ROW_NUMBER() OVER (PARTITION BY bc.bay_id ORDER BY bc.bay_inspection_date DESC) AS rn
    FROM service_bays sb
    JOIN bay_compliance bc ON bc.bay_id = sb.bay_id
)
SELECT
    b.branch_id AS "Branch ID",
    lb.branch_inspection_date AS "Last Branch Inspection",
    lb.branch_inspection_passed AS "Inspection Passed",
    COUNT(lbay.bay_id) AS "Total Bays",
    SUM(CASE WHEN lbay.bay_inspection_passed THEN 0 ELSE 1 END) AS "Failing Bays"
FROM branches b
LEFT JOIN latest_branch lb ON lb.branch_id = b.branch_id AND lb.rn = 1
LEFT JOIN latest_bay lbay ON lbay.branch_id = b.branch_id AND lbay.rn = 1
GROUP BY b.branch_id, lb.branch_inspection_date, lb.branch_inspection_passed
ORDER BY b.branch_id;
