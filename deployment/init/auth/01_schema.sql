CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION CURRENT_USER;

-- Roles
CREATE TABLE IF NOT EXISTS auth.roles (
                                          role_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL UNIQUE,
    description TEXT
    );

-- Users
CREATE TABLE IF NOT EXISTS auth.users (
                                          user_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    email       CITEXT NOT NULL UNIQUE,
    national_id TEXT UNIQUE,
    phone       TEXT,
    role_id     UUID REFERENCES auth.roles(role_id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
    base_salary NUMERIC(14,2) CHECK (base_salary IS NULL OR base_salary >= 0),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
    );

CREATE INDEX IF NOT EXISTS idx_users_role ON auth.users (role_id);

-- Privileges (optional if you run as auth_be_user)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'auth_be_user') THEN
    GRANT USAGE ON SCHEMA auth TO auth_be_user;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA auth TO auth_be_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth
      GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO auth_be_user;
END IF;
END$$;
