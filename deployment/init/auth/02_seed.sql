INSERT INTO auth.roles (name, description)
VALUES ('ADMIN', 'System administrator'),
       ('OPERATOR', 'Loan applications operator') ON CONFLICT (name) DO NOTHING;

INSERT INTO auth.users (first_name, last_name, email, national_id, phone, role_id, base_salary)
SELECT 'Admin', 'System', 'admin@felixvita.co', '00000000', '3000000000', r.role_id, 0
FROM auth.roles r
WHERE r.name = 'ADMIN' ON CONFLICT (email) DO NOTHING;
