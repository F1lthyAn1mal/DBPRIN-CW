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
    cert_date DATE NOT NULL
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
    shift_start TIMESTAMP NOT NULL,
    shift_end TIMESTAMP NOT NULL,
    CHECK (shift_end > shift_start)
);
CREATE TABLE staff_shifts (
    staff_id INT NOT NULL,
    shift_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (shift_id) REFERENCES shift(
);


-- BRANCH AND STAFF_BRANCH INTERSECT
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    manager_id INT NOT NULL,
    branch_phone VARCHAR(15) NOT NULL UNIQUE CHECK (branch_phone ~ '^[0-9]+$'),
    branch_email VARCHAR(150) NOT NULL UNIQUE CHECK (branch_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
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
    package_price DECIMAL(10,2),
    package_ideas TEXT
    
);

CREATE TABLE service_packages(
    staff_id  INT,
    package_id INT

    FOREIGN KEY(package_id  
);

Create Table service_type(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(20),
    service_price  DECIMAL(10,2)
    
);


CREATE TABLE service_assignments(
    service_asgn_id  SERIAL PRIMARY KEY,
    allocation_id INTEGER,
    service_id INTEGER
);


CREATE TABLE staff_assignments (
    staff_id INT NOT NULL,
    service_asgnn_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),

)

CREATE TYPE member_enum AS ENUM ('None', 'Bronze', 'Silver', 'Gold');
CREATE TYPE member_duration_enum AS ENUM('None', 'Month', 'Year', '3 Year');
CREATE TABLE memberships (
    member_id SERIAL PRIMARY KEY,
    member_tier member_enum NOT NULL,
    member_duration member_duration_enum NOT NULL,
    member_price DECIMAL(5,2) NOT NULL,
    member_discount DECIMAL(4,2) NOT NULL
);

CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
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

CREATE TABLE vehicle_history (
    history_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    last_service DATE,
    service_due DATE NOT NULL,
    external_services TEXT
);

CREATE TABLE appointments(
    appt_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    appt_date TIMESTAMP NOT NULL
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

CREATE TABLE appt_history(
    appt_id INT NOT NULL,
    history_id INT NOT NULL,
    FOREIGN KEY (appt_id) REFERENCES appointments(appt_id),
    FOREIGN KEY (history_id) REFERENCES vehicle_history(history_id)
);