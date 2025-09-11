INSERT INTO loan.statuses (name, description)
VALUES ('PENDING', 'Application created, under review'),
       ('APPROVED', 'Application approved'),
       ('REJECTED', 'Application rejected')
ON CONFLICT (name) DO NOTHING;

INSERT INTO loan.loan_types (name, min_amount, max_amount, interest_rate, auto_validation)
VALUES ('Personal', 500.00, 20000.00, 17.99, true),
       ('Auto', 5000.00, 60000.00, 9.90, true),
       ('Education', 1000.00, 50000.00, 6.75, false),
       ('Small Business', 10000.00, 150000.00, 12.50, false),
       ('Mortgage', 50000.00, 500000.00, 7.25, false)
ON CONFLICT (name) DO UPDATE
    SET min_amount      = EXCLUDED.min_amount,
        max_amount      = EXCLUDED.max_amount,
        interest_rate   = EXCLUDED.interest_rate,
        auto_validation = EXCLUDED.auto_validation;

WITH status_map AS (SELECT name, status_id FROM loan.statuses WHERE name IN ('PENDING', 'APPROVED', 'REJECTED')),
     type_map AS (SELECT name, loan_type_id, min_amount, max_amount
                  FROM loan.loan_types
                  WHERE name IN ('Personal', 'Auto', 'Education', 'Small Business', 'Mortgage')),
     seed AS (SELECT *
              FROM (VALUES
                        ('juanmiloz@hotmail.com', 'Personal', 5000.00, 36, 'APPROVED'),
                        ('james.rodriguez@felixvita.co', 'Auto', 28000.00, 48, 'PENDING'),
                        ('luis.diaz@felixvita.co', 'Personal', 12000.00, 36, 'APPROVED'),
                        ('juan.cuadrado@felixvita.co', 'Small Business', 80000.00, 60, 'REJECTED'),
                        ('david.ospina@felixvita.co', 'Mortgage', 220000.00, 240, 'APPROVED'),
                        ('yerry.mina@felixvita.co', 'Auto', 40000.00, 60, 'PENDING'),
                        ('rafael.borre@felixvita.co', 'Personal', 5500.00, 24, 'REJECTED'),
                        ('jefferson.lerma@felixvita.co', 'Education', 18000.00, 48, 'APPROVED'),
                        ('davinson.sanchez@felixvita.co', 'Mortgage', 150000.00, 180, 'PENDING'),
                        ('jhon.arias@felixvita.co', 'Personal', 3000.00, 18, 'APPROVED'),
                        ('daniel.munoz@felixvita.co', 'Education', 8000.00, 36,
                         'PENDING')) AS v(email, loan_type_name, amount, term_months, status_name))
INSERT
INTO loan.loan_applications (amount, term_months, email, status_id, loan_type_id)
SELECT s.amount, s.term_months, s.email, sm.status_id, tm.loan_type_id
FROM seed s
         JOIN status_map sm ON sm.name = s.status_name
         JOIN type_map tm ON tm.name = s.loan_type_name
WHERE s.amount BETWEEN tm.min_amount AND tm.max_amount
  AND NOT EXISTS (SELECT 1
                  FROM loan.loan_applications la
                  WHERE la.email = s.email
                    AND la.amount = s.amount
                    AND la.term_months = s.term_months
                    AND la.loan_type_id = tm.loan_type_id);
