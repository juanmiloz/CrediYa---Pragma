INSERT INTO auth.roles (name, description) VALUES
                                               ('ADMIN',    'System administrator'),
                                               ('CUSTOMER', 'End customer'),
                                               ('ADVISOR',  'Loan advisor')
ON CONFLICT (name) DO NOTHING;

WITH roles_map AS (
    SELECT 'ADMIN'    AS role_name, role_id FROM auth.roles WHERE name = 'ADMIN'
    UNION ALL
    SELECT 'CUSTOMER' AS role_name, role_id FROM auth.roles WHERE name = 'CUSTOMER'
    UNION ALL
    SELECT 'ADVISOR'  AS role_name, role_id FROM auth.roles WHERE name = 'ADVISOR'
),
     seed AS (
         SELECT * FROM (VALUES
                            -- Tu usuario admin
                            ('Juan Camilo','Zorrilla Calvache','juanmiloz@hotmail.com','1006050024','3107115055','ADMIN',   2000),

                            -- Ejemplos (parecen reales)
                            ('James',      'Rodríguez',        'james.rodriguez@felixvita.co',   '1010000001','3001234567','CUSTOMER', NULL),
                            ('Luis',       'Díaz',             'luis.diaz@felixvita.co',         '1010000002','3007654321','CUSTOMER', NULL),
                            ('Juan',       'Cuadrado',         'juan.cuadrado@felixvita.co',     '1010000003','3012345678','ADVISOR',  4200),
                            ('David',      'Ospina',           'david.ospina@felixvita.co',      '1010000004','3018765432','CUSTOMER', NULL),
                            ('Yerry',      'Mina',             'yerry.mina@felixvita.co',        '1010000005','3023456789','ADVISOR',  3800),
                            ('Rafael Santos','Borré',          'rafael.borre@felixvita.co',      '1010000006','3029876543','CUSTOMER', NULL),
                            ('Jefferson',  'Lerma',            'jefferson.lerma@felixvita.co',   '1010000007','3031239876','CUSTOMER', NULL),
                            ('Davinson',   'Sánchez',          'davinson.sanchez@felixvita.co',  '1010000008','3039873210','ADVISOR',  3600),
                            ('Jhon',       'Arias',            'jhon.arias@felixvita.co',        '1010000009','3041231234','CUSTOMER', NULL),
                            ('Daniel',     'Muñoz',            'daniel.munoz@felixvita.co',      '1010000010','3049879876','CUSTOMER', NULL)
                       ) AS v(first_name,last_name,email,national_id,phone,role_name,base_salary)
     )
INSERT INTO auth.users (first_name, last_name, email, national_id, phone, role_id, base_salary)
SELECT s.first_name, s.last_name, s.email, s.national_id, s.phone, r.role_id, s.base_salary
FROM seed s
         JOIN roles_map r USING (role_name)
ON CONFLICT (email) DO UPDATE
    SET first_name  = EXCLUDED.first_name,
        last_name   = EXCLUDED.last_name,
        national_id = EXCLUDED.national_id,
        phone       = EXCLUDED.phone,
        role_id     = EXCLUDED.role_id,
        base_salary = EXCLUDED.base_salary;
