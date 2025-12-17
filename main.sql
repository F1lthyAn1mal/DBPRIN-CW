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
    record_id  Serial Primary KEY,
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
    bay_inspection_date TIMESTAMP,
    bay_inspection_passed BOOL,
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
    vehicle_id INT NOT NULL,
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
    appt_id INT NOT NULL,
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
    invouce_due_date DATE NOT NULL,
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


