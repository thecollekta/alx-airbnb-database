-- Airbnb Clone Database - Table Partitioning Implementation
-- Partitioning the Booking table by start_date for improved query performance

-- Begin transaction for consistent partitioning setup
BEGIN;

-- Create backup of existing booking data
CREATE TABLE booking_backup AS SELECT * FROM booking;

-- Drop existing booking table (preserve constraints for recreation)
DROP TABLE IF EXISTS booking CASCADE;

-- Create new partitioned booking table
CREATE TABLE booking (
    booking_id UUID DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status booking_status_enum NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

-- Constraints
CONSTRAINT pk_booking_partitioned PRIMARY KEY (booking_id, start_date),
    CONSTRAINT fk_booking_property FOREIGN KEY (property_id) 
        REFERENCES property(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) 
        REFERENCES "user"(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_valid_dates CHECK (start_date < end_date),
    CONSTRAINT chk_future_booking CHECK (start_date >= CURRENT_DATE)
) PARTITION BY RANGE (start_date);

-- Create partitions for different date ranges
-- Current year partitions (2025)
CREATE TABLE booking_2025_q1 PARTITION OF booking FOR
VALUES
FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE booking_2025_q2 PARTITION OF booking FOR
VALUES
FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE booking_2025_q3 PARTITION OF booking FOR
VALUES
FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE booking_2025_q4 PARTITION OF booking FOR
VALUES
FROM ('2025-10-01') TO ('2026-01-01');

-- Future year partitions (2026)
CREATE TABLE booking_2026_q1 PARTITION OF booking FOR
VALUES
FROM ('2026-01-01') TO ('2026-04-01');

CREATE TABLE booking_2026_q2 PARTITION OF booking FOR
VALUES
FROM ('2026-04-01') TO ('2026-07-01');

CREATE TABLE booking_2026_q3 PARTITION OF booking FOR
VALUES
FROM ('2026-07-01') TO ('2026-10-01');

CREATE TABLE booking_2026_q4 PARTITION OF booking FOR
VALUES
FROM ('2026-10-01') TO ('2027-01-01');

-- Future year partitions (2027)
CREATE TABLE booking_2027_q1 PARTITION OF booking FOR
VALUES
FROM ('2027-01-01') TO ('2027-04-01');

CREATE TABLE booking_2027_q2 PARTITION OF booking FOR
VALUES
FROM ('2027-04-01') TO ('2027-07-01');

-- Default partition for dates beyond defined ranges
CREATE TABLE booking_default PARTITION OF booking DEFAULT;

-- Restore data from backup
INSERT INTO booking SELECT * FROM booking_backup;

-- Drop backup table
DROP TABLE booking_backup;

-- Add start_date column to payment table
ALTER TABLE payment ADD COLUMN booking_start_date DATE;

-- Populate booking_start_date from booking table
UPDATE payment p
SET
    booking_start_date = b.start_date
FROM booking b
WHERE
    p.booking_id = b.booking_id;

-- Set NOT NULL constraint after population
ALTER TABLE payment ALTER COLUMN booking_start_date SET NOT NULL;

-- Recreate payment table foreign key constraint
ALTER TABLE payment DROP CONSTRAINT IF EXISTS fk_payment_booking;

ALTER TABLE payment
ADD CONSTRAINT fk_payment_booking FOREIGN KEY (
    booking_id,
    booking_start_date
) REFERENCES booking (booking_id, start_date) ON DELETE CASCADE;

-- Recreate indexes on partitioned table
CREATE INDEX idx_booking_partitioned_dates ON booking (
    property_id,
    start_date,
    end_date
);

CREATE INDEX idx_booking_partitioned_user ON booking (user_id, start_date);

CREATE INDEX idx_booking_partitioned_status ON booking (status, start_date);

-- Create indexes on individual partitions for better performance
DO $$
DECLARE
    partition_name text;
    partition_names text[] := ARRAY[
        'booking_2025_q1', 'booking_2025_q2', 'booking_2025_q3', 'booking_2025_q4',
        'booking_2026_q1', 'booking_2026_q2', 'booking_2026_q3', 'booking_2026_q4',
        'booking_2027_q1', 'booking_2027_q2', 'booking_default'
    ];
BEGIN
    FOREACH partition_name IN ARRAY partition_names
    LOOP
        -- Create property-specific indexes on each partition
        EXECUTE format('CREATE INDEX idx_%s_property_dates ON %I (property_id, start_date, end_date)',
                      partition_name, partition_name);
        
        -- Create user-specific indexes on each partition
        EXECUTE format('CREATE INDEX idx_%s_user_dates ON %I (user_id, start_date)',
                      partition_name, partition_name);
        
        -- Create status-specific indexes on each partition
        EXECUTE format('CREATE INDEX idx_%s_status ON %I (status, start_date)',
                      partition_name, partition_name);
    END LOOP;
END $$;

-- Recreate update trigger for partitioned table
CREATE TRIGGER update_booking_modtime
    BEFORE UPDATE ON booking
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Create function to automatically create new partitions
CREATE OR REPLACE FUNCTION create_booking_partition(start_date DATE)
RETURNS void AS $$
DECLARE
    partition_name text;
    start_date_str text;
    end_date_str text;
BEGIN
    -- Calculate partition name based on year and quarter
    partition_name := 'booking_' || EXTRACT(YEAR FROM start_date) || '_q' || EXTRACT(QUARTER FROM start_date);
    
    -- Calculate partition bounds
    start_date_str := DATE_TRUNC('quarter', start_date)::text;
    end_date_str := (DATE_TRUNC('quarter', start_date) + INTERVAL '3 months')::text;
    
    -- Create partition if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_class 
        WHERE relname = partition_name 
        AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ) THEN
        EXECUTE format('CREATE TABLE %I PARTITION OF booking FOR VALUES FROM (%L) TO (%L)',
                      partition_name, start_date_str, end_date_str);
        
        -- Create indexes on new partition
        EXECUTE format('CREATE INDEX idx_%s_property_dates ON %I (property_id, start_date, end_date)',
                      partition_name, partition_name);
        EXECUTE format('CREATE INDEX idx_%s_user_dates ON %I (user_id, start_date)',
                      partition_name, partition_name);
        EXECUTE format('CREATE INDEX idx_%s_status ON %I (status, start_date)',
                      partition_name, partition_name);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to automatically create partitions on insert
CREATE OR REPLACE FUNCTION booking_partition_trigger()
RETURNS trigger AS $$
BEGIN
    PERFORM create_booking_partition(NEW.start_date);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic partition creation
CREATE TRIGGER booking_auto_partition_trigger
    BEFORE INSERT ON booking
    FOR EACH ROW EXECUTE FUNCTION booking_partition_trigger();

-- Create maintenance function to drop old partitions
CREATE OR REPLACE FUNCTION cleanup_old_booking_partitions(months_to_keep INTEGER DEFAULT 24)
RETURNS void AS $$
DECLARE
    partition_record RECORD;
    cutoff_date DATE;
BEGIN
    cutoff_date := CURRENT_DATE - INTERVAL '1 month' * months_to_keep;
    
    FOR partition_record IN
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE tablename LIKE 'booking_20%'
        AND tablename != 'booking_default'
        AND schemaname = 'public'
    LOOP
        -- Extract date from partition name and check if it's old enough
        IF (SUBSTRING(partition_record.tablename FROM 'booking_(\d{4})_q(\d)')::text)::date < cutoff_date THEN
            EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', partition_record.tablename);
            RAISE NOTICE 'Dropped old partition: %', partition_record.tablename;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Add table comments for documentation
COMMENT ON TABLE booking IS 'Partitioned booking table by start_date for improved query performance';

COMMENT ON FUNCTION create_booking_partition (DATE) IS 'Automatically creates quarterly partitions for booking table';

COMMENT ON FUNCTION cleanup_old_booking_partitions (INTEGER) IS 'Removes old booking partitions to manage storage';

-- Performance testing queries
-- Query 1: Get bookings for a specific date range (should use partition pruning)
EXPLAIN (
    ANALYZE,
    BUFFERS
)
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, b.status
FROM booking b
WHERE
    b.start_date >= '2025-07-01'
    AND b.start_date < '2025-10-01'
ORDER BY b.start_date;

-- Query 2: Get bookings for a specific property in a date range
EXPLAIN (
    ANALYZE,
    BUFFERS
)
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, b.status
FROM booking b
WHERE
    b.property_id = 'c1d2e3f4-95a6-7890-cdef-345678901001'
    AND b.start_date >= '2025-07-01'
    AND b.start_date < '2025-10-01'
ORDER BY b.start_date;

-- Query 3: Aggregate bookings by status and month
EXPLAIN (
    ANALYZE,
    BUFFERS
)
SELECT
    DATE_TRUNC('month', start_date) as booking_month,
    status,
    COUNT(*) as booking_count,
    SUM(total_price) as total_revenue
FROM booking
WHERE
    start_date >= '2025-01-01'
    AND start_date < '2026-01-01'
GROUP BY
    DATE_TRUNC('month', start_date),
    status
ORDER BY booking_month, status;

-- Show partition information
SELECT
    pt.schemaname,
    pt.tablename as partition_name,
    pg_size_pretty(
        pg_total_relation_size(
            pt.schemaname || '.' || pt.tablename
        )
    ) as size,
    (
        SELECT COUNT(*)
        FROM booking
        WHERE
            tableoid = (
                pt.schemaname || '.' || pt.tablename
            )::regclass
    ) as row_count
FROM pg_tables pt
WHERE
    pt.tablename LIKE 'booking_%'
ORDER BY pt.tablename;

COMMIT;

-- Final verification queries
SELECT 'Partitioning setup completed successfully' as status;

SELECT COUNT(*) as total_bookings FROM booking;

SELECT schemaname, tablename, pg_size_pretty(
        pg_total_relation_size(
            schemaname || '.' || tablename
        )
    ) as size
FROM pg_tables
WHERE
    tablename LIKE 'booking_%'
ORDER BY tablename;