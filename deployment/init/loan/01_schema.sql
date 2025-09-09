-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;   -- case-insensitive email

-- Schema
CREATE SCHEMA IF NOT EXISTS loan AUTHORIZATION CURRENT_USER;

-- Status catalog
CREATE TABLE IF NOT EXISTS loan.statuses (
                                             status_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL UNIQUE,
    description TEXT
    );

-- Loan types catalog
CREATE TABLE IF NOT EXISTS loan.loan_types (
                                               loan_type_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name               TEXT NOT NULL UNIQUE,
    min_amount         NUMERIC(14,2) NOT NULL CHECK (min_amount >= 0),
    max_amount         NUMERIC(14,2) NOT NULL CHECK (max_amount >= min_amount),
    interest_rate      NUMERIC(5,2)  NOT NULL CHECK (interest_rate >= 0),
    auto_validation    BOOLEAN NOT NULL DEFAULT false
    );

-- Loan applications
CREATE TABLE IF NOT EXISTS loan.loan_applications (
                                                      application_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount         NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    term_months    INTEGER NOT NULL CHECK (term_months > 0),
    email          CITEXT NOT NULL,
    status_id      UUID NOT NULL,
    loan_type_id   UUID NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_application_status
    FOREIGN KEY (status_id) REFERENCES loan.statuses(status_id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT fk_application_type
    FOREIGN KEY (loan_type_id) REFERENCES loan.loan_types(loan_type_id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
    );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_loan_applications_email ON loan.loan_applications (email);
CREATE INDEX IF NOT EXISTS idx_loan_applications_status ON loan.loan_applications (status_id);
CREATE INDEX IF NOT EXISTS idx_loan_applications_type   ON loan.loan_applications (loan_type_id);

-- Privileges (optional if you run as application_be_user)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'application_be_user') THEN
    GRANT USAGE ON SCHEMA loan TO application_be_user;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA loan TO application_be_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA loan
      GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO application_be_user;
END IF;
END$$;
