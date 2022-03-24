CREATE
EXTENSION cube;
CREATE
EXTENSION earthdistance;

CREATE TABLE order_statuses
(
    id          INT PRIMARY KEY,
    description VARCHAR
);

CREATE TABLE types
(
    id         UUID PRIMARY KEY   DEFAULT gen_random_uuid(),
    name       varchar   NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

CREATE TABLE categories
(
    id          INT PRIMARY KEY,
    description VARCHAR
);

CREATE TABLE delivery_types
(
    id          INT PRIMARY KEY,
    description VARCHAR
);

CREATE TABLE payment_types
(
    id          INT PRIMARY KEY,
    description VARCHAR
);

CREATE TABLE restaurants
(
    id              UUID PRIMARY KEY   DEFAULT gen_random_uuid(),
    title           varchar   NOT NULL,
    rating          DECIMAL,
    medium_price    DECIMAL,
    user_id         INT       NOT NULL,
    address         varchar,
    image           varchar,
    time_work_start time without time zone,
    time_work_end   time without time zone,
    is_active       bool,
    number          numeric,
    email           varchar,
    description     varchar,
    created_at      TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
    latitude        DECIMAL,
    longitude       DECIMAL
);

CREATE TABLE location
(
    restaurant_id UUID references restaurants (id) on delete cascade NOT NULL,
    latitude      varchar                                            NOT NULL,
    longitude     varchar                                            NOT NULL
);

CREATE TABLE dishes
(
    id            UUID PRIMARY KEY                                   NOT NULL DEFAULT gen_random_uuid(),
    restaurant_id UUID references restaurants (id) on delete cascade NOT NULL,
    type          UUID references types (id)                         NOT NULL,
    cost          DECIMAL                                            NOT NULL,
    name          varchar                                            NOT NULL,
    cooking_time  integer,
    image         varchar,
    weight        DECIMAL,
    description   varchar,
    status        varchar                                            NOT NULL DEFAULT 'available',
    created_at    TIMESTAMP                                          NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
        CONSTRAINT check_status CHECK ( status IN ('available', 'unavailable') )
);

CREATE TABLE orders
(
    id                  UUID PRIMARY KEY                                   NOT NULL,
    row_id              SERIAL                                             NOT NULL unique,
    restaurant_id       UUID references restaurants (id) on delete cascade NOT NULL,
    cost                DECIMAL,
    delivery_time       timestamp                                          NOT NULL,
    client_full_name    VARCHAR                                            NOT NULL,
    client_phone_number TEXT                                               NOT NULL,
    address             VARCHAR                                            NOT NULL,
    delivery_type       INT references delivery_types (id),
    payment_type        INT                                                NOT NULL DEFAULT 1,
    courier_service     INT,
    status              INT REFERENCES order_statuses (id)                 NOT NULL DEFAULT 1,
    view_status         BOOLEAN                                                     DEFAULT FALSE,
    created_at          TIMESTAMP                                          NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

CREATE TABLE feedbacks
(
    id            UUID PRIMARY KEY                                   NOT NULL DEFAULT gen_random_uuid(),
    restaurant_id UUID references restaurants (id) on delete cascade NOT NULL,
    order_id      UUID references orders (id) on delete cascade      NOT NULL,
    feedback      VARCHAR,
    rating        INTEGER
);

CREATE TABLE order_dishes
(
    id         UUID PRIMARY KEY                                       DEFAULT gen_random_uuid(),
    order_id   UUID REFERENCES orders (id) on delete cascade NOT NULL,
    dish_id    UUID REFERENCES dishes (id)                   NOT NULL,
    amount     integer                                       NOT NULL,
    rate       DECIMAL,
    created_at TIMESTAMP                                     NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

CREATE TABLE category_restaurants
(
    id            UUID PRIMARY KEY                                              DEFAULT gen_random_uuid(),
    category_id   integer REFERENCES categories (id) on delete cascade NOT NULL,
    restaurant_id UUID REFERENCES restaurants (id)                     NOT NULL,
    created_at    TIMESTAMP                                            NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

INSERT INTO payment_types(id, description)
VALUES (1, 'card'),
       (2, 'cash'),
       (3, 'card online');

INSERT INTO order_statuses(id, description)
VALUES (1, 'New'),
       (2, 'Canceled'),
       (3, 'In progress'),
       (4, 'Ready for delivery'),
       (5, 'Completed');

INSERT INTO delivery_types(id, description)
VALUES (1, 'Restaurant delivery'),
       (2, 'Service delivery');

INSERT INTO categories(id, description)
VALUES (1, 'Asian'),
       (2, 'Burgers'),
       (3, 'Breakfast'),
       (4, 'Pizza'),
       (5, 'Lunch'),
       (6, 'Fast-food'),
       (7, 'Dessert'),
       (8, 'Coffee'),
       (9, 'Steaks');

INSERT INTO restaurants (id, user_id, title, rating, medium_price, address, time_work_start,
                         time_work_end, is_active,
                         image, latitude, longitude, description)
VALUES ('01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b', 1, 'Meat & Fish', 8.5, 51.20, 'улица Кульман, 14к1, Минск',
        '08:00:00',
        '15:00:00', TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b/37de00e0-ceab-4dd9-843b-ce68e01e3159.jpg',
        53.921435397746784, 27.581316198274365,
        'Chain steakhouse and fish restaurant. The concept of the establishment is a harmonious combination of fish and meat dishes. The menu focuses on domestic grain-fed beef and seafood from Kamchatka, Yakutia and Murmansk.'),
       ('02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b', 1, 'KFC', 7.1, 15.00, 'улица Притыцкого, 101а, Минск', '09:00:00',
        '17:00:00', TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b/1ce759d9-2467-44e4-b9b2-591388e1cb80.png',
        53.906670487925986, 27.435194827109605,
        'Kentucky Fried Chicken, abbreviated as KFC, is an international chain of catering restaurants specializing in chicken dishes.'),
       ('03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b', 1, 'Burger KING', 6.5, 12.00, 'улица Притыцкого, 19а, Минск',
        '10:00:00',
        '18:00:00', TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b/7ade7bc2-1dfa-4fe1-86ab-272b2c4fe221.png',
        53.909390439793654, 27.496377398273868,
        'Burger King Corporation is an American company that owns the Burger King global fast food chain specializing in hamburgers.'),
       ('04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b', 1, 'McDonald’s', 9, 11.20, 'улица Притыцкого 28, Минск', '08:00:00',
        '23:00:00', TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b/02013725-971f-4a58-b375-ebc0c66b7765.png',
        53.909390439793654, 27.496377398273868,
        'McDonald’s is an American corporation operating in the field of catering, the world''s largest chain of fast food restaurants.'),
       ('04fb44e3-5f18-41eb-80a1-d8b4e8a77f1b', 1, 'Dodo Pizza', 5, 25.00, 'ул. Романовская Слобода 8, Минск',
        '00:08:00',
        '00:00:00',
        TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/1738cc31-6075-4588-8efe-9a1c1a0f0ae4/0ab0fed5-75af-4ed4-94c4-a61ed2e100d5.jpg',
        53.902777, 27.547575,
        'Huge selection on the menu. The perfect combination of flavors and the thinnest dough is the key to delicious pizza. Delicious pizza delivery with the best ingredients.'),
       ('04fb44e3-5f18-41eb-80a1-d8b4e8a11f1b', 1, 'Domino’s Pizza', 5, 26.00, 'пр-т. Победителей 1, Минск', '00:08:00',
        '00:00:00',
        TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/1738cc31-6075-4588-8efe-9a1c1a0f0ae4/acf12143-ba1a-4f36-b712-6f31e460c8e3.png',
        53.905143, 27.552264,
        'Dominos Pizza is an American catering company. Operates the world''s largest chain of pizzerias.'),
       ('05fb44e3-3f18-43eb-82a1-d8b4e8a22f1b', 1, 'NEFT', 9.5, 60.00, 'улица Аранская 8, Минск', '00:00:00',
        '00:00:00',
        TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/05fb44e3-3f18-43eb-82a1-d8b4e8a22f1b/e7d9e569-5d51-4a7e-b39e-b79a0c89b6c3.jpg',
        53.885351410688884, 27.569866540601108,
        'The NEFT Lounge Restaurant is a unique establishment with a conceptual name, the main goal of which is to create a truly high-quality and atmospheric vacation. NEFT combines all the best from the restaurant and hookah industry: a high-quality menu thought out to the smallest detail, a high level of service and serving dishes, an individual approach to each guest, a perfectly matched hookah park and a huge selection of premium positions of tobacco-free nicotine-free blends, as well as a wide tea room map, which has more than fifty types of tea.'),
       ('06fb44e3-1f18-45eb-20a1-d8b4e8a22f1b', 1, 'KOKOS', 8, 45.00, 'улица Богдана Хмельницкого 4, Минск',
        '10:00:00',
        '18:00:00', TRUE,
        'https://onlineshop.fra1.digitaloceanspaces.com/06fb44e3-1f18-45eb-20a1-d8b4e8a22f1b/d42a1d19-bc13-41c9-9aed-5b9d6751aba2.jpg',
        53.922992038531554, 27.596746998274412, 'The atmosphere of real Asian cuisine is felt in the institution.');

INSERT INTO types (id, name)
VALUES ('11fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 'Steaks'),
       ('11fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 'Lunch'),
       ('11fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 'Salads'),
       ('11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 'Snacks'),

       ('22fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 'Burgers'),
       ('22fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 'Baskets'),
       ('22fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 'Chicken'),
       ('23fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 'Sauce'),

       ('33fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 'Beef burgers'),
       ('33fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 'Chicken burgers'),
       ('33fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 'Fish burgers'),

       ('33fb44e3-5f18-04eb-80a1-d8b4e8a33f1b', 'Pizzas'),
       ('33fb44e3-5f18-04eb-80a1-d8b4e8a23f1b', 'Desserts'),
       ('33fb44e3-5f18-04eb-80a1-d8b4e8a11f1b', 'Drinks'),

       ('77fb44e3-3f18-02eb-82a1-d8b4e8a22f1b', 'Soups'),
       ('77fb44e3-3f18-03eb-82a1-d8b4e8a22f1b', 'Paste'),
       ('77fb44e3-3f18-04eb-82a1-d8b4e8a22f1b', 'Meat'),

       ('99fb44e3-1f18-01eb-20a1-d8b4e8a22f1b', 'Curry'),
       ('99fb44e3-1f18-02eb-20a1-d8b4e8a22f1b', 'Soups'),
       ('99fb44e3-1f18-03eb-20a1-d8b4e8a22f1b', 'Wok');


INSERT INTO dishes (id, restaurant_id, type, cost, name, image)
VALUES ('01aa44e3-5f18-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 35, 'Filet mignon steak',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/c45b77a2-4865-476c-8be8-da23d432d0f4.jpeg'),
       ('02aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 25.90, 'Pork steaks',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/c9b2d180-99ab-4fe6-ba9f-3152eb458ab2.jpg'),
       ('03aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 6.80, 'Mini Caesar salad with chicken',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/e4ca6f37-23dd-49dc-9301-773a11b8d8bb.jpg'),
       ('04aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 6.80, 'Mini Caesar salad with salmon',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/06610fa1-7d57-4028-ad9d-e7695c3a1590.jpg'),
       ('05aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 16.90, 'Meat salad',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/75134d88-2e54-4ad4-bb03-1bfbf8e2a006.jpg'),
       ('06aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 10.30, 'Greek salad',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/2aee1d8f-832c-4ec9-ae63-aa8ef907ef83.jpg'),
       ('07aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 11, 'Vegetable snack',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/85d69d91-684e-4544-911b-6d4874c112b2.jpg'),
       ('08aa44e3-0000-45eb-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 19, 'Carpaccio',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/3baa1429-f9e9-4a76-83c9-612b921c0aa7.jpg'),

       ('01bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '22fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 4, 'Chef Burger junior',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/b9bd80ff-3f12-4a10-9950-436457ba8587.png'),
       ('02bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '22fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 4, 'Chef Burger junior spicy',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/3efc0757-04c1-4c8e-8be7-6b1691146a19.jpg'),
       ('03bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '22fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 14.10, 'Basket S',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/694af036-329b-4482-b45f-de9d646b646d.png'),
       ('04bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '22fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 19.80, 'Basket M',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/bdcc6a1e-2062-4021-a095-3e376de15b57.png'),
       ('05bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 4.69, 'Two legs',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/ca5fe645-4a38-44e0-849d-b877b4369362.jpg'),
       ('06bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 5, 'Three strips',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/927adc3d-9c78-4107-9dae-15e6342f7100.png'),
       ('07bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '23fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 0.9, 'Cheese sauce',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/e3ed28ac-4322-4cf3-8444-c58498455c50.jpg'),
       ('08bb44e3-0000-45eb-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '23fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 0.9, 'Barbecue sauce',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/9a168f6f-342c-4217-b0e0-fe8259b8e427.jpg'),

       ('01ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '33fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 6.30, 'Big King',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/d037b4e8-b3cb-46db-bc97-3ef7f459b17a.jpg'),
       ('02ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '33fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 7, 'Whopper',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/6738b828-aa21-42e7-8968-4485cc1f127c.jpg'),
       ('03ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '33fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 5.90, 'Chicken King',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/2ddd8e8c-70ac-4604-a93e-2eff32522238.jpg'),
       ('04ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '33fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 9.50, 'Mozzarella Chicken',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/3e265f1b-8aa7-470c-b70c-e77f9f17e597.jpg'),
       ('05ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '33fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 7.90, 'Shrimp King',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/16c82df5-5876-42b3-8f02-32b2a618c56e.jpg'),
       ('07ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 12.50, 'King Bouquet',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/a3c6f71d-6a3a-4391-922e-70e9106ebadd.jpg'),
       ('08ee44e3-0000-45eb-80a1-d8b4e8a22f1b', '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 5.30, 'King Nuggets M',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/421648f7-034a-442e-8ca2-5e6068a05219.jpg'),

       ('01ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '33fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 10.10, 'Big Tasty',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/497f6c1b-fbd8-4877-a6af-99caf81c9e82.jpg'),
       ('02ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '33fb44e3-5f18-01eb-80a1-d8b4e8a22f1b', 6.50, 'Big Mac',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/5451021c-a9d3-45ea-b5f7-db0133ee7558.jpg'),
       ('03ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '33fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 2.70, 'Chicken burger',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/5940dd0d-0c26-4249-bdf3-492ba595dab8.png'),
       ('04ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '33fb44e3-5f18-02eb-80a1-d8b4e8a22f1b', 6, 'McChicken',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/5c687172-3f60-4542-8484-5f33e33e6d08.jpg'),
       ('05ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '33fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 6.50, 'Filet o fish',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/b0d7d522-b4a7-411b-9df2-a9c45dc9654b.jpg'),
       ('06ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '33fb44e3-5f18-03eb-80a1-d8b4e8a22f1b', 7.60, 'Double Fillet o Fish',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/3c099b3c-89f2-4122-acfc-9349e41d3c86.jpg'),
       ('07ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 4.10, 'French fries large',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/4f967c62-4b4e-4be7-b602-6a6b6466d8db.jpg'),
       ('08ff44e3-0000-45eb-80a1-d8b4e8a22f1b', '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b',
        '11fb44e3-5f18-04eb-80a1-d8b4e8a22f1b', 5.80, 'Chicken McNuggets 6 pcs',
        'https://onlineshop.fra1.digitaloceanspaces.com/01fb44e3-0000-45eb-80a1-d8b4e8a22f1b/5c770f70-908a-49a3-b368-724f116cf32d.jpg');

INSERT INTO orders (id, restaurant_id, payment_type, cost, delivery_time, address, client_phone_number,
                    client_full_name)
VALUES ('01ff44e3-5f18-0000-80a1-d8b4e8a22f1b', '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b', 2, 32, '2016-06-22 19:10:25-07',
        'ул. Новоуфимская 11, Минск', '291111111', 'Иван Иванов'),
       ('02ff44e3-5f18-0001-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b', 2, 15, '2020-06-22 19:10:25-07',
        'улица Притыцкого 29', '291111112', 'Петя Петров'),
       ('03ff44e3-5f18-0002-80a1-d8b4e8a22f1b', '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b', 2, 15.3,
        '2022-02-22 19:10:25-07',
        'улица Притыцкого 30', '291111113', 'Катя Костевич');

INSERT INTO order_dishes (order_id, dish_id, amount)
VALUES ('01ff44e3-5f18-0000-80a1-d8b4e8a22f1b', '01ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 2),
       ('01ff44e3-5f18-0000-80a1-d8b4e8a22f1b', '02ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 2),

       ('02ff44e3-5f18-0001-80a1-d8b4e8a22f1b', '03ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 3),

       ('03ff44e3-5f18-0002-80a1-d8b4e8a22f1b', '04ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 1),
       ('03ff44e3-5f18-0002-80a1-d8b4e8a22f1b', '05ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 1),
       ('03ff44e3-5f18-0002-80a1-d8b4e8a22f1b', '06ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 1),
       ('03ff44e3-5f18-0002-80a1-d8b4e8a22f1b', '07ff44e3-0000-45eb-80a1-d8b4e8a22f1b', 1);

INSERT INTO category_restaurants(category_id, restaurant_id)
VALUES (1, '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b'),
       (2, '01fb44e3-5f18-45eb-80a1-d8b4e8a22f1b'),
       (1, '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b'),
       (2, '02fb44e3-5f18-45eb-80a1-d8b4e8a22f1b'),
       (3, '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b'),
       (5, '03fb44e3-5f18-45eb-80a1-d8b4e8a22f1b'),
       (2, '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b'),
       (3, '04fb44e3-5f18-41eb-80a1-d8b4e8a99f1b'),
       (1, '05fb44e3-3f18-43eb-82a1-d8b4e8a22f1b'),
       (5, '05fb44e3-3f18-43eb-82a1-d8b4e8a22f1b'),
       (4, '06fb44e3-1f18-45eb-20a1-d8b4e8a22f1b'),
       (4, '04fb44e3-5f18-41eb-80a1-d8b4e8a77f1b'),
       (4, '04fb44e3-5f18-41eb-80a1-d8b4e8a11f1b'),
       (5, '06fb44e3-1f18-45eb-20a1-d8b4e8a22f1b');