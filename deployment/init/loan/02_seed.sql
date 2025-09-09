INSERT INTO loan.statuses (name, description)
VALUES ('PENDING', 'Application created, under review'),
       ('APPROVED', 'Application approved'),
       ('REJECTED', 'Application rejected') ON CONFLICT (name) DO NOTHING;

INSERT INTO loan.loan_types (name, min_amount, max_amount, interest_rate, auto_validation)
VALUES ('Personal', 100000, 50000000, 18.50, true),
       ('Free Investment', 500000, 100000000, 22.00, false) ON CONFLICT (name) DO NOTHING;
