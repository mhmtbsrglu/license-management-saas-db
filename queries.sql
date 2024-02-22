DO $$ 
DECLARE 
    table_name_var TEXT;
BEGIN
    -- List of tables to be truncated
    FOR table_name_var IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    LOOP
        -- Truncate each table if it exists
        EXECUTE 'TRUNCATE TABLE ' || table_name_var || ' CASCADE';
    END LOOP;

    -- Now, recreate the tables
    CREATE TABLE IF NOT EXISTS accounts (
        _id INT PRIMARY KEY,
        email VARCHAR(50) NOT NULL,
        password VARCHAR(50) NOT NULL,
        deleted BOOLEAN DEFAULT FALSE,
        banned BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS customers (
        _id INT PRIMARY KEY,
        account_id INT UNIQUE,
        subscription_type_id INT UNIQUE,
        full_name VARCHAR(50),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP,
        CONSTRAINT fk_account_id FOREIGN KEY(account_id) REFERENCES accounts(_id),
        CONSTRAINT fk_subscription_type_id FOREIGN KEY(subscription_type_id) REFERENCES subscription_types(_id)
    );

    CREATE TABLE IF NOT EXISTS subscription_types (
        _id INT PRIMARY KEY,
        subscription_type TEXT NOT NULL DEFAULT 'DEMO',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP,
        UNIQUE(subscription_type)
    );

    CREATE TABLE IF NOT EXISTS projects (
        _id INT PRIMARY KEY,
        customer_id INT,
        project_title VARCHAR(50) NOT NULL,
        usage_limit INT DEFAULT 10,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP,
        CONSTRAINT FK_CUSTOMER_ID FOREIGN KEY (customer_id) REFERENCES customers(_id)
    );

    CREATE TABLE IF NOT EXISTS project_licenses (
        _id INT PRIMARY KEY,
        project_id INT,
        license_type_id INT UNIQUE,
        license TEXT,
        is_used BOOLEAN DEFAULT FALSE,
        mac_address TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP,
        end_at TIMESTAMP WITH TIME ZONE,
        CONSTRAINT FK_PROJECT_ID FOREIGN KEY(project_id) REFERENCES projects(_id),
        CONSTRAINT FK_LICENSE_TYPE_ID FOREIGN KEY(license_type_id) REFERENCES license_types(_id)
    );

    CREATE TABLE IF NOT EXISTS license_types (
        _id INT PRIMARY KEY,
        license_type TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP,
        UNIQUE(license_type)
    );

    CREATE TABLE IF NOT EXISTS sidebar_items (
        _id INT PRIMARY KEY,
        href TEXT UNIQUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS customer_sidebar_layouts (
        _id INT PRIMARY KEY,
        customer_id INT,
        item_id INT,
        CONSTRAINT FK_CUSTOMER_ID FOREIGN KEY (customer_id) REFERENCES customers(_id),
        CONSTRAINT FK_ITEM_ID FOREIGN KEY (item_id) REFERENCES sidebar_items(_id)
    );

    CREATE TABLE IF NOT EXISTS phone_numbers (
        _id INT PRIMARY KEY,
        customer_id INT NOT NULL,
        country_code INT NOT NULL,
        phone_number TEXT NOT NULL,
        CONSTRAINT FK_CUSTOMER_ID FOREIGN KEY (customer_id) REFERENCES customers(_id)
    );
	
	CREATE TABLE IF NOT EXISTS account_mac_addresses(
		_id INT PRIMARY KEY,
        account_id INT UNIQUE, -- ONE TO ONE
		CONSTRAINT fk_account_id FOREIGN KEY(account_id) REFERENCES accounts(_id)
	);
	
	-- Insert dummy data for accounts
INSERT INTO accounts (_id, email, password) VALUES
(1, 'elon.musk@spacex.com', 'spacexpassword'),
(2, 'jeff.bezos@blueorigin.com', 'blueoriginpassword'),
(3, 'richard.branson@virgin-galactic.com', 'virgingalacticpassword');


-- Insert dummy data for subscription_types
INSERT INTO subscription_types (_id, subscription_type) VALUES
(1, 'Premium'),
(2, 'Gold'),
(3, 'Platinum');

-- Insert dummy data for customers
INSERT INTO customers (_id, account_id, subscription_type_id, full_name) VALUES
(1, 1, 1, 'Elon Musk'),
(2, 2, 2, 'Jeff Bezos'),
(3, 3, 3, 'Richard Branson');

-- Insert dummy data for projects
INSERT INTO projects (_id, customer_id, project_title, usage_limit) VALUES
(1, 1, 'Starship Development', 20),
(2, 2, 'Blue Moon Lunar Lander', 15),
(3, 3, 'Galactic Spaceship Two', 10);

-- Insert dummy data for project_licenses
INSERT INTO project_licenses (_id, project_id, license_type_id, license, is_used, mac_address, end_at) VALUES
(1, 1, 1, 'Starship License', false, '00:11:22:33:44:55', '2024-12-31'),
(2, 2, 2, 'Blue Moon License', false, '11:22:33:44:55:66', '2024-12-31'),
(3, 3, 3, 'Galactic Spaceship License', false, '22:33:44:55:66:77', '2024-12-31');

-- Insert dummy data for sidebar_items
INSERT INTO sidebar_items (_id, href) VALUES
(1, '/dashboard'),
(2, '/projects'),
(3, '/profile');

-- Insert dummy data for customer_sidebar_layouts
INSERT INTO customer_sidebar_layouts (_id, customer_id, item_id) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1),
(4, 3, 3);

-- Insert dummy data for phone_numbers
INSERT INTO phone_numbers (_id, customer_id, country_code, phone_number) VALUES
(1, 1, 1, '1234567890'),
(2, 2, 1, '9876543210'),
(3, 3, 1, '5551234567');

-- Insert dummy data for account_mac_addresses
INSERT INTO account_mac_addresses (_id, account_id, mac_address) VALUES
(1, 1, '00:11:22:33:44:55'),
(2, 2, '11:22:33:44:55:66'),
(3, 3, '22:33:44:55:66:77');


END $$;
