SET check_function_bodies = false;
SET search_path = public, pg_catalog;
CREATE TYPE public.enum_gender AS ENUM (
  'M', 'F'
);
--
-- Structure for table users (OID = 10229872) :
--
CREATE TABLE public.users (
    id bigserial NOT NULL,
    login varchar(255) NOT NULL,
    password text NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT now(),
    birth_date date,
    first_name text,
    last_name text,
    middle_name text,
    email varchar(255),
    phone varchar(11),
    gender enum_gender,
    avatar bytea
)
WITH (oids = false);
--
-- Structure for table roles (OID = 10229883) :
--
CREATE TABLE public.roles (
    code varchar(255) NOT NULL,
    name text NOT NULL,
    start_at date,
    expire_at date,
    id integer DEFAULT nextval(('public.roles_id_seq'::text)::regclass) NOT NULL
)
WITH (oids = false);
--
-- Structure for table r_function (OID = 10229891) :
--
CREATE TABLE public.r_function (
    code varchar(255) NOT NULL,
    name text NOT NULL,
    id integer NOT NULL
)
WITH (oids = false);
--
-- Structure for table mtm_user2role (OID = 10229899) :
--
CREATE TABLE public.mtm_user2role (
    user_id bigint NOT NULL,
    role_id integer NOT NULL
)
WITH (oids = false);
--
-- Definition for sequence roles_id_seq (OID = 10229918) :
--
CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;
--
-- Structure for table orders (OID = 10229940) :
--
CREATE TABLE public.orders (
    id bigserial NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    client_id bigint NOT NULL,
    departure_address text,
    destination_address text,
    state_id integer,
    transport_id integer,
    operator_id bigint,
    activated_at timestamp(0) without time zone,
    transport_class_id integer
)
WITH (oids = false);
ALTER TABLE ONLY public.orders ALTER COLUMN transport_id SET STATISTICS 0;
--
-- Structure for table r_order_status (OID = 10229960) :
--
CREATE TABLE public.r_order_status (
    id integer NOT NULL,
    name text NOT NULL
)
WITH (oids = false);
--
-- Structure for table mtm_role2function (OID = 10229973) :
--
CREATE TABLE public.mtm_role2function (
    role_id integer NOT NULL,
    function_id integer NOT NULL
)
WITH (oids = false);
ALTER TABLE ONLY public.mtm_role2function ALTER COLUMN function_id SET STATISTICS 0;
--
-- Structure for table vehicle (OID = 10229991) :
--
CREATE TABLE public.vehicle (
    id bigserial NOT NULL,
    brand_id integer NOT NULL,
    model text NOT NULL,
    production_year integer NOT NULL,
    registration_no varchar(15) NOT NULL,
    registration_date date NOT NULL,
    decomission_date date,
    vehicle_class_id integer DEFAULT 1 NOT NULL
)
WITH (oids = false);
--
-- Structure for table vehicle_brand (OID = 10230002) :
--
CREATE TABLE public.vehicle_brand (
    id serial NOT NULL,
    name text NOT NULL
)
WITH (oids = false);
--
-- Structure for table vehicle_images (OID = 10230018) :
--
CREATE TABLE public.vehicle_images (
    id bigserial NOT NULL,
    vehicle_id bigint NOT NULL,
    image bytea
)
WITH (oids = false);
--
-- Structure for table r_vehicle_class (OID = 10230051) :
--
CREATE TABLE public.r_vehicle_class (
    id integer NOT NULL,
    name text NOT NULL
)
WITH (oids = false);
--
-- Data for table public.users (OID = 10229872) (LIMIT 0,2)
--
INSERT INTO users (id, login, password, created_at, updated_at, birth_date, first_name, last_name, middle_name, email, phone, gender, avatar)
VALUES (1, 'admin', '$2a$12$ONULJMSH77oWf3Cscu8g4O8yiD9vHbsMAUrg2uvzOiVZJu5ihWBXi', '2020-07-30 14:21:26', '2020-07-30 14:21:26', NULL, '', '', '', NULL, '', 'M', NULL);

INSERT INTO users (id, login, password, created_at, updated_at, birth_date, first_name, last_name, middle_name, email, phone, gender, avatar)
VALUES (7, 'operator', '$2a$12$o0EsnADcbItwUoRlHAeTtuzeZOj.of4MVfnXEBRxH2N3Ry1tTLJhO', '2020-07-31 08:33:59', '2020-07-31 08:33:59', NULL, '', '', NULL, NULL, NULL, 'F', NULL);

--
-- Data for table public.roles (OID = 10229883) (LIMIT 0,2)
--
INSERT INTO roles (code, name, start_at, expire_at, id)
VALUES ('GOD', 'God', NULL, NULL, 1);

INSERT INTO roles (code, name, start_at, expire_at, id)
VALUES ('operator', 'Operator', NULL, NULL, 3);

--
-- Data for table public.r_function (OID = 10229891) (LIMIT 0,5)
--
INSERT INTO r_function (code, name, id)
VALUES ('EDIT_PROFILE', 'Редактирование профиля', 1);

INSERT INTO r_function (code, name, id)
VALUES ('USER_MANAGEMENT', 'Управление пользователями', 3);

INSERT INTO r_function (code, name, id)
VALUES ('ROLE_MANAGEMENT', 'Управление ролями', 4);

INSERT INTO r_function (code, name, id)
VALUES ('ORDER_MANAGEMENT', 'Управление заказами', 5);

INSERT INTO r_function (code, name, id)
VALUES ('VEHICLE_MANAGEMENT', 'Управление транспортом', 6);

--
-- Data for table public.mtm_user2role (OID = 10229899) (LIMIT 0,1)
--
INSERT INTO mtm_user2role (user_id, role_id)
VALUES (1, 1);

INSERT INTO mtm_user2role (user_id, role_id)
VALUES (7, 3);
--
-- Data for table public.r_order_status (OID = 10229960) (LIMIT 0,5)
--
INSERT INTO r_order_status (id, name)
VALUES (1, 'Создан');

INSERT INTO r_order_status (id, name)
VALUES (2, 'Исполняется');

INSERT INTO r_order_status (id, name)
VALUES (3, 'Отменен');

INSERT INTO r_order_status (id, name)
VALUES (4, 'Выполнен');

INSERT INTO r_order_status (id, name)
VALUES (5, 'Завершен');

--
-- Data for table public.mtm_role2function (OID = 10229973) (LIMIT 0,8)
--
INSERT INTO mtm_role2function (role_id, function_id)
VALUES (1, 1);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (1, 3);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (1, 4);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (1, 5);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (1, 6);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (3, 1);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (3, 5);

INSERT INTO mtm_role2function (role_id, function_id)
VALUES (3, 6);

--
-- Data for table public.vehicle (OID = 10229991) (LIMIT 0,14)
--
INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (6, 2, 'Camry', 2020, 'ABV 992-123-922', '2020-07-31', NULL, 2);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (7, 2, 'Cruiser', 2020, 'ABV 992-123-923', '2020-07-31', NULL, 3);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (8, 3, 'Grumman', 2020, 'ABV 992-123-931', '2020-07-31', NULL, 1);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (9, 3, 'B-52', 2020, 'ABV 992-123-932', '2020-07-31', NULL, 2);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (10, 3, 'B1', 2020, 'ABV 992-123-933', '2020-07-31', NULL, 3);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (11, 4, 'A-320', 2020, 'ABV 992-123-941', '2020-07-31', NULL, 1);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (12, 4, 'A-340', 2020, 'ABV 992-123-942', '2020-07-31', NULL, 2);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (13, 4, 'A-380', 2020, 'ABV 992-123-943', '2020-07-31', NULL, 3);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (3, 1, 'Mavic', 2020, 'ABV 992-123-912', '2020-07-31', NULL, 2);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (4, 1, 'Mavic Pro', 2020, 'ABV 992-123-913', '2020-07-31', NULL, 3);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (1, 2, 'Phantom ', 2020, 'ABV 992-123-983', '2020-07-21', NULL, 2);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (5, 2, 'fsdf', 2020, 'ABV 992-123-921', '2020-07-31', '2020-07-31', 1);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (14, 2, 'Corolla', 2010, 'ABV 992-123-983', '2020-07-01', NULL, 1);

INSERT INTO vehicle (id, brand_id, model, production_year, registration_no, registration_date, decomission_date, vehicle_class_id)
VALUES (15, 4, 'A-321 neo', 2019, 'AAA 123-321-548', '2020-07-01', NULL, 1);

--
-- Data for table public.vehicle_brand (OID = 10230002) (LIMIT 0,4)
--
INSERT INTO vehicle_brand (id, name)
VALUES (1, 'DJI');

INSERT INTO vehicle_brand (id, name)
VALUES (2, 'Toyota');

INSERT INTO vehicle_brand (id, name)
VALUES (3, 'Northrop');

INSERT INTO vehicle_brand (id, name)
VALUES (4, 'Airbus');

--
-- Data for table public.r_vehicle_class (OID = 10230051) (LIMIT 0,3)
--
INSERT INTO r_vehicle_class (id, name)
VALUES (1, 'Эконом');

INSERT INTO r_vehicle_class (id, name)
VALUES (2, 'Бизнес');

INSERT INTO r_vehicle_class (id, name)
VALUES (3, 'Премиум');

--
-- Definition for index users_pkey (OID = 10229879) :
--
ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey
    PRIMARY KEY (id);
--
-- Definition for index mtm_user2role_pkey (OID = 10229902) :
--
ALTER TABLE ONLY mtm_user2role
    ADD CONSTRAINT mtm_user2role_pkey
    PRIMARY KEY (user_id, role_id);
--
-- Definition for index r_function_pkey (OID = 10229909) :
--
ALTER TABLE ONLY r_function
    ADD CONSTRAINT r_function_pkey
    PRIMARY KEY (id);
--
-- Definition for index roles_pkey (OID = 10229920) :
--
ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey
    PRIMARY KEY (id);
--
-- Definition for index mtm_user2role_fk (OID = 10229923) :
--
ALTER TABLE ONLY mtm_user2role
    ADD CONSTRAINT mtm_user2role_fk
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
--
-- Definition for index orders_pkey (OID = 10229948) :
--
ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey
    PRIMARY KEY (id);
--
-- Definition for index orders_client_fk (OID = 10229950) :
--
ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_client_fk
    FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE;
--
-- Definition for index orders_operator_fk (OID = 10229955) :
--
ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_operator_fk
    FOREIGN KEY (operator_id) REFERENCES users(id) ON DELETE CASCADE;
--
-- Definition for index r_order_status_pkey (OID = 10229966) :
--
ALTER TABLE ONLY r_order_status
    ADD CONSTRAINT r_order_status_pkey
    PRIMARY KEY (id);
--
-- Definition for index orders_state_fk (OID = 10229968) :
--
ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_state_fk
    FOREIGN KEY (state_id) REFERENCES r_order_status(id) ON DELETE CASCADE;
--
-- Definition for index mtm_role2function_pk (OID = 10229976) :
--
ALTER TABLE ONLY mtm_role2function
    ADD CONSTRAINT mtm_role2function_pk
    PRIMARY KEY (function_id, role_id);
--
-- Definition for index mtm_role2function_fk (OID = 10229979) :
--
ALTER TABLE ONLY mtm_role2function
    ADD CONSTRAINT mtm_role2function_fk
    FOREIGN KEY (role_id) REFERENCES roles(id);
--
-- Definition for index mtm_role2function_fk1 (OID = 10229984) :
--
ALTER TABLE ONLY mtm_role2function
    ADD CONSTRAINT mtm_role2function_fk1
    FOREIGN KEY (function_id) REFERENCES r_function(id);
--
-- Definition for index vehicle_pkey (OID = 10229998) :
--
ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_pkey
    PRIMARY KEY (id);
--
-- Definition for index vehicle_brand_pkey (OID = 10230009) :
--
ALTER TABLE ONLY vehicle_brand
    ADD CONSTRAINT vehicle_brand_pkey
    PRIMARY KEY (id);
--
-- Definition for index vehicle_brand_fk (OID = 10230011) :
--
ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_brand_fk
    FOREIGN KEY (brand_id) REFERENCES vehicle_brand(id) ON DELETE CASCADE;
--
-- Definition for index vehicle_images_pkey (OID = 10230025) :
--
ALTER TABLE ONLY vehicle_images
    ADD CONSTRAINT vehicle_images_pkey
    PRIMARY KEY (id);
--
-- Definition for index vehicle_images_vehicle_fk (OID = 10230027) :
--
ALTER TABLE ONLY vehicle_images
    ADD CONSTRAINT vehicle_images_vehicle_fk
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id) ON DELETE CASCADE;
--
-- Definition for index users_login_key (OID = 10230032) :
--
ALTER TABLE ONLY users
    ADD CONSTRAINT users_login_key
    UNIQUE (login);
--
-- Definition for index r_vehicle_class_pkey (OID = 10230057) :
--
ALTER TABLE ONLY r_vehicle_class
    ADD CONSTRAINT r_vehicle_class_pkey
    PRIMARY KEY (id);
--
-- Data for sequence public.users_id_seq (OID = 10229870)
--
SELECT pg_catalog.setval('users_id_seq', 7, true);
--
-- Data for sequence public.r_function_id_seq (OID = 10229906)
--
SELECT pg_catalog.setval('r_function_id_seq', 6, true);
--
-- Data for sequence public.roles_id_seq (OID = 10229918)
--
SELECT pg_catalog.setval('roles_id_seq', 3, true);
--
-- Data for sequence public.orders_id_seq (OID = 10229938)
--
SELECT pg_catalog.setval('orders_id_seq', 15, true);
--
-- Data for sequence public.transport_id_seq (OID = 10229989)
--
SELECT pg_catalog.setval('transport_id_seq', 15, true);
--
-- Data for sequence public.vehicle_brand_id_seq (OID = 10230000)
--
SELECT pg_catalog.setval('vehicle_brand_id_seq', 4, true);
--
-- Data for sequence public.vehicle_images_id_seq (OID = 10230016)
--
SELECT pg_catalog.setval('vehicle_images_id_seq', 1, false);
--
-- Comments
--
COMMENT ON SCHEMA public IS 'standard public schema';
COMMENT ON COLUMN public.users.id IS 'Синтетический ключ таблицы "Пользователи"';
COMMENT ON COLUMN public.users.login IS 'Логин пользователя';
COMMENT ON COLUMN public.users.password IS 'Хешированный пароль пользователя';
COMMENT ON COLUMN public.users.created_at IS 'Дата и время создания';
COMMENT ON COLUMN public.users.updated_at IS 'Дата и время последнего обновления';
COMMENT ON COLUMN public.users.birth_date IS 'Дата рождения';
COMMENT ON COLUMN public.users.first_name IS 'Имя';
COMMENT ON COLUMN public.users.last_name IS 'Фамилия';
COMMENT ON COLUMN public.users.middle_name IS 'Отчество';
COMMENT ON COLUMN public.users.phone IS 'Телефон';
COMMENT ON COLUMN public.users.gender IS 'Пол пользователя. M - мужской пол, F - женский';
COMMENT ON COLUMN public.users.avatar IS 'Фото или аватарка пользователя';
COMMENT ON COLUMN public.roles.code IS 'Уникальный код роли (системное имя)';
COMMENT ON COLUMN public.roles.name IS 'Наименование роли';
COMMENT ON COLUMN public.roles.start_at IS 'Дата начала действия';
COMMENT ON COLUMN public.roles.expire_at IS 'Завершение срока действия роли';
COMMENT ON COLUMN public.roles.id IS 'Синтетический ключ таблицы';
COMMENT ON TABLE public.r_function IS 'Статический справочник системных функций';
COMMENT ON COLUMN public.r_function.code IS 'Системный код функции';
COMMENT ON COLUMN public.r_function.name IS 'Наименование';
COMMENT ON COLUMN public.r_function.id IS 'Синтетический (ссылочный) ключ таблицы';
COMMENT ON TABLE public.orders IS 'Заказы';
COMMENT ON COLUMN public.orders.id IS 'Автоматически-генерируемый номер заказа';
COMMENT ON COLUMN public.orders.created_at IS 'Дата и время создания записи';
COMMENT ON COLUMN public.orders.client_id IS 'Идентификатор пользователя-заказчика';
COMMENT ON COLUMN public.orders.departure_address IS 'Адрес точки отправления';
COMMENT ON COLUMN public.orders.destination_address IS 'Адрес назначения';
COMMENT ON COLUMN public.orders.state_id IS 'Состояние заказа (ссылка на справочник)';
COMMENT ON COLUMN public.orders.transport_id IS 'Ссылка на выделенный для исполнения заказа транспорт';
COMMENT ON COLUMN public.orders.operator_id IS 'Ссылка на оператора, который принял заказ (таблица users)';
COMMENT ON COLUMN public.orders.activated_at IS 'Дата и время принятия заказа и перевода в статус "Активен"';
COMMENT ON COLUMN public.orders.transport_class_id IS 'Выбранный класс транспорта';
COMMENT ON TABLE public.r_order_status IS 'Справочник статусов заказа';
COMMENT ON COLUMN public.r_order_status.id IS 'Синтетический ключ таблицы';
COMMENT ON COLUMN public.r_order_status.name IS 'Расшифровка статуса заказа';
COMMENT ON TABLE public.mtm_role2function IS 'Таблица-ассоциация для связи ролей и функций';
COMMENT ON COLUMN public.mtm_role2function.role_id IS 'Ссылка на роль';
COMMENT ON COLUMN public.mtm_role2function.function_id IS 'Ссылка на функцию';
COMMENT ON TABLE public.vehicle IS 'Реестр транспортных единиц (дронов)';
COMMENT ON COLUMN public.vehicle.id IS 'Синтетический ключ таблицы';
COMMENT ON COLUMN public.vehicle.brand_id IS 'Ссылка на производителя (vehicle_brand)';
COMMENT ON COLUMN public.vehicle.model IS 'Наименование модели';
COMMENT ON COLUMN public.vehicle.production_year IS 'Год производства';
COMMENT ON COLUMN public.vehicle.registration_no IS 'Регистрационный номер (пример: ABV 992-123-983)';
COMMENT ON COLUMN public.vehicle.registration_date IS 'Дата регистрации';
COMMENT ON COLUMN public.vehicle.decomission_date IS 'Дата списания';
COMMENT ON COLUMN public.vehicle.vehicle_class_id IS 'Класс дрона';
COMMENT ON TABLE public.vehicle_brand IS 'Марки дронов (производители)';
COMMENT ON COLUMN public.vehicle_brand.id IS 'Синтетический ключ таблицы';
COMMENT ON COLUMN public.vehicle_brand.name IS 'Наименование производителя';
COMMENT ON TABLE public.vehicle_images IS 'Изображения дронов';
COMMENT ON COLUMN public.vehicle_images.id IS 'Синтетический ключ таблицы';
COMMENT ON COLUMN public.vehicle_images.vehicle_id IS 'Ссылка на таблицу vehicle';
COMMENT ON COLUMN public.vehicle_images.image IS 'Изображение';
COMMENT ON TYPE enum_gender IS 'M - Мужской
F - Женский';