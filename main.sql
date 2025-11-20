CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    staff_fname VARCHAR(50) NOT NULL,
    staff_lname VARCHAR(50) NOT NULL,
    staff_phone VARCHAR(15) NOT NULL UNIQUE CHECK (staff_phone ~ '^[0-9]+$'),
    staff_email VARCHAR(150) NOT NULL CHECK (staff_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
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
    FOREIGN KEY (shift_id) REFERENCES shift(shift_id)
);


-- BRANCH AND STAFF_BRANCH INTERSECT
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    manager_id INT NOT NULL,
    branch_phone VARCHAR(15) NOT NULL UNIQUE CHECK (branch_phone ~ '^[0-9]+$'),
    branch_email VARCHAR(150) NOT NULL CHECK (branch_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    branch_addr1 VARCHAR(100) NOT NULL,
    bbranch_addr2 VARCHAR(100),
    branchpostcode VARCHAR(7) NOT NULL,
    branch_city VARCHAR(50) NOT NULL,
    workshop_size SMALLINT NOT NULL 
)

CREATE TABLE branch_staff (
    branch_id INT NOT NULL,
    staff_id INT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);


CREATE TABLE packages(
    package_id SERIAL PRIMARY KEY,
    package_price DECIMAL(10,2) NOT NULL CHECK (package_price >= 0),
    package_desc TEXT
);

CREATE TABLE service_packages (
    service_id INT NOT NULL,
    package_id INT NOT NULL,
    FOREIGN KEY (service_id) REFERENCES service_type(service_id),
    FOREIGN KEY (package_id) REFERENCES packages(package_id)
);

Create Table service_type(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(20) NOT NULL,
    service_price DECIMAL(10,2) NOT NULL CHECK (service_price >= 0)
);


CREATE TABLE service_assignments(
    service_asgn_id SERIAL PRIMARY KEY,
    allocation_id INT NOT NULL,
    service_id INT NOT NULL,
    time_taken DECIMAL(3,1)
);


CREATE TABLE staff_assinments (
    staff_id INT NOT NULL,
    service_asgnn_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);




CREATE TYPE pay_type_enum AS ENUM ('In Full', 'Installment', )

CREATE TABLE payments (
    pay_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    pay_amount DECIMAL(6,2) NOT NULL,
    pay_method VARCHAR(50) NOT NULL,
    pay_date DATE NOT NULL DEFAULT CURRENT_DATE,
    pay_type pay_type_enum
);

CREATE TABLE payment_plans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(50)
);

CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    appt_id INT NOT NULL,
    plan_id INT NOT NULL,
    cust_id INT NOT NULL,
    invoice_total DECIMAL(7,2),
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    invoice_due DECIMAL(7,2),
    invoice_discount_total DECIMAL(7,2),
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id),
    FOREIGN KEY (plan_id) REFERENCES payment_plans(plan_id),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
);

CREATE TABLE appointments (
    appt_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    appt_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (appt_date >= CURRENT_TIMESTAMP)
);

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    appt_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 and 5)
    description TEXT,
    feedback_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (feedback_date >= CURRENT_TIMESTAMP)
);

CREATE TABLE feedback_replies (
    reply_id SERIAL PRIMARY KEY,
    feedback_id INT NOT NULL,
    reply_text TEXT,
    reply_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (reply_date >= CURRENT_TIMESTAMP)
);
