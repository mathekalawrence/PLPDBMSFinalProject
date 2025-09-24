-- Road Accidents Reporting System Database
-- 

-- Creating the Database
CREATE DATABASE IF NOT EXISTS road_accidents_db;
USE road_accidents_db;

-- 1. Locations Table (Master data for accident locations)
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_type ENUM('HIGHWAY', 'INTERSECTION', 'RESIDENTIAL', 'COMMERCIAL', 'RURAL') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Persons Table (Information about people involved in accidents)
CREATE TABLE persons (
    person_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    phone_number VARCHAR(20),
    email VARCHAR(150),
    driver_license_number VARCHAR(50) UNIQUE,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Vehicles Table (Information about vehicles involved)
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('CAR', 'TRUCK', 'MOTORCYCLE', 'BUS', 'BICYCLE', 'PEDESTRIAN', 'OTHER') NOT NULL,
    make VARCHAR(50),
    model VARCHAR(50),
    year INT,
    color VARCHAR(30),
    owner_id INT NOT NULL,
    insurance_company VARCHAR(100),
    insurance_policy_number VARCHAR(100),
    FOREIGN KEY (owner_id) REFERENCES persons(person_id) ON DELETE RESTRICT
);

-- 4. Accidents Table (Main accidents record)
CREATE TABLE accidents (
    accident_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_date DATE NOT NULL,
    accident_time TIME NOT NULL,
    location_id INT NOT NULL,
    weather_condition ENUM('CLEAR', 'RAIN', 'SNOW', 'FOG', 'WINDY', 'OTHER') NOT NULL,
    road_condition ENUM('DRY', 'WET', 'ICY', 'CONSTRUCTION', 'OTHER') NOT NULL,
    light_condition ENUM('DAYLIGHT', 'DARK', 'DUSK', 'DAWN') NOT NULL,
    severity_level ENUM('MINOR', 'MODERATE', 'SERIOUS', 'FATAL') NOT NULL,
    total_vehicles_involved INT DEFAULT 1,
    description TEXT,
    investigating_officer VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE RESTRICT
);

-- 5. Accident_Vehicles Junction Table (Many-to-Many: Accidents and Vehicles)
CREATE TABLE accident_vehicles (
    accident_vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    vehicle_damage_level ENUM('NONE', 'MINOR', 'MODERATE', 'SEVERE', 'TOTALED') NOT NULL,
    vehicle_position ENUM('AT_SCENE', 'MOVED', 'UNKNOWN') DEFAULT 'AT_SCENE',
    FOREIGN KEY (accident_id) REFERENCES accidents(accident_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    FOREIGN KEY (driver_id) REFERENCES persons(person_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_accident_vehicle (accident_id, vehicle_id)
);

-- 6. Injuries Table (Records of injuries to persons)
CREATE TABLE injuries (
    injury_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    person_id INT NOT NULL,
    vehicle_id INT,
    injury_type ENUM('NONE', 'MINOR', 'MODERATE', 'SERIOUS', 'FATAL') NOT NULL,
    body_part_affected VARCHAR(100),
    treatment_required ENUM('NONE', 'FIRST_AID', 'HOSPITAL', 'EMERGENCY_ROOM') NOT NULL,
    hospital_name VARCHAR(200),
    injury_description TEXT,
    FOREIGN KEY (accident_id) REFERENCES accidents(accident_id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES persons(person_id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE SET NULL
);

-- 7. Citations Table (Traffic citations issued)
CREATE TABLE citations (
    citation_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    person_id INT NOT NULL,
    vehicle_id INT,
    violation_type VARCHAR(150) NOT NULL,
    violation_code VARCHAR(50),
    fine_amount DECIMAL(10, 2),
    points_assigned INT,
    issued_date DATE NOT NULL,
    issuing_officer VARCHAR(150) NOT NULL,
    status ENUM('ISSUED', 'PAID', 'CONTESTED', 'DISMISSED') DEFAULT 'ISSUED',
    FOREIGN KEY (accident_id) REFERENCES accidents(accident_id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES persons(person_id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE SET NULL
);

-- 8. Witnesses Table (Witness information for accidents)
CREATE TABLE witnesses (
    witness_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    person_id INT NOT NULL,
    contact_info VARCHAR(200),
    statement TEXT,
    is_eyewitness BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (accident_id) REFERENCES accidents(accident_id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES persons(person_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_accident_witness (accident_id, person_id)
);

-- 9. Emergency_Response Table (Emergency services response)
CREATE TABLE emergency_response (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    agency_type ENUM('POLICE', 'AMBULANCE', 'FIRE', 'TOW_TRUCK') NOT NULL,
    agency_name VARCHAR(200) NOT NULL,
    dispatch_time DATETIME,
    arrival_time DATETIME,
    units_dispatched INT DEFAULT 1,
    response_notes TEXT,
    FOREIGN KEY (accident_id) REFERENCES accidents(accident_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_accidents_date ON accidents(accident_date);
CREATE INDEX idx_accidents_location ON accidents(location_id);
CREATE INDEX idx_vehicles_owner ON vehicles(owner_id);
CREATE INDEX idx_injuries_accident ON injuries(accident_id);
CREATE INDEX idx_citations_person ON citations(person_id);

-- Insert sample data for testing
INSERT INTO locations (street_address, city, state, zip_code, latitude, longitude, location_type) VALUES
('123 Main St', 'Nairobi', 'Nairobi County', '00100', -1.286389, 36.817223, 'INTERSECTION'),
('Mombasa Road KM 15', 'Nairobi', 'Nairobi County', '00200', -1.350000, 36.850000, 'HIGHWAY'),
('Uhuru Highway Roundabout', 'Nairobi', 'Nairobi County', '00100', -1.283333, 36.816667, 'INTERSECTION');

INSERT INTO persons (first_name, last_name, date_of_birth, gender, phone_number, driver_license_number) VALUES
('John', 'Kamau', '1995-03-15', 'MALE', '+254712345378', 'DL122456'),
('Mary', 'Wanjiku', '1990-07-22', 'FEMALE', '+254723456789', 'DL234167'),
('David', 'Ochieng', '1978-11-30', 'MALE', '+254732567890', 'DL345678');

INSERT INTO vehicles (license_plate, vehicle_type, make, model, year, color, owner_id) VALUES
('KCA 123A', 'CAR', 'Toyota', 'Premio', 2018, 'White', 1),
('KBB 456B', 'MOTORCYCLE', 'Honda', 'CG125', 2020, 'Red', 2),
('KDA 789C', 'TRUCK', 'Isuzu', 'NPR', 2015, 'Blue', 3);

-- Display table relationships information
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'road_accidents_db' 
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;
