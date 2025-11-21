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
    FOREIGN 
EY )


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
    allocation_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    time_taken DECIMAL(3,1)

    FOREIGN KEY(service_id) REFERENCES service_type(service_id),
    FOREIGN KEY(allocation_id) REFERENCES workshop_allocation(allocation_id)
);

Create Table workshop_allocation(
    allocation_id SERIAL PRIMARY KEY,
    app_id INT NOT NULL,
)


CREATE TABLE staff_assinments (
    staff_id INT NOT NULL,
    service_asgnn_id INT NOT NULL,
    bay_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (bay_id) REFERENCES service_bays(bay_id)
);

Create Table service_bays(
    bay_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL,
    occupied BOOL,
    FOREIGN KEY(branch_id) REFERENCES branches(branch_id)
);

Create Table bay_compliance(
    bay_record_id SERIAL PRIMARY KEY,
    bay_id INT NOT NULL,
    bay_inspection_date TIMESTAMP,
    bay_inspection_passed BOOL,
    FOREIGN KEY(bay_id) REFERENCES service_bays(bay_id)
);

Create Table parts_usage(
    part_id INT NOT NULL,
    allocation_id INT NOT NULL,
    FOREIGN KEY(part_id) REFERENCES parts(part_id),
    FOREIGN KEY(allocation_id) REFERENCES workshop_allocation(allocation_id)
);
 
 Create TABLE parts(
    part_id Serial Primary Key,
    part_name VARCHAR(50),
    part_description VARCHAR(50),
    part_price DECIMAL(7,2),

 );


 Create Table branch_compliance(
    record_id  Serial Primary KEY,
    branch_id INT NOT NULL,
    branch_inspection_date TIMESTAMP,
    branch_inspection BOOL,
    FOREIGN KEY(branch_id) REFERENCES branches(branch_id)
 );



